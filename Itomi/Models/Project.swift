// One crochet or knit project and everything saved about it

import Foundation
import SwiftData

// SwiftData model: saved to the phone automatically
@Model
final class Project {
    var id: UUID
    var name: String
    @Attribute(.externalStorage) var photo: Data?
    var hookSize: String
    var yarn: String
    var notes: String
    var usesParts: Bool
    var countsInRounds: Bool
    var usesNeedles: Bool = false
    var isFinished: Bool
    var createdAt: Date
    var finishedAt: Date?

    // Deleting a project also deletes its parts
    @Relationship(deleteRule: .cascade, inverse: \Part.project)
    var parts: [Part] = []

    init(name: String, hookSize: String = "", yarn: String = "", notes: String = "", usesParts: Bool = true, countsInRounds: Bool = true) {
        self.id = UUID()
        self.name = name
        self.photo = nil
        self.hookSize = hookSize
        self.yarn = yarn
        self.notes = notes
        self.usesParts = usesParts
        self.countsInRounds = countsInRounds
        self.isFinished = false
        self.createdAt = Date.now
        self.finishedAt = nil
    }

    // Parts in the order they were added (SwiftData doesn't keep order on its own)
    var sortedParts: [Part] {
        return parts.sorted { first, second in
            first.sortOrder < second.sortOrder
        }
    }

    // e.g. "4.0 mm hook" or "4.0 mm needles"
    var toolText: String {
        if usesNeedles {
            return "\(hookSize) needles"
        } else {
            return "\(hookSize) hook"
        }
    }

    // "Round" or "Row", depending on how this project counts
    var countWord: String {
        if countsInRounds {
            return "Round"
        } else {
            return "Row"
        }
    }

    // MARK: - Finish screen numbers

    // Every piece made, counting copies (Ears ×2 counts as 2)
    var piecesMade: Int {
        var total = 0
        for part in parts {
            total += part.copies
        }
        return total
    }

    // Every round counted across all parts and copies
    var roundsCounted: Int {
        var total = 0
        for part in parts {
            total += part.roundsCounted
        }
        return total
    }

    // Calendar days from starting to finishing, counting both days
    var daysTaken: Int {
        let endDate = finishedAt ?? Date.now
        let calendar = Calendar.current
        let start = calendar.startOfDay(for: createdAt)
        let end = calendar.startOfDay(for: endDate)
        let days = calendar.dateComponents([.day], from: start, to: end).day ?? 0
        return days + 1
    }

    // MARK: - Progress

    // When any part of this project was last counted
    var lastCountedAt: Date? {
        var latest: Date? = nil
        for part in parts {
            guard let countedAt = part.lastCountedAt else {
                continue
            }
            if let current = latest {
                if countedAt > current {
                    latest = countedAt
                }
            } else {
                latest = countedAt
            }
        }
        return latest
    }

    // The part to pick up from: the last one counted (unless it's done), else the first one not done
    var currentPart: Part? {
        var lastCounted: Part? = nil
        var latestDate = Date.distantPast
        for part in parts {
            if let countedAt = part.lastCountedAt, countedAt > latestDate {
                latestDate = countedAt
                lastCounted = part
            }
        }
        if let lastCounted, lastCounted.isDone == false {
            return lastCounted
        }

        for part in sortedParts {
            if part.isDone == false {
                return part
            }
        }

        // Everything is done: show the last part counted
        if let lastCounted {
            return lastCounted
        }
        return sortedParts.first
    }

    // Short progress line for the Projects list, e.g. "Head · Round 5 of 22"
    var progressSummary: String {
        guard let part = currentPart else {
            return "No parts yet"
        }
        if part.lastCountedAt == nil {
            // Earlier parts are done, this one is next
            if usesParts && part != sortedParts.first {
                return "Up next: \(part.currentCopyName)"
            }
            return "Not started"
        }
        if usesParts {
            return "\(part.currentCopyName) · \(part.roundText)"
        }
        return part.roundText
    }
}
