// "Putting Bunny together": tick off the sewing-up steps once every part is made

import SwiftUI
import SwiftData

struct AssemblySheet: View {
    @Environment(\.themeColor) private var themeColor
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss

    let project: Project
    @State private var showingAddStep = false
    @State private var newStepText = ""
    @State private var stepBeingRenamed: AssemblyStep?
    @State private var renameText = ""

    var body: some View {
        NavigationStack {
            List {
                Section {
                    header
                }
                .listRowBackground(Color.clear)
                .listRowInsets(EdgeInsets())

                Section {
                    ForEach(project.sortedAssemblySteps) { step in
                        stepRow(step)
                    }
                    .onDelete(perform: deleteSteps)

                    Button("Add a step", systemImage: "plus") {
                        newStepText = ""
                        showingAddStep = true
                        Haptics.light()
                    }
                } header: {
                    ListSectionTitle(text: "Steps")
                } footer: {
                    Text("Hold a step to rename it, or swipe to remove it.")
                }
            }
            .scrollContentBackground(.hidden)
            .background(Color.warmBackground)
            .navigationBarTitleDisplayMode(.inline)
            .safeAreaInset(edge: .bottom) {
                if allStepsDone {
                    finishButton
                        .transition(.move(edge: .bottom).combined(with: .opacity))
                }
            }
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("Done") {
                        Haptics.light()
                        dismiss()
                    }
                }
            }
            .alert("New step", isPresented: $showingAddStep) {
                TextField("e.g. Attach the tail", text: $newStepText)
                Button("Cancel", role: .cancel) {}
                Button("Add") {
                    addStep()
                }
            }
            .alert("Rename step", isPresented: renameAlertShowing) {
                TextField("Step", text: $renameText)
                Button("Cancel", role: .cancel) {}
                Button("Save") {
                    renameStep()
                }
            }
        }
        .onAppear {
            project.addDefaultAssemblySteps()
            saveChanges()
        }
    }

    // Loop, title and a gentle line about where things stand
    var header: some View {
        VStack(spacing: 12) {
            LoopMark(size: 56, color: themeColor)
            Text("Putting \(project.name) together")
                .font(.title)
                .fontWeight(.bold)
                .multilineTextAlignment(.center)
            Text(headerSubtitle)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
                .contentTransition(.opacity)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 8)
    }

    // e.g. "Every part is made. Take your time." or "All sewn up. Lovely work."
    var headerSubtitle: String {
        if allStepsDone {
            return "All sewn up. Lovely work."
        }
        if project.assemblyStepsDone == 0 {
            return "Every part is made. Take your time."
        }
        return "\(project.assemblyStepsDone) of \(project.assemblySteps.count) done. No rush."
    }

    // One step: tap anywhere on the row to tick it
    func stepRow(_ step: AssemblyStep) -> some View {
        Button {
            withAnimation(.snappy) {
                step.isDone.toggle()
            }
            Haptics.light()
            saveChanges()
        } label: {
            HStack(spacing: 14) {
                if step.isDone {
                    Image(systemName: "checkmark.circle.fill")
                        .font(.title2)
                        .foregroundStyle(themeColor)
                } else {
                    Image(systemName: "circle")
                        .font(.title2)
                        .foregroundStyle(.secondary)
                }
                Text(step.text)
                    .foregroundStyle(step.isDone ? .secondary : .primary)
                    .strikethrough(step.isDone, color: .secondary)
                Spacer()
            }
            .frame(minHeight: 44)
            .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
        .contextMenu {
            Button("Rename", systemImage: "pencil") {
                renameText = step.text
                stepBeingRenamed = step
            }
        }
        .accessibilityAddTraits(step.isDone ? .isSelected : [])
    }

    // Shows once every step is ticked
    var finishButton: some View {
        Button {
            finishProject()
        } label: {
            Text("Finish \(project.name)")
                .font(.headline)
                .fontWeight(.semibold)
                .frame(maxWidth: .infinity)
        }
        .buttonStyle(.glassProminent)
        .controlSize(.extraLarge)
        .padding(.horizontal)
    }

    var allStepsDone: Bool {
        return project.assemblySteps.isEmpty == false && project.assemblyStepsDone == project.assemblySteps.count
    }

    // The rename alert is open while a step is being renamed
    var renameAlertShowing: Binding<Bool> {
        Binding(
            get: { stepBeingRenamed != nil },
            set: { isShowing in
                if isShowing == false {
                    stepBeingRenamed = nil
                }
            }
        )
    }

    func addStep() {
        let text = newStepText.trimmingCharacters(in: .whitespaces)
        if text.isEmpty {
            return
        }
        withAnimation {
            project.addAssemblyStep(text)
        }
        Haptics.light()
        saveChanges()
    }

    func renameStep() {
        let text = renameText.trimmingCharacters(in: .whitespaces)
        if let step = stepBeingRenamed, text.isEmpty == false {
            step.text = text
            saveChanges()
        }
        stepBeingRenamed = nil
    }

    func deleteSteps(at offsets: IndexSet) {
        let steps = project.sortedAssemblySteps
        for index in offsets {
            modelContext.delete(steps[index])
        }
        saveChanges()
    }

    // Mark the project finished; whoever opened this sheet shows the finish screen
    func finishProject() {
        project.isFinished = true
        project.finishedAt = Date.now
        Haptics.success()
        saveChanges()
        LockScreenCounter.projectEnded(project)
        Analytics.projectFinished()
        dismiss()
    }

    func saveChanges() {
        do {
            try modelContext.save()
        } catch {
            print("Couldn't save assembly steps: \(error)")
        }
    }
}
