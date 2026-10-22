// "Add a round" and "Undo" for the Lock Screen buttons, Siri and the Action Button

import AppIntents
import Foundation

// Apple's required App Intent setup: built into both targets, but the counting only runs inside the app
nonisolated struct AddRoundIntent: LiveActivityIntent {
    static let title: LocalizedStringResource = "Add a round"
    static let description = IntentDescription("Adds a round to the part you're counting in Itomi.")

    func perform() async throws -> some IntentResult & ProvidesDialog {
        #if WIDGET_EXTENSION
        return .result(dialog: "")
        #else
        let message = await LockScreenCounter.addRound()
        return .result(dialog: IntentDialog(stringLiteral: message))
        #endif
    }
}

nonisolated struct UndoRoundIntent: LiveActivityIntent {
    static let title: LocalizedStringResource = "Undo the last count"
    static let isDiscoverable = false

    func perform() async throws -> some IntentResult {
        #if !WIDGET_EXTENSION
        await LockScreenCounter.undo()
        #endif
        return .result()
    }
}
