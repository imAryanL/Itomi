// Second onboarding screen: name the first project and start counting

import SwiftUI
import SwiftData

struct FirstProjectView: View {
    @Environment(\.modelContext) private var modelContext
    let onProjectCreated: (Project) -> Void

    @State private var name = ""
    @State private var usesNeedles = false
    @State private var countsInRounds = true

    var body: some View {
        Form {
            Section {
                VStack(alignment: .leading, spacing: 8) {
                    Text("Your first project")
                        .font(.largeTitle)
                        .fontWeight(.bold)
                    Text("What are you working on right now? You can change all of this later.")
                        .foregroundStyle(.secondary)
                }
            }
            .listRowBackground(Color.clear)
            .listRowInsets(EdgeInsets())

            Section("Project name") {
                TextField("Project name", text: $name, prompt: Text("e.g. Bunny"))
            }

            Section("I'm using a") {
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
                Toggle(isOn: $countsInRounds) {
                    Text("Count in rounds")
                    Text("For amigurumi and anything worked in the round")
                }
            }
        }
        .scrollContentBackground(.hidden)
        .background(Color.warmBackground)
        // Tick when the hook/needles choice or switch changes
        .onChange(of: usesNeedles) {
            Haptics.light()
        }
        .onChange(of: countsInRounds) {
            Haptics.light()
        }
        .safeAreaInset(edge: .bottom) {
            Button {
                createProject()
            } label: {
                Text("Start counting")
                    .font(.headline)
                    .fontWeight(.semibold)
                    .frame(maxWidth: .infinity)
            }
            .buttonStyle(.glassProminent)
            .controlSize(.extraLarge)
            .padding(.horizontal)
            .disabled(trimmedName.isEmpty)
        }
    }

    // The name without extra spaces at the start or end
    var trimmedName: String {
        return name.trimmingCharacters(in: .whitespaces)
    }

    // Make a simple one-counter project and hand it back to open its counter
    func createProject() {
        let project = Project(name: trimmedName, hookSize: "4.0 mm", usesParts: false, countsInRounds: countsInRounds)
        project.usesNeedles = usesNeedles
        modelContext.insert(project)
        Analytics.projectCreated(project, from: "Onboarding")

        let onlyPart = Part(name: trimmedName, sortOrder: 0)
        project.parts.append(onlyPart)

        // Save now so a force-quit can't lose it
        do {
            try modelContext.save()
        } catch {
            print("Couldn't save project: \(error)")
        }
        Haptics.success()
        onProjectCreated(project)
    }
}
