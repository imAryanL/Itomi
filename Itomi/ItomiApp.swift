// App entry point: opens the first screen and sets up saving

import SwiftUI
import SwiftData

@main
struct ItomiApp: App {
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
        // Save projects (and their parts and stitch targets) on the phone
        .modelContainer(for: Project.self)
    }
}
