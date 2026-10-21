// Backup file: saves every project to one .json file and reads it back to restore

import Foundation
import SwiftData

// The backup file's layout (plain copies of the models that can be written as JSON)
struct BackupFile: Codable {
    var version: Int
    var createdAt: Date
    var projects: [BackupProject]
}

struct BackupProject: Codable {
    var id: UUID
    var name: String
    var photo: Data?
    var hookSize: String
    var yarn: String
    var notes: String
    var usesParts: Bool
    var countsInRounds: Bool
    var usesNeedles: Bool
    var isFinished: Bool
    var createdAt: Date
    var finishedAt: Date?
    var parts: [BackupPart]
}

struct BackupPart: Codable {
    var id: UUID
    var name: String
    var sortOrder: Int
    var copies: Int
    var currentCopy: Int
    var plannedRounds: Int?
    var currentRound: Int
    var currentStitch: Int
    var lastCountedAt: Date?
    var undoRounds: [Int]
    var undoStitches: [Int]
    var undoCopies: [Int]
    var stitchTargets: [BackupStitchTarget]
}

struct BackupStitchTarget: Codable {
    var id: UUID
    var round: Int
    var stitches: Int
}

enum Backup {
    // MARK: - Making a backup

    // Write every project to a dated .json file and return where it is
    static func makeFile(projects: [Project]) throws -> URL {
        var backupProjects: [BackupProject] = []
        for project in projects {
            backupProjects.append(copy(of: project))
        }
        let file = BackupFile(version: 1, createdAt: Date.now, projects: backupProjects)

        let encoder = JSONEncoder()
        encoder.dateEncodingStrategy = .iso8601
        let data = try encoder.encode(file)

        // e.g. "Itomi backup 2026-10-20.json"
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        let day = formatter.string(from: Date.now)
        let url = FileManager.default.temporaryDirectory.appendingPathComponent("Itomi backup \(day).json")
        try data.write(to: url)
        return url
    }

    static func copy(of project: Project) -> BackupProject {
        var backupParts: [BackupPart] = []
        for part in project.sortedParts {
            var targets: [BackupStitchTarget] = []
            for target in part.stitchTargets {
                targets.append(BackupStitchTarget(id: target.id, round: target.round, stitches: target.stitches))
            }
            backupParts.append(BackupPart(
                id: part.id, name: part.name, sortOrder: part.sortOrder, copies: part.copies,
                currentCopy: part.currentCopy, plannedRounds: part.plannedRounds,
                currentRound: part.currentRound, currentStitch: part.currentStitch,
                lastCountedAt: part.lastCountedAt, undoRounds: part.undoRounds,
                undoStitches: part.undoStitches, undoCopies: part.undoCopies, stitchTargets: targets
            ))
        }
        return BackupProject(
            id: project.id, name: project.name, photo: project.photo, hookSize: project.hookSize,
            yarn: project.yarn, notes: project.notes, usesParts: project.usesParts,
            countsInRounds: project.countsInRounds, usesNeedles: project.usesNeedles,
            isFinished: project.isFinished, createdAt: project.createdAt,
            finishedAt: project.finishedAt, parts: backupParts
        )
    }

    // MARK: - Restoring

    // Add the backup's projects, skipping any already here; returns how many were added
    static func restore(from url: URL, into context: ModelContext, existing: [Project]) throws -> Int {
        // Files picked from the Files app need permission to be read
        let gotAccess = url.startAccessingSecurityScopedResource()
        defer {
            if gotAccess {
                url.stopAccessingSecurityScopedResource()
            }
        }

        let data = try Data(contentsOf: url)
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601
        let file = try decoder.decode(BackupFile.self, from: data)

        // IDs already on this phone, so restoring twice never makes copies
        var existingIDs: Set<UUID> = []
        for project in existing {
            existingIDs.insert(project.id)
        }

        var added = 0
        for saved in file.projects {
            if existingIDs.contains(saved.id) {
                continue
            }
            context.insert(makeProject(from: saved))
            added += 1
        }
        try context.save()
        return added
    }

    static func makeProject(from saved: BackupProject) -> Project {
        let project = Project(name: saved.name, hookSize: saved.hookSize, yarn: saved.yarn, notes: saved.notes,
                              usesParts: saved.usesParts, countsInRounds: saved.countsInRounds)
        project.id = saved.id
        project.photo = saved.photo
        project.usesNeedles = saved.usesNeedles
        project.isFinished = saved.isFinished
        project.createdAt = saved.createdAt
        project.finishedAt = saved.finishedAt

        for savedPart in saved.parts {
            let part = Part(name: savedPart.name, sortOrder: savedPart.sortOrder,
                            copies: savedPart.copies, plannedRounds: savedPart.plannedRounds)
            part.id = savedPart.id
            part.currentCopy = savedPart.currentCopy
            part.currentRound = savedPart.currentRound
            part.currentStitch = savedPart.currentStitch
            part.lastCountedAt = savedPart.lastCountedAt
            part.undoRounds = savedPart.undoRounds
            part.undoStitches = savedPart.undoStitches
            part.undoCopies = savedPart.undoCopies
            for savedTarget in savedPart.stitchTargets {
                let target = StitchTarget(round: savedTarget.round, stitches: savedTarget.stitches)
                target.id = savedTarget.id
                part.stitchTargets.append(target)
            }
            project.parts.append(part)
        }
        return project
    }
}
