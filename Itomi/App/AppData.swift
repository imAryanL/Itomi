// The one place projects are saved, shared by the screens and the Lock Screen buttons

import SwiftData

enum AppData {
    // Same file as before (SwiftData's default), so nothing saved earlier moves
    static let container: ModelContainer = makeContainer()

    static func makeContainer() -> ModelContainer {
        do {
            return try ModelContainer(for: Project.self)
        } catch {
            fatalError("Couldn't open saved projects: \(error)")
        }
    }
}
