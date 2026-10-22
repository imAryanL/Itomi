// One sewing-up step once every part is made, e.g. "Stuff firmly"

import Foundation
import SwiftData

// SwiftData model: saved to the phone automatically
@Model
final class AssemblyStep {
    var id: UUID
    var text: String
    var isDone: Bool
    var sortOrder: Int
    var project: Project?

    init(text: String, sortOrder: Int) {
        self.id = UUID()
        self.text = text
        self.isDone = false
        self.sortOrder = sortOrder
    }
}
