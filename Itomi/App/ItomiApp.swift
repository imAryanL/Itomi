// App entry point: plays the launch animation, opens the first screen and sets up saving

import SwiftUI
import SwiftData

@main
struct ItomiApp: App {
    @State private var showingLaunch = true
    @State private var proStore = ProStore()
    @AppStorage("theme") private var themeName = Theme.plum.rawValue

    init() {
        RoundedTitles.apply()
        ProStore.configure()
    }

    var body: some Scene {
        WindowGroup {
            ZStack {
                ProjectsView(launchFinished: showingLaunch == false)

                // The loop draws itself on every launch, then fades away
                if showingLaunch {
                    LaunchView {
                        showingLaunch = false
                    }
                    .transition(.opacity)
                }
            }
            .fontDesign(.rounded)
            // Every word a little heavier than iOS's regular, so the app reads sturdy
            .fontWeight(.medium)
            .tint(currentTheme.color)
            .environment(\.themeColor, currentTheme.color)
            .environment(proStore)
            // Load prices and watch for Pro turning on or off
            .task {
                await proStore.start()
            }
        }
        // Save projects (and their parts and stitch targets) on the phone
        .modelContainer(AppData.container)
    }

    // The picked theme for Pro, plum for everyone else
    var currentTheme: Theme {
        if proStore.isPro == false {
            return .plum
        }
        return Theme(rawValue: themeName) ?? .plum
    }
}
