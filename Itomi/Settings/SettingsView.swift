// Settings: counter options and backing up or restoring projects

import SwiftUI
import SwiftData
import UniformTypeIdentifiers

struct SettingsView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss
    @Environment(ProStore.self) private var proStore
    @Query private var allProjects: [Project]
    @State private var showingPaywall = false

    @AppStorage("hapticsOn") private var hapticsOn = true
    @AppStorage("keepScreenOn") private var keepScreenOn = true
    @AppStorage("lockScreenCounter") private var lockScreenCounter = true
    @AppStorage("pretendFree") private var pretendFree = false

    @State private var backupURL: URL?
    @State private var showingRestorePicker = false
    @State private var restoreMessage: String?

    var body: some View {
        NavigationStack {
            Form {
                Section {
                    proRow
                }

                Section {
                    appearanceRow
                }

                Section {
                    Toggle("Haptics", isOn: $hapticsOn)
                    Toggle("Keep screen on while counting", isOn: $keepScreenOn)
                    // Pro: the counter card on the Lock Screen and in the Dynamic Island
                    if proStore.isPro {
                        Toggle("Counter on Lock Screen", isOn: $lockScreenCounter)
                    }
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
                    Toggle("Pretend I'm not Pro", isOn: $pretendFree)
                        .onChange(of: pretendFree) {
                            Task {
                                await proStore.refreshPro()
                            }
                        }
                } header: {
                    ListSectionTitle(text: "Testing")
                } footer: {
                    Text("Sample projects adds Bunny, Winter scarf, Teddy and 4 finished projects. Your own projects stay as they are.")
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
            // Turning it off takes the card away now
            .onChange(of: lockScreenCounter) {
                Haptics.light()
                if lockScreenCounter == false {
                    LockScreenCounter.end()
                }
            }
            .navigationTitle("Settings")
            .fullScreenCover(isPresented: $showingPaywall) {
                PaywallView()
            }
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

    // Pro: theme color and app icon; free: shows the PRO badge and opens the paywall
    @ViewBuilder
    var appearanceRow: some View {
        if proStore.isPro {
            NavigationLink {
                AppearanceView()
            } label: {
                Label("Appearance", systemImage: "paintpalette")
            }
            .simultaneousGesture(TapGesture().onEnded { Haptics.light() })
        } else {
            Button {
                showingPaywall = true
                Haptics.light()
            } label: {
                HStack {
                    Label("Appearance", systemImage: "paintpalette")
                        .foregroundStyle(.primary)
                    Spacer()
                    Text("PRO")
                        .font(.caption)
                        .fontWeight(.heavy)
                        .foregroundStyle(.white)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 2)
                        .background(Color.accent, in: Capsule())
                }
                .contentShape(Rectangle())
            }
            .buttonStyle(.plain)
        }
    }

    // Itomi Pro: a thank-you when Pro is on, otherwise opens the paywall
    @ViewBuilder
    var proRow: some View {
        if proStore.isPro {
            HStack(spacing: 14) {
                LoopMark(size: 22, color: .cream)
                    .frame(width: 36, height: 36)
                    .background(Color.accent, in: RoundedRectangle(cornerRadius: 10))
                VStack(alignment: .leading, spacing: 2) {
                    Text("Itomi Pro")
                        .font(.headline)
                        .fontWeight(.semibold)
                    Text("Thank you for supporting Itomi")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                }
            }
            .accessibilityElement(children: .combine)
        } else {
            Button {
                showingPaywall = true
                Haptics.light()
            } label: {
                HStack(spacing: 14) {
                    LoopMark(size: 22, color: .cream)
                        .frame(width: 36, height: 36)
                        .background(Color.accent, in: RoundedRectangle(cornerRadius: 10))
                    VStack(alignment: .leading, spacing: 2) {
                        Text("Itomi Pro")
                            .font(.headline)
                            .fontWeight(.semibold)
                            .foregroundStyle(.primary)
                        Text("Lock Screen counter, unlimited projects and more")
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                    }
                    Spacer()
                    Image(systemName: "chevron.right")
                        .font(.footnote)
                        .fontWeight(.semibold)
                        .foregroundStyle(.tertiary)
                }
                .contentShape(Rectangle())
            }
            .buttonStyle(.plain)
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
