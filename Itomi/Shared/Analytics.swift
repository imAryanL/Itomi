// Anonymous app stats sent to TelemetryDeck (no names, no project details)

import TelemetryDeck

enum Analytics {
    // Only count the first round of each app launch, not every tap
    static var sentRoundCounted = false
    static var sentRoundCountedOutside = false

    // Start TelemetryDeck once at launch (it also counts each app open by itself)
    static func start() {
        let config = TelemetryDeck.Config(appID: "EF41D3DF-24F8-4AF0-8545-03781A36A5B2")
        TelemetryDeck.initialize(config: config)
    }

    // from: "New project", "Onboarding" or "Make another", plus hook or needles, parts or one counter
    static func projectCreated(_ project: Project, from: String) {
        var tool = "Hook"
        if project.usesNeedles {
            tool = "Needles"
        }
        var counter = "One counter"
        if project.usesParts {
            counter = "Parts"
        }
        TelemetryDeck.signal("Project.created", parameters: ["from": from, "tool": tool, "counter": counter])
    }

    static func roundCounted() {
        if sentRoundCounted {
            return
        }
        sentRoundCounted = true
        TelemetryDeck.signal("Counter.roundCounted")
    }

    // A round added from the Lock Screen, Siri, the Action Button or Control Center (once per launch)
    static func roundCountedOutsideApp() {
        if sentRoundCountedOutside {
            return
        }
        sentRoundCountedOutside = true
        TelemetryDeck.signal("Counter.roundCountedOutsideApp")
    }

    // A round's stitches didn't add up
    static func stitchWarningShown() {
        TelemetryDeck.signal("Counter.stitchWarningShown")
    }

    // choice: "Fix stitches" or "Keep going"
    static func stitchWarningAnswered(choice: String) {
        TelemetryDeck.signal("Counter.stitchWarningAnswered", parameters: ["choice": choice])
    }

    // Free plan: tapped + with 2 projects going
    static func projectLimitReached() {
        TelemetryDeck.signal("Pro.projectLimitReached")
    }

    static func projectFinished() {
        TelemetryDeck.signal("Project.finished")
    }

    // from: "Home", "Settings" or "Stitches"
    static func paywallShown(from: String) {
        TelemetryDeck.signal("Pro.paywallShown", parameters: ["from": from])
    }

    // Tapped Get Pro, then backed out of Apple's payment sheet
    static func purchaseCancelled() {
        TelemetryDeck.signal("Pro.purchaseCancelled")
    }

    // plan: "Yearly" or "Lifetime"
    static func proBought(plan: String) {
        TelemetryDeck.signal("Pro.bought", parameters: ["plan": plan])
    }
}
