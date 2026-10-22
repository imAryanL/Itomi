// Buzzes for taps around the app, all turned off by the Haptics setting

import UIKit

enum Haptics {
    // Strongest buzz, for adding a round
    static func heavy() {
        play(.heavy)
    }

    // For adding a stitch and undo
    static func medium() {
        play(.medium)
    }

    // Small tick for every other button
    static func light() {
        play(.light)
    }

    // Double buzz for finishing something
    static func success() {
        if isOn == false {
            return
        }
        UINotificationFeedbackGenerator().notificationOccurred(.success)
    }

    // Gentle "hmm" buzz when a round's stitches don't add up
    static func warning() {
        if isOn == false {
            return
        }
        UINotificationFeedbackGenerator().notificationOccurred(.warning)
    }

    static func play(_ style: UIImpactFeedbackGenerator.FeedbackStyle) {
        if isOn == false {
            return
        }
        UIImpactFeedbackGenerator(style: style).impactOccurred()
    }

    // The Haptics toggle in Settings, on until it's turned off
    static var isOn: Bool {
        if UserDefaults.standard.object(forKey: "hapticsOn") == nil {
            return true
        }
        return UserDefaults.standard.bool(forKey: "hapticsOn")
    }
}
