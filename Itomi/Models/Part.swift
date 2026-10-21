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
    var project: Project?

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
}
