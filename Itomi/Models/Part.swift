// One piece of a project (Head, Body, Ears ×2) with its own counter

import Foundation
import SwiftData

// SwiftData model: saved to the phone automatically
@Model
final class Part {
    var id: UUID
    var name: String
    var sortOrder: Int
    var copies: Int
    var currentCopy: Int
    var plannedRounds: Int?
    var currentRound: Int
    var currentStitch: Int
    var lastCountedAt: Date?
    var project: Project?

    // Undo history: what the counter looked like before each tap (newest last)
    var undoRounds: [Int] = []
    var undoStitches: [Int] = []
    var undoCopies: [Int] = []

    // Deleting a part also deletes its stitch targets
    @Relationship(deleteRule: .cascade, inverse: \StitchTarget.part)
    var stitchTargets: [StitchTarget] = []

    init(name: String, sortOrder: Int, copies: Int = 1, plannedRounds: Int? = nil) {
        self.id = UUID()
        self.name = name
        self.sortOrder = sortOrder
        self.copies = copies
        self.currentCopy = 1
        self.plannedRounds = plannedRounds
        self.currentRound = 0
        self.currentStitch = 0
        self.lastCountedAt = nil
    }

    // MARK: - Counting

    // Add a round and reset stitches
    func addRound() {
        rememberForUndo()
        currentRound += 1
        currentStitch = 0
        lastCountedAt = Date.now
    }

    func addStitch() {
        rememberForUndo()
        currentStitch += 1
        lastCountedAt = Date.now
    }

    func removeStitch() {
        if currentStitch == 0 {
            return
        }
        rememberForUndo()
        currentStitch -= 1
        lastCountedAt = Date.now
    }

    // Move on to the next copy (Ear 1 → Ear 2), starting from round 0
    func startNextCopy() {
        if currentCopy >= copies {
            return
        }
        rememberForUndo()
        currentCopy += 1
        currentRound = 0
        currentStitch = 0
        lastCountedAt = Date.now
    }

    // Save the counter as it is now, keeping the last 50 steps (the three lists always grow together)
    private func rememberForUndo() {
        undoRounds.append(currentRound)
        undoStitches.append(currentStitch)
        undoCopies.append(currentCopy)

        if undoRounds.count > 50 {
            undoRounds.removeFirst()
            undoStitches.removeFirst()
            undoCopies.removeFirst()
        }
    }

    var canUndo: Bool {
        return undoRounds.isEmpty == false
    }

    // Put the counter back to how it was before the last tap
    func undo() {
        if canUndo == false {
            return
        }
        currentRound = undoRounds.removeLast()
        currentStitch = undoStitches.removeLast()
        currentCopy = undoCopies.removeLast()
        lastCountedAt = Date.now
    }

    // MARK: - Status

    // The current copy has reached its planned rounds
    var isCopyFinished: Bool {
        guard let planned = plannedRounds else {
            return false
        }
        return currentRound >= planned
    }

    // Every copy has reached its planned rounds
    var isDone: Bool {
        return isCopyFinished && currentCopy >= copies
    }

    // Name with the number of copies, e.g. "Ears ×2"
    var displayName: String {
        if copies > 1 {
            return "\(name) ×\(copies)"
        } else {
            return name
        }
    }

    // Name with the copy being worked on, e.g. "Ears 1 of 2"
    var currentCopyName: String {
        if copies > 1 {
            return "\(name) \(currentCopy) of \(copies)"
        } else {
            return name
        }
    }

    // "Round" or "Row", taken from the project
    var countWord: String {
        if let project {
            return project.countWord
        }
        return "Round"
    }

    // e.g. "Round 5 of 22" or "Round 5"
    var roundText: String {
        if let planned = plannedRounds {
            return "\(countWord) \(currentRound) of \(planned)"
        }
        return "\(countWord) \(currentRound)"
    }

    // For the parts list, e.g. "Round 5 of 22", "Not started · 18 rounds" or "Done"
    var statusText: String {
        if isDone {
            return "Done"
        }

        if currentRound == 0 && currentCopy == 1 {
            if let planned = plannedRounds {
                return "Not started · \(planned) \(countWord.lowercased())s"
            }
            return "Not started"
        }

        // Show which copy, e.g. "2 of 2 · Round 3 of 10"
        if copies > 1 {
            return "\(currentCopy) of \(copies) · \(roundText)"
        }
        return roundText
    }

    // Rounds counted on this part, including earlier copies
    var roundsCounted: Int {
        let earlierCopies = currentCopy - 1
        let roundsPerCopy = plannedRounds ?? 0
        return earlierCopies * roundsPerCopy + currentRound
    }

    // How far along this part is, from 0 to 1 (counting every copy)
    var progress: Double {
        guard let planned = plannedRounds, planned > 0 else {
            return 0
        }
        let roundsDone = (currentCopy - 1) * planned + min(currentRound, planned)
        let roundsTotal = copies * planned
        return Double(roundsDone) / Double(roundsTotal)
    }

    // Expected stitches for a round, if one was set
    func expectedStitches(forRound round: Int) -> Int? {
        for target in stitchTargets {
            if target.round == round {
                return target.stitches
            }
        }
        return nil
    }

    // The round being worked on now (the counter shows rounds already done)
    var workingRound: Int {
        return currentRound + 1
    }

    // Expected stitches for the round being worked on, if one was set
    var expectedStitchesNow: Int? {
        return expectedStitches(forRound: workingRound)
    }
}
