// "+ Round" button for Control Center and the Lock Screen corners (Pro)

import AppIntents
import SwiftUI
import WidgetKit

// Apple's required Control Center setup: one button that runs the same "Add a round" as Siri
struct CounterControl: ControlWidget {
    var body: some ControlWidgetConfiguration {
        StaticControlConfiguration(kind: "com.aryan.Itomi.addRound") {
            ControlWidgetButton(action: AddRoundIntent()) {
                Label("Add a round", systemImage: "plus.circle.fill")
            }
        }
        .displayName("Add a round")
        .description("Adds a round to the part you're counting in Itomi.")
    }
}
