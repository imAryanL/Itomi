// Pro Lock Screen counter: shows, updates and ends the card, and counts for its buttons and Siri

import ActivityKit
import Foundation
import SwiftData

enum LockScreenCounter {
    // The Settings switch, on until it's turned off
    static var isOn: Bool {
        if UserDefaults.standard.object(forKey: "lockScreenCounter") == nil {
            return true
        }
        return UserDefaults.standard.bool(forKey: "lockScreenCounter")
    }

    // Only a copy of ProStore's answer, refreshed every time the app opens (works when woken in the background)
    static var isPro: Bool {
        return UserDefaults.standard.bool(forKey: "isPro")
    }

    // The part on the Lock Screen right now
    static var shownPartID: String? {
        return UserDefaults.standard.string(forKey: "lockScreenPartID")
    }

    // Cards asked to end that iOS hasn't finished taking away yet
    static var endingCardIDs: Set<String> = []

    // MARK: - The card

    // Put this part on the Lock Screen (or take the card away when it's done)
    static func show(_ part: Part) {
        if isPro == false || isOn == false {
            end()
            return
        }
        // A finished project never goes on the Lock Screen (finishing ends its card)
        if part.project?.isFinished == true {
            return
        }

        let content = ActivityContent(state: makeState(for: part), staleDate: nil)

        // The part is done: leave its last round showing for 10 minutes, then go
        if part.isDone {
            // Only this part's card, so peeking at a done part leaves another part's card alone
            if part.id.uuidString != shownPartID {
                return
            }
            for activity in liveCards() {
                endingCardIDs.insert(activity.id)
                Task {
                    await activity.end(content, dismissalPolicy: .after(Date.now.addingTimeInterval(10 * 60)))
                }
            }
            return
        }

        UserDefaults.standard.set(part.id.uuidString, forKey: "lockScreenPartID")

        // Update the card that's there, or start one
        let activities = liveCards()
        if activities.isEmpty {
            if ActivityAuthorizationInfo().areActivitiesEnabled == false {
                return
            }
            // This fails if the app is in the background (Siri); the count is still saved
            do {
                _ = try Activity.request(attributes: CounterActivityAttributes(), content: content)
            } catch {
                print("Couldn't start the Lock Screen counter: \(error)")
            }
        } else {
            for activity in activities {
                Task {
                    await activity.update(content)
                }
            }
        }
    }

    // Cards still counting (a finished card can linger on screen for a while)
    static func liveCards() -> [Activity<CounterActivityAttributes>] {
        var cards: [Activity<CounterActivityAttributes>] = []
        for activity in Activity<CounterActivityAttributes>.activities {
            if endingCardIDs.contains(activity.id) {
                continue
            }
            if activity.activityState == .active || activity.activityState == .stale {
                cards.append(activity)
            }
        }
        return cards
    }

    // Take the card off the Lock Screen
    static func end() {
        for activity in Activity<CounterActivityAttributes>.activities {
            endingCardIDs.insert(activity.id)
            Task {
                await activity.end(nil, dismissalPolicy: .immediate)
            }
        }
        UserDefaults.standard.removeObject(forKey: "lockScreenPartID")
    }

    // A project was finished or deleted: end the card if it shows one of its parts
    static func projectEnded(_ project: Project) {
        for part in project.parts {
            if part.id.uuidString == shownPartID {
                end()
                return
            }
        }
    }

    // e.g. "Bunny · Head", "Round 6 of 22" and how far along the part is
    static func makeState(for part: Part) -> CounterActivityAttributes.ContentState {
        var title = part.currentCopyName
        if let project = part.project {
            if project.usesParts {
                title = "\(project.name) · \(part.currentCopyName)"
            } else {
                title = project.name
            }
        }
        return CounterActivityAttributes.ContentState(
            title: title,
            countWord: part.countWord,
            round: part.currentRound,
            plannedRounds: part.plannedRounds,
            progress: part.progress
        )
    }

    // MARK: - Counting from the Lock Screen and Siri

    // Lock Screen +, Siri or the Action Button; returns what Siri says back
    static func addRound() -> String {
        if isPro == false {
            return "Counting with Siri is part of Itomi Pro."
        }
        guard let part = partToCount() else {
            return "Open a project in Itomi to start counting."
        }
        if part.isDone {
            return "\(part.name) is done. Open Itomi to start the next part."
        }
        part.addRound()
        save()
        show(part)
        Analytics.roundCountedOutsideApp()
        return "\(part.currentCopyName), \(part.roundText)"
    }

    // Lock Screen Undo: put the part back to how it was before the last tap
    static func undo() {
        if isPro == false {
            return
        }
        guard let part = partToCount() else {
            return
        }
        part.undo()
        save()
        show(part)
    }

    // The part on the Lock Screen, or else the part counted most recently
    static func partToCount() -> Part? {
        let context = AppData.container.mainContext
        var parts: [Part] = []
        do {
            parts = try context.fetch(FetchDescriptor<Part>())
        } catch {
            print("Couldn't load parts: \(error)")
            return nil
        }

        for part in parts {
            if part.id.uuidString == shownPartID && part.project?.isFinished == false {
                return part
            }
        }

        var latest: Part? = nil
        for part in parts {
            guard let counted = part.lastCountedAt, part.project?.isFinished == false else {
                continue
            }
            if let latestDate = latest?.lastCountedAt {
                if counted > latestDate {
                    latest = part
                }
            } else {
                latest = part
            }
        }
        return latest
    }

    // Save straight away, the same as a tap in the app
    static func save() {
        do {
            try AppData.container.mainContext.save()
        } catch {
            print("Couldn't save count: \(error)")
        }
    }
}
