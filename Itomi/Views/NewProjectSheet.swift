// Sheet for starting a new project: name, hook size, yarn, and how to count

import SwiftUI
import SwiftData
import PhotosUI

struct NewProjectSheet: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss

    @State private var name = ""
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

    var body: some View {
        NavigationStack {
            Form {
                Section {
                    photoBox
                }
                .listRowBackground(Color.clear)

                Section {
                    LabeledContent("Name") {
                        TextField("Name", text: $name, prompt: Text("e.g. Bunny"))
                            .multilineTextAlignment(.trailing)
                    }
                    Picker("Hook size", selection: $hookSize) {
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
                    Toggle(isOn: $usesParts) {
                        Text("Split into parts")
                        Text("Head, body, arms… each with its own counter")
                    }
                    Toggle(isOn: $countsInRounds) {
                        Text("Count in rounds")
                        Text("Off counts rows instead")
                    }
                }
            }
            .scrollContentBackground(.hidden)
            .background(Color.warmBackground)
            .navigationTitle("New project")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Create") {
                        createProject()
                    }
                    .disabled(trimmedName.isEmpty)
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

    // Dashed "Add photo" box, or the picked photo
    var photoBox: some View {
        PhotosPicker(selection: $pickedPhoto, matching: .images) {
            ZStack {
                if let photoData, let image = UIImage(data: photoData) {
                    Image(uiImage: image)
                        .resizable()
                        .scaledToFill()
                } else {
                    RoundedRectangle(cornerRadius: 28)
                        .strokeBorder(style: StrokeStyle(lineWidth: 2, dash: [6]))
                        .foregroundStyle(.tint.opacity(0.4))
                    VStack(spacing: 6) {
                        Image(systemName: "camera")
                            .font(.title2)
                        Text("Add photo")
                            .font(.subheadline.bold())
                    }
                    .foregroundStyle(.tint)
                }
            }
            .frame(width: 120, height: 120)
            .clipShape(RoundedRectangle(cornerRadius: 28))
        }
        .frame(maxWidth: .infinity)
    }

    // The name without extra spaces at the start or end
    var trimmedName: String {
        return name.trimmingCharacters(in: .whitespaces)
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
        project.photo = photoData
        modelContext.insert(project)

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
        dismiss()
    }
}

#Preview {
    NewProjectSheet()
        .modelContainer(for: Project.self, inMemory: true)
}
