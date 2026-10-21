// Sheet for adding a part to a project: name, how many copies, how many rounds

import SwiftUI
import SwiftData

struct AddPartSheet: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss

    let project: Project

    @State private var name = ""
    @State private var copies = 1
    @State private var rounds = 10

    var body: some View {
        NavigationStack {
            Form {
                Section {
                    LabeledContent("Name") {
                        TextField("Name", text: $name, prompt: Text("e.g. Head"))
                            .multilineTextAlignment(.trailing)
                    }
                    Stepper(value: $copies, in: 1...20) {
                        LabeledContent("Make", value: "×\(copies)")
                    }
                    Stepper(value: $rounds, in: 1...500) {
                        LabeledContent("\(project.countWord)s", value: "\(rounds)")
                    }
                }
            }
            .scrollContentBackground(.hidden)
            .background(Color.warmBackground)
            .navigationTitle("Add a part")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Add") {
                        addPart()
                    }
                    .disabled(trimmedName.isEmpty)
                }
            }
        }
    }

    // The name without extra spaces at the start or end
    var trimmedName: String {
        return name.trimmingCharacters(in: .whitespaces)
    }

    // Add the part to the end of the list and close the sheet
    func addPart() {
        let part = Part(name: trimmedName, sortOrder: project.parts.count, copies: copies, plannedRounds: rounds)
        project.parts.append(part)

        // Save now so a force-quit can't lose it
        do {
            try modelContext.save()
        } catch {
            print("Couldn't save part: \(error)")
        }
        dismiss()
    }
}
