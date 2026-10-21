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
    var isFinished: Bool
    var createdAt: Date
    var finishedAt: Date?

    // Deleting a project also deletes its parts
    @Relationship(deleteRule: .cascade, inverse: \Part.project)
    var parts: [Part] = []

    init(name: String, hookSize: String = "", yarn: String = "", notes: String = "") {
        self.id = UUID()
        self.name = name
        self.photo = nil
        self.hookSize = hookSize
        self.yarn = yarn
        self.notes = notes
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
}
