// One project's page: its details, parts and notes

import SwiftUI
import SwiftData
import PhotosUI

struct ProjectDetailView: View {
    @Environment(\.modelContext) private var modelContext
    @Bindable var project: Project

    @State private var showingAddPart = false
    @State private var showingFinish = false
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
                        NavigationLink {
                            CounterView(project: project, part: part)
                        } label: {
                            PartRow(part: part)
                        }
                        .simultaneousGesture(TapGesture().onEnded { Haptics.light() })
                    }
                    Button("Add part", systemImage: "plus") {
                        showingAddPart = true
                        Haptics.light()
                    }
                } header: {
                    ListSectionTitle(text: "Parts")
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
                    project.isFinished = true
                    project.finishedAt = Date.now
                    Haptics.success()
                    saveChanges()
                    showingFinish = true
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

    // Big button at the bottom that opens the counter where you left off
    @ViewBuilder
    var continueButton: some View {
        if let part = project.currentPart {
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
