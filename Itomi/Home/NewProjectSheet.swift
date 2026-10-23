// Sheet for starting a new project (or editing one): hook or needles, name, size, yarn, and how to count

import SwiftUI
import SwiftData
import PhotosUI

struct NewProjectSheet: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss

    // Set when editing an existing project instead of making a new one
    var projectToEdit: Project?

    @State private var name = ""
    @State private var usesNeedles = false
    @State private var hookSize = "4.0 mm"
    @State private var yarn = ""
    @State private var usesParts = true
    @State private var countsInRounds = true
    @State private var pickedPhoto: PhotosPickerItem?
    @State private var photoData: Data?

    let hookSizes = [
        "2.0 mm", "2.25 mm", "2.5 mm", "2.75 mm", "3.0 mm", "3.25 mm", "3.5 mm", "3.75 mm",
        "4.0 mm", "4.5 mm", "5.0 mm", "5.5 mm", "6.0 mm", "6.5 mm", "7.0 mm", "8.0 mm",
        "9.0 mm", "10.0 mm", "12.0 mm"
    ]

    // Start with the project's details filled in when editing
    init(projectToEdit: Project? = nil) {
        self.projectToEdit = projectToEdit
        if let project = projectToEdit {
            _name = State(initialValue: project.name)
            _usesNeedles = State(initialValue: project.usesNeedles)
            _hookSize = State(initialValue: project.hookSize)
            _yarn = State(initialValue: project.yarn)
            _usesParts = State(initialValue: project.usesParts)
            _countsInRounds = State(initialValue: project.countsInRounds)
            _photoData = State(initialValue: project.photo)
        }
    }

    var body: some View {
        NavigationStack {
            Form {
                Section {
                    photoBox
                }
                .listRowBackground(Color.clear)

                // Same choice as onboarding: crochet hook or knitting needles
                Section {
                    Picker("I'm using a", selection: $usesNeedles) {
                        Text("Crochet hook").tag(false)
                        Text("Knitting needles").tag(true)
                    }
                    .pickerStyle(.segmented)
                    .labelsHidden()
                }
                .listRowBackground(Color.clear)
                .listRowInsets(EdgeInsets())

                Section {
                    LabeledContent("Name") {
                        TextField("Name", text: $name, prompt: Text("e.g. Bunny"))
                            .multilineTextAlignment(.trailing)
                    }
                    Picker(sizeLabel, selection: $hookSize) {
                        ForEach(hookSizes, id: \.self) { size in
                            Text(size)
                        }
                    }
                    LabeledContent("Yarn") {
                        TextField("Yarn", text: $yarn, prompt: Text("Optional"))
                            .multilineTextAlignment(.trailing)
                    }
                }

                Section {
                    // Parts can't be switched on or off once the project exists
                    if projectToEdit == nil {
                        Toggle(isOn: $usesParts) {
                            Text("Split into parts")
                            Text("Head, body, arms… each with its own counter")
                        }
                    }
                    Toggle(isOn: $countsInRounds) {
                        Text("Count in rounds")
                        Text("Off counts rows instead")
                    }
                }
            }
            .scrollContentBackground(.hidden)
            .background(Color.warmBackground)
            // Tick when the hook/needles choice, a size or a switch changes
            .onChange(of: usesNeedles) {
                Haptics.light()
            }
            .onChange(of: hookSize) {
                Haptics.light()
            }
            .onChange(of: usesParts) {
                Haptics.light()
            }
            .onChange(of: countsInRounds) {
                Haptics.light()
            }
            .navigationTitle(projectToEdit == nil ? "New project" : "Edit project")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        Haptics.light()
                        dismiss()
                    }
                }
                ToolbarItem(placement: .confirmationAction) {
                    if projectToEdit == nil {
                        Button("Create") {
                            createProject()
                        }
                        .disabled(trimmedName.isEmpty)
                    } else {
                        Button("Save") {
                            saveEdits()
                        }
                        .disabled(trimmedName.isEmpty)
                    }
                }
            }
            // Shrink a newly picked photo and keep it until Create
            .onChange(of: pickedPhoto) {
                guard let item = pickedPhoto else {
                    return
                }
                Task {
                    photoData = await PhotoShrinker.load(item)
                }
            }
        }
    }

    // Dashed "Add photo" box, or the picked photo at the same size
    var photoBox: some View {
        PhotosPicker(selection: $pickedPhoto, matching: .images) {
            Color.clear
                .frame(width: 170, height: 170)
                .overlay {
                    if let photoData, let image = UIImage(data: photoData) {
                        Image(uiImage: image)
                            .resizable()
                            .scaledToFill()
                    } else {
                        RoundedRectangle(cornerRadius: 40)
                            .strokeBorder(style: StrokeStyle(lineWidth: 2.5, dash: [8]))
                            .foregroundStyle(.tint.opacity(0.4))
                        VStack(spacing: 8) {
                            Image(systemName: "camera.fill")
                                .font(.largeTitle)
                            Text("Add photo")
                                .font(.headline)
                                .fontWeight(.semibold)
                        }
                        .foregroundStyle(.tint)
                    }
                }
                .clipShape(RoundedRectangle(cornerRadius: 40))
        }
        // No haptic here: a tap gesture on a list row stops the photo picker from opening
        .frame(maxWidth: .infinity)
    }

    // "Hook size" or "Needle size"
    var sizeLabel: String {
        if usesNeedles {
            return "Needle size"
        }
        return "Hook size"
    }

    // The name without extra spaces at the start or end
    var trimmedName: String {
        return name.trimmingCharacters(in: .whitespaces)
    }

    // Save changes to the project being edited and close the sheet
    func saveEdits() {
        guard let project = projectToEdit else {
            return
        }
        project.name = trimmedName
        project.usesNeedles = usesNeedles
        project.hookSize = hookSize
        project.yarn = yarn.trimmingCharacters(in: .whitespaces)
        project.countsInRounds = countsInRounds
        project.photo = photoData

        do {
            try modelContext.save()
        } catch {
            print("Couldn't save project: \(error)")
        }
        Haptics.light()
        dismiss()
    }

    // Save the new project and close the sheet
    func createProject() {
        let project = Project(
            name: trimmedName,
            hookSize: hookSize,
            yarn: yarn.trimmingCharacters(in: .whitespaces),
            usesParts: usesParts,
            countsInRounds: countsInRounds
        )
        project.usesNeedles = usesNeedles
        project.photo = photoData
        modelContext.insert(project)
        Analytics.projectCreated(project, from: "New project")

        // No parts: give it one hidden part so the counter always has something to count
        if usesParts == false {
            let onlyPart = Part(name: trimmedName, sortOrder: 0)
            project.parts.append(onlyPart)
        }

        // Save now so a force-quit can't lose it
        do {
            try modelContext.save()
        } catch {
            print("Couldn't save project: \(error)")
        }
        Haptics.success()
        dismiss()
    }
}

#Preview {
    NewProjectSheet()
        .modelContainer(for: Project.self, inMemory: true)
}
