// What the Lock Screen counter shows (this folder is built into both the app and the widget)

import ActivityKit
import Foundation

// Apple's required Live Activity setup: everything lives in ContentState so one card can switch parts
nonisolated struct CounterActivityAttributes: ActivityAttributes {
    nonisolated struct ContentState: Codable, Hashable {
        var title: String
        var countWord: String
        var round: Int
        var plannedRounds: Int?
        var progress: Double

        // e.g. "Round 6 of 22" or "Row 64"
        var roundText: String {
            if let planned = plannedRounds {
                return "\(countWord) \(round) of \(planned)"
            }
            return "\(countWord) \(round)"
        }
    }
}
