// The counter: tap the big card to add a round, count stitches, undo

import SwiftUI
import SwiftData

struct CounterView: View {
    @Environment(\.modelContext) private var modelContext

    let project: Project
    @State private var part: Part
    @State private var showingAddPart = false
    @AppStorage("keepScreenOn") private var keepScreenOn = true

    init(project: Project, part: Part) {
        self.project = project
        _part = State(initialValue: part)
    }

    var body: some View {
        VStack(spacing: 16) {
            roundCard

            if part.isCopyFinished && part.currentCopy < part.copies {
                Button("Start \(part.name) \(part.currentCopy + 1) of \(part.copies)") {
                    part.startNextCopy()
                    Haptics.success()
                    saveChanges()
                }
                .buttonStyle(.glassProminent)
                .controlSize(.large)
            }

            stitchCard

            Button("Undo", systemImage: "arrow.uturn.backward") {
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
        // Keep the screen on while counting
        .onAppear {
            UIApplication.shared.isIdleTimerDisabled = keepScreenOn
        }
        .onDisappear {
            UIApplication.shared.isIdleTimerDisabled = false
        }
    }

    // The big plum card: tap anywhere on it to add a round
    var roundCard: some View {
        Button {
            part.addRound()
            playRoundHaptic()
            saveChanges()
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
                    if let expected = part.expectedStitches(forRound: part.currentRound) {
                        Text("of \(expected)")
                            .foregroundStyle(.secondary)
                    }
                }
            }
            .accessibilityElement(children: .combine)
            Spacer()

            Button("Remove stitch", systemImage: "minus") {
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
