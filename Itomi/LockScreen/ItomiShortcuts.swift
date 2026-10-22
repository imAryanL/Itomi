// Siri phrases and the Action Button / Shortcuts entry for "Add a round"

import AppIntents

// Apple's required App Shortcuts setup
struct ItomiShortcuts: AppShortcutsProvider {
    static var appShortcuts: [AppShortcut] {
        AppShortcut(
            intent: AddRoundIntent(),
            phrases: [
                "Add a round in \(.applicationName)",
                "Count a round in \(.applicationName)",
                "Add a row in \(.applicationName)"
            ],
            shortTitle: "Add a round",
            systemImageName: "plus.circle"
        )
    }
}
