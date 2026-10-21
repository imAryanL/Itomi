// How many stitches a round should end with (used by the Pro stitch warning)

import Foundation
import SwiftData

// SwiftData model: saved to the phone automatically
@Model
final class StitchTarget {
    var id: UUID
    var round: Int
    var stitches: Int
    var part: Part?

    init(round: Int, stitches: Int) {
        self.id = UUID()
        self.round = round
        self.stitches = stitches
    }
}
