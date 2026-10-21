// App entry point: plays the launch animation, opens the first screen and sets up saving

import SwiftUI
import SwiftData

@main
struct ItomiApp: App {
    @State private var showingLaunch = true

    init() {
        RoundedTitles.apply()
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
            .tint(Color.accent)
        }
        // Save projects (and their parts and stitch targets) on the phone
        .modelContainer(for: Project.self)
    }
}
