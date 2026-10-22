// Settings: counter options and backing up or restoring projects

import SwiftUI
import SwiftData
import UniformTypeIdentifiers

struct SettingsView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss
    @Query private var allProjects: [Project]

    @AppStorage("hapticsOn") private var hapticsOn = true
    @AppStorage("keepScreenOn") private var keepScreenOn = true

    @State private var backupURL: URL?
    @State private var showingRestorePicker = false
    @State private var restoreMessage: String?

    var body: some View {
        NavigationStack {
            Form {
                Section {
                    Toggle("Haptics", isOn: $hapticsOn)
                    Toggle("Keep screen on while counting", isOn: $keepScreenOn)
                } header: {
                    ListSectionTitle(text: "Counter")
                }

                Section {
                    backupRow
                    Button("Restore from a backup") {
                        showingRestorePicker = true
                        Haptics.light()
                    }
                } header: {
                    ListSectionTitle(text: "Your data")
                } footer: {
                    Text("A backup is one file with all your projects and photos. Save it to Files or send it to yourself.")
                }

                #if DEBUG
                // Only in builds run from Xcode, never in the App Store version
                Section {
                    Button("Add sample projects") {
                        SampleData.addAll(into: modelContext)
                        Haptics.success()
                    }
                } header: {
                    ListSectionTitle(text: "Testing")
                } footer: {
                    Text("Adds Bunny, Winter scarf, Teddy and 4 finished projects. Your own projects stay as they are.")
                }
                #endif

                Section {
                    Text("Itomi \(appVersion)")
                        .font(.footnote)
                        .foregroundStyle(.secondary)
                        .frame(maxWidth: .infinity)
                }
                .listRowBackground(Color.clear)
            }
            .scrollContentBackground(.hidden)
            .background(Color.warmBackground)
            // Tick when a switch changes (turning Haptics off stays quiet)
            .onChange(of: hapticsOn) {
                Haptics.light()
            }
            .onChange(of: keepScreenOn) {
                Haptics.light()
            }
            .navigationTitle("Settings")
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("Done") {
                        Haptics.light()
                        dismiss()
                    }
                }
            }
            // Make the backup file ready for the share sheet
            .task {
                do {
                    backupURL = try Backup.makeFile(projects: allProjects)
                } catch {
                    print("Couldn't make backup: \(error)")
                }
            }
            .fileImporter(isPresented: $showingRestorePicker, allowedContentTypes: [.json]) { result in
                restore(result)
            }
            .alert("Restore", isPresented: showingRestoreMessage) {
                Button("OK") {
                    restoreMessage = nil
                }
            } message: {
                Text(restoreMessage ?? "")
            }
        }
    }

    // "Back up projects" opens the share sheet with the backup file
    @ViewBuilder
    var backupRow: some View {
        if let backupURL {
            ShareLink(item: backupURL) {
                Text("Back up projects")
            }
            .simultaneousGesture(TapGesture().onEnded { Haptics.light() })
        } else {
            Text("Back up projects")
                .foregroundStyle(.secondary)
        }
    }

    // Add the picked backup's projects and say how it went
    func restore(_ result: Result<URL, Error>) {
        switch result {
        case .success(let url):
            do {
                let added = try Backup.restore(from: url, into: modelContext, existing: allProjects)
                Haptics.success()
                if added == 0 {
                    restoreMessage = "Everything in that backup is already here."
                } else if added == 1 {
                    restoreMessage = "Added 1 project."
                } else {
                    restoreMessage = "Added \(added) projects."
                }
            } catch {
                restoreMessage = "That file couldn't be read. Make sure it's an Itomi backup."
            }
        case .failure:
            restoreMessage = "That file couldn't be opened."
        }
    }

    // Shows the alert whenever there's a message
    var showingRestoreMessage: Binding<Bool> {
        Binding(
            get: { restoreMessage != nil },
            set: { isShowing in
                if isShowing == false {
                    restoreMessage = nil
                }
            }
        )
    }

    // e.g. "1.0", from the app's settings
    var appVersion: String {
        let version = Bundle.main.object(forInfoDictionaryKey: "CFBundleShortVersionString") as? String
        return version ?? "1.0"
    }
}
