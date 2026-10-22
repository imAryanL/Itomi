// One project's page: its details, parts and notes

import SwiftUI
import SwiftData
import PhotosUI

struct ProjectDetailView: View {
    @Environment(\.modelContext) private var modelContext
    @Bindable var project: Project

    @State private var showingAddPart = false
    @State private var showingFinish = false
    @State private var showingAssembly = false
    @State private var openedPart: Part?
    @State private var showingFinishCheck = false
    @State private var pickedPhoto: PhotosPickerItem?

    var body: some View {
        List {
            Section {
                header
            }
            .listRowBackground(Color.clear)
            .listRowInsets(EdgeInsets())

            if project.usesParts {
                Section {
                    ForEach(project.sortedParts) { part in
                        // A plain button, since a tap gesture on a List link stops it opening
                        Button {
                            Haptics.light()
                            openedPart = part
                        } label: {
                            HStack(spacing: 12) {
                                PartRow(part: part)
                                Image(systemName: "chevron.right")
                                    .font(.footnote)
                                    .fontWeight(.semibold)
                                    .foregroundStyle(.tertiary)
                            }
                            .contentShape(Rectangle())
                        }
                        .buttonStyle(.plain)
                    }
                    Button("Add part", systemImage: "plus") {
                        showingAddPart = true
                        Haptics.light()
                    }
                } header: {
                    ListSectionTitle(text: "Parts")
                }

                // Shows once every part is made and the project isn't finished yet
                if project.allPartsDone && project.isFinished == false {
                    Section {
                        assemblyRow
                    } header: {
                        ListSectionTitle(text: "Putting it together")
                    }
                }
            } else if let onlyPart = project.sortedParts.first {
                Section {
                    CountCard(part: onlyPart)
                } header: {
                    ListSectionTitle(text: "Progress")
                }
            }

            Section {
                TextField("Notes", text: $project.notes, prompt: Text("Anything to remember"), axis: .vertical)
                    .lineLimit(3...)
            } header: {
                ListSectionTitle(text: "Notes")
            }
        }
        .scrollContentBackground(.hidden)
        .background(Color.warmBackground)
        .navigationBarTitleDisplayMode(.inline)
        .safeAreaInset(edge: .bottom) {
            if project.isFinished == false {
                continueButton
            }
        }
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                moreMenu
            }
        }
        .sheet(isPresented: $showingAddPart) {
            AddPartSheet(project: project)
        }
        // Gentle check before finishing with parts still going
        .alert("Finish \(project.name)?", isPresented: $showingFinishCheck) {
            Button("Keep going", role: .cancel) {}
            Button("Finish anyway") {
                finishProject()
            }
        } message: {
            Text(finishCheckMessage)
        }
        // Tapping a part opens its counter
        .navigationDestination(item: $openedPart) { part in
            CounterView(project: project, part: part)
        }
        // Finishing from the checklist opens the finish screen next
        .sheet(isPresented: $showingAssembly, onDismiss: {
            if project.isFinished {
                showingFinish = true
            }
        }) {
            AssemblySheet(project: project)
        }
        .fullScreenCover(isPresented: $showingFinish) {
            FinishView(project: project)
        }
        // Save notes as they're typed
        .onChange(of: project.notes) {
            saveChanges()
        }
        // Save a newly picked photo
        .onChange(of: pickedPhoto) {
            guard let item = pickedPhoto else {
                return
            }
            Task {
                if let data = await PhotoShrinker.load(item) {
                    project.photo = data
                    saveChanges()
                }
            }
        }
    }

    // How many parts aren't done yet (0 for a project without parts)
    var partsLeft: Int {
        if project.usesParts == false {
            return 0
        }
        var left = 0
        for part in project.parts {
            if part.isDone == false {
                left += 1
            }
        }
        return left
    }

    // e.g. "2 parts aren't done yet. You can still finish it now."
    var finishCheckMessage: String {
        if partsLeft == 1 {
            return "1 part isn't done yet. You can still finish it now."
        }
        return "\(partsLeft) parts aren't done yet. You can still finish it now."
    }

    // Move the project to the Finished shelf and show the finish screen
    func finishProject() {
        project.isFinished = true
        project.finishedAt = Date.now
        Haptics.success()
        saveChanges()
        showingFinish = true
    }

    // The ••• menu: finish the project, or move it back to In progress
    var moreMenu: some View {
        Menu("More", systemImage: "ellipsis") {
            if project.isFinished {
                Button("Move back to In progress", systemImage: "arrow.uturn.backward") {
                    project.isFinished = false
                    project.finishedAt = nil
                    Haptics.light()
                    saveChanges()
                }
            } else {
                Button("Finish project", systemImage: "checkmark.circle") {
                    // Parts still going: ask first, so it can't happen by mistake
                    if partsLeft > 0 {
                        showingFinishCheck = true
                        Haptics.light()
                    } else {
                        finishProject()
                    }
                }
            }
        }
    }

    var header: some View {
        HStack(spacing: 16) {
            PhotosPicker(selection: $pickedPhoto, matching: .images) {
                ProjectThumbnail(project: project, size: 80)
            }
            // Only the photo opens the picker, not the whole row
            .buttonStyle(.borderless)
            .simultaneousGesture(TapGesture().onEnded { Haptics.light() })
            .accessibilityLabel("Change photo")

            VStack(alignment: .leading, spacing: 8) {
                Text(project.name)
                    .font(.largeTitle)
                    .fontWeight(.bold)
                HStack {
                    if project.hookSize.isEmpty == false {
                        DetailChip(text: project.toolText)
                    }
                    if project.yarn.isEmpty == false {
                        DetailChip(text: project.yarn)
                    }
                }
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }

    // Row that opens the checklist, e.g. "2 of 4 steps done"
    var assemblyRow: some View {
        Button {
            showingAssembly = true
            Haptics.light()
        } label: {
            HStack(spacing: 14) {
                LoopMark(size: 28, color: .accent)
                VStack(alignment: .leading, spacing: 2) {
                    Text("Every part is made")
                        .font(.headline)
                        .fontWeight(.semibold)
                    Text(assemblyStatusText)
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                }
                Spacer()
                Image(systemName: "chevron.right")
                    .font(.footnote)
                    .fontWeight(.semibold)
                    .foregroundStyle(.tertiary)
            }
            .frame(minHeight: 44)
            .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
    }

    // e.g. "Stuff, sew and finish up" or "2 of 4 steps done"
    var assemblyStatusText: String {
        if project.assemblySteps.isEmpty {
            return "Stuff, sew and finish up"
        }
        return "\(project.assemblyStepsDone) of \(project.assemblySteps.count) steps done"
    }

    // Big button at the bottom: opens the counter where you left off, or the checklist when every part is made
    @ViewBuilder
    var continueButton: some View {
        if project.allPartsDone {
            Button {
                showingAssembly = true
                Haptics.light()
            } label: {
                Text("Put it together")
                    .font(.headline)
                    .fontWeight(.semibold)
                    .frame(maxWidth: .infinity)
            }
            .buttonStyle(.glassProminent)
            .controlSize(.extraLarge)
            .padding(.horizontal)
        } else if let part = project.currentPart {
            NavigationLink {
                CounterView(project: project, part: part)
            } label: {
                Text(continueTitle(for: part))
                    .font(.headline)
                    .fontWeight(.semibold)
                    .frame(maxWidth: .infinity)
            }
            .buttonStyle(.glassProminent)
            .controlSize(.extraLarge)
            .simultaneousGesture(TapGesture().onEnded { Haptics.light() })
            .padding(.horizontal)
        }
    }

    // e.g. "Continue Head · Round 5" or "Start Head"
    func continueTitle(for part: Part) -> String {
        var title = ""
        if part.lastCountedAt == nil {
            title = "Start"
        } else {
            title = "Continue"
        }
        if project.usesParts {
            title += " \(part.currentCopyName)"
        }
        if part.lastCountedAt != nil {
            title += " · \(part.countWord) \(part.currentRound)"
        }
        return title
    }

    func saveChanges() {
        do {
            try modelContext.save()
        } catch {
            print("Couldn't save project: \(error)")
        }
    }
}

// Small rounded label, e.g. "4.0 mm hook"
struct DetailChip: View {
    let text: String

    var body: some View {
        Text(text)
            .font(.subheadline)
            .padding(.horizontal, 10)
            .padding(.vertical, 4)
            .background(.background, in: Capsule())
    }
}

// Big count for a project without parts, e.g. "Row 64 · Last counted today"
struct CountCard: View {
    let part: Part

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack(alignment: .firstTextBaseline, spacing: 8) {
                Text("\(part.countWord) \(part.currentRound)")
                    .font(.system(size: 40, design: .rounded))
                    .fontWeight(.bold)
                    .foregroundStyle(Color.accent)
                    .contentTransition(.numericText())
                if let planned = part.plannedRounds {
                    Text("of \(planned)")
                        .font(.title3)
                        .fontWeight(.semibold)
                        .foregroundStyle(.secondary)
                }
            }
            Text(lastCountedText)
                .font(.subheadline)
                .foregroundStyle(.secondary)

            // Only show a bar when there's a goal to fill it toward
            if part.plannedRounds != nil {
                ThickProgressBar(value: part.progress, isDone: part.isDone)
            }
        }
        .padding(.vertical, 6)
        .accessibilityElement(children: .combine)
    }

    // e.g. "Last counted 5 minutes ago", or "Not started yet"
    var lastCountedText: String {
        guard let date = part.lastCountedAt else {
            return "Not started yet"
        }
        let when = date.formatted(.relative(presentation: .named))
        return "Last counted \(when)"
    }
}
