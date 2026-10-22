// The counter: tap the big card to add a round, count stitches, undo

import SwiftUI
import SwiftData

struct CounterView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss
    @Environment(ProStore.self) private var proStore

    let project: Project
    @State private var part: Part
    @State private var showingAddPart = false
    @State private var editingPart: Part?
    @State private var stitchWarning: StitchWarning?
    @State private var showingPartDone = false
    @State private var showingFinish = false
    @State private var showingAssembly = false
    @State private var welcomeBackText: String? = nil
    @AppStorage("keepScreenOn") private var keepScreenOn = true

    init(project: Project, part: Part) {
        self.project = project
        _part = State(initialValue: part)
    }

    var body: some View {
        VStack(spacing: 16) {
            if let welcomeBackText {
                WelcomeBackLine(text: welcomeBackText)
                    .transition(.opacity)
            }

            if showingPartDone {
                PartDoneCard(
                    part: part,
                    nextPart: nextPart,
                    onNext: goToNextPart,
                    onPutTogether: openAssembly,
                    onKeepCounting: hidePartDone
                )
                .transition(.opacity)
            } else {
                roundCard
                    .transition(.opacity)
            }

            if part.isCopyFinished && part.currentCopy < part.copies {
                Button("Start \(part.name) \(part.currentCopy + 1) of \(part.copies)") {
                    part.startNextCopy()
                    Haptics.success()
                    saveChanges()
                }
                .buttonStyle(.glassProminent)
                .controlSize(.large)
            }

            if let stitchWarning {
                StitchWarningCard(warning: stitchWarning, onFix: fixStitches, onKeepGoing: hideStitchWarning)
                    .transition(.opacity)
            }

            stitchCard

            Button("Undo", systemImage: "arrow.uturn.backward") {
                showingPartDone = false
                stitchWarning = nil
                part.undo()
                Haptics.medium()
                saveChanges()
            }
            .buttonStyle(.glass)
            .controlSize(.large)
            .disabled(part.canUndo == false)
        }
        .padding(.horizontal)
        .padding(.bottom)
        .background(Color.warmBackground)
        // Cap text size so the stitch row and Undo still fit under the big card
        .dynamicTypeSize(...DynamicTypeSize.accessibility1)
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .principal) {
                partSwitcher
            }
        }
        .sheet(isPresented: $showingAddPart) {
            AddPartSheet(project: project)
        }
        .sheet(item: $editingPart) { partToEdit in
            AddPartSheet(project: project, partToEdit: partToEdit)
        }
        // Finishing from the checklist opens the finish screen next
        .sheet(isPresented: $showingAssembly, onDismiss: {
            if project.isFinished {
                showingFinish = true
            }
        }) {
            AssemblySheet(project: project)
        }
        // After the finish screen, go back to where the counter was opened from
        .fullScreenCover(isPresented: $showingFinish, onDismiss: { dismiss() }) {
            FinishView(project: project)
        }
        // Keep the screen on while counting
        .onAppear {
            UIApplication.shared.isIdleTimerDisabled = keepScreenOn
            welcomeBackText = makeWelcomeBackText()
            LockScreenCounter.show(part)
        }
        // Hide the welcome line once counting starts again, and keep the Lock Screen card in step
        .onChange(of: part.lastCountedAt) {
            withAnimation {
                welcomeBackText = nil
            }
            LockScreenCounter.show(part)
        }
        // Switching parts moves the Lock Screen card to the new part
        .onChange(of: part) {
            LockScreenCounter.show(part)
        }
        .onDisappear {
            UIApplication.shared.isIdleTimerDisabled = false
        }
    }

    // The big plum card: tap anywhere on it to add a round
    var roundCard: some View {
        Button {
            let wasDone = part.isDone
            let warning = checkStitches()
            part.addRound()
            saveChanges()

            if let warning {
                Haptics.warning()
                AccessibilityNotification.Announcement(warning.title).post()
            } else {
                playRoundHaptic()
            }
            withAnimation {
                stitchWarning = warning
            }

            // This tap finished the whole part: show the done card
            if project.usesParts && wasDone == false && part.isDone {
                withAnimation {
                    showingPartDone = true
                }
            }
        } label: {
            VStack(spacing: 8) {
                Text(part.countWord.uppercased())
                    .font(.headline)
                    .fontWeight(.semibold)
                    .opacity(0.8)
                Text("\(part.currentRound)")
                    .font(.system(size: 160, design: .rounded))
                    .fontWeight(.bold)
                    .minimumScaleFactor(0.5)
                    .lineLimit(1)
                    .contentTransition(.numericText())
                if let planned = part.plannedRounds {
                    Text("of \(planned)")
                        .font(.title3)
                }
                Text("Tap anywhere to add a \(part.countWord.lowercased())")
                    .font(.subheadline)
                    .opacity(0.8)
                    .padding(.top, 16)
            }
            .foregroundStyle(.white)
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .background(Color.accent, in: RoundedRectangle(cornerRadius: 32))
        }
        .buttonStyle(.plain)
        .accessibilityLabel(part.roundText)
        .accessibilityHint("Adds a \(part.countWord.lowercased())")
    }

    // Stitch count with minus and plus buttons
    var stitchCard: some View {
        HStack {
            VStack(alignment: .leading, spacing: 2) {
                Text("Stitches")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                HStack(alignment: .firstTextBaseline, spacing: 6) {
                    Text("\(part.currentStitch)")
                        .font(.largeTitle)
                        .fontWeight(.bold)
                        .contentTransition(.numericText())
                    if let expected = part.expectedStitchesNow {
                        Text("of \(expected)")
                            .foregroundStyle(.secondary)
                    }
                }
            }
            .accessibilityElement(children: .combine)
            Spacer()

            Button("Remove stitch", systemImage: "minus") {
                stitchWarning = nil
                part.removeStitch()
                Haptics.light()
                saveChanges()
            }
            .labelStyle(.iconOnly)
            .font(.title2)
            .buttonStyle(.glass)
            .buttonBorderShape(.circle)
            .controlSize(.large)
            .disabled(part.currentStitch == 0)

            Button("Add stitch", systemImage: "plus") {
                stitchWarning = nil
                part.addStitch()
                Haptics.medium()
                saveChanges()
            }
            .labelStyle(.iconOnly)
            .font(.title2)
            .buttonStyle(.glassProminent)
            .buttonBorderShape(.circle)
            .controlSize(.large)
        }
        .padding()
        .background(.background, in: RoundedRectangle(cornerRadius: 24))
    }

    // Title menu, e.g. "Bunny · Head", for jumping to another part
    @ViewBuilder
    var partSwitcher: some View {
        if project.usesParts {
            Menu {
                ForEach(project.sortedParts) { otherPart in
                    Button {
                        part = otherPart
                        showingPartDone = false
                        stitchWarning = nil
                        Haptics.light()
                    } label: {
                        if otherPart == part {
                            Label(otherPart.currentCopyName, systemImage: "checkmark")
                        } else {
                            Text(otherPart.currentCopyName)
                        }
                        Text(otherPart.statusText)
                    }
                }
                Divider()
                Button("Edit \(part.name)", systemImage: "pencil") {
                    editingPart = part
                    Haptics.light()
                }
                Button("Add part", systemImage: "plus") {
                    showingAddPart = true
                    Haptics.light()
                }
            } label: {
                HStack(spacing: 4) {
                    Text("\(project.name) · \(part.currentCopyName)")
                        .font(.headline)
                        .fontWeight(.semibold)
                    Image(systemName: "chevron.down")
                        .font(.caption)
                        .fontWeight(.bold)
                }
                .foregroundStyle(.primary)
            }
        } else {
            Text(project.name)
                .font(.headline)
                .fontWeight(.semibold)
        }
    }

    // The first part that isn't done yet, in list order
    var nextPart: Part? {
        for otherPart in project.sortedParts {
            if otherPart != part && otherPart.isDone == false {
                return otherPart
            }
        }
        return nil
    }

    // Switch the counter to the next part
    func goToNextPart() {
        guard let next = nextPart else {
            return
        }
        Haptics.light()
        withAnimation {
            part = next
            showingPartDone = false
            stitchWarning = nil
        }
    }

    // Pro: the round about to be finished doesn't have the stitches it should (only if stitches were counted)
    func checkStitches() -> StitchWarning? {
        if proStore.isPro == false || part.currentStitch == 0 {
            return nil
        }
        guard let expected = part.expectedStitchesNow else {
            return nil
        }
        if part.currentStitch == expected {
            return nil
        }
        let round = part.workingRound
        return StitchWarning(
            countWord: part.countWord,
            round: round,
            counted: part.currentStitch,
            expected: expected,
            expectedBefore: part.expectedStitches(forRound: round - 1)
        )
    }

    // Go back to the round before, stitches and all, to fix the count
    func fixStitches() {
        part.undo()
        Haptics.medium()
        saveChanges()
        withAnimation {
            stitchWarning = nil
            showingPartDone = false
        }
    }

    func hideStitchWarning() {
        Haptics.light()
        withAnimation {
            stitchWarning = nil
        }
    }

    // Every part is made: open the "Put it together" checklist
    func openAssembly() {
        Haptics.light()
        showingAssembly = true
    }

    // Back to the counter, past the planned rounds
    func hidePartDone() {
        Haptics.light()
        withAnimation {
            showingPartDone = false
        }
    }

    // "Last counted 3 days ago", only if the project wasn't counted today
    func makeWelcomeBackText() -> String? {
        guard let lastCounted = project.lastCountedAt else {
            return nil
        }
        if Calendar.current.isDateInToday(lastCounted) {
            return nil
        }
        let when = lastCounted.formatted(.relative(presentation: .named))
        return "Last counted \(when)"
    }

    // Heavy buzz for a round, or a double buzz when it hits the planned rounds
    func playRoundHaptic() {
        if part.currentRound == part.plannedRounds {
            Haptics.success()
        } else {
            Haptics.heavy()
        }
    }

    // Save after every tap so a force-quit can't lose a count
    func saveChanges() {
        do {
            try modelContext.save()
        } catch {
            print("Couldn't save count: \(error)")
        }
    }
}
