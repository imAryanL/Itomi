// Temporary test screen to prove projects save (replaced by the Projects list in milestone 2)

import SwiftUI
import SwiftData

struct ContentView: View {
    @Environment(\.modelContext) private var modelContext
    @Query(sort: \Project.createdAt) private var projects: [Project]

    var body: some View {
        NavigationStack {
            List {
                ForEach(projects) { project in
                    VStack(alignment: .leading) {
                        Text(project.name)
                            .font(.headline)
                        Text(partsSummary(for: project))
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                    }
                }
            }
            .navigationTitle("Saved projects")
            .toolbar {
                Button("Add test project", systemImage: "plus") {
                    addTestProject()
                }
            }
        }
    }

    // Make a Bunny project with three parts and a few stitch targets
    func addTestProject() {
        let project = Project(name: "Bunny \(projects.count + 1)", hookSize: "3.5 mm", yarn: "Cotton")
        modelContext.insert(project)

        let head = Part(name: "Head", sortOrder: 0, plannedRounds: 18)
        let body = Part(name: "Body", sortOrder: 1, plannedRounds: 15)
        let ears = Part(name: "Ears", sortOrder: 2, copies: 2, plannedRounds: 10)
        project.parts.append(head)
        project.parts.append(body)
        project.parts.append(ears)

        // Fill in a sphere start: 6, 12, 18
        head.stitchTargets.append(StitchTarget(round: 1, stitches: 6))
        head.stitchTargets.append(StitchTarget(round: 2, stitches: 12))
        head.stitchTargets.append(StitchTarget(round: 3, stitches: 18))
        head.currentRound = 3

        // Save now so a force-quit can't lose it
        do {
            try modelContext.save()
        } catch {
            print("Couldn't save project: \(error)")
        }
    }

    // e.g. "Head, Body, Ears ×2 · Head on round 3"
    func partsSummary(for project: Project) -> String {
        var names: [String] = []
        for part in project.sortedParts {
            if part.copies > 1 {
                names.append("\(part.name) ×\(part.copies)")
            } else {
                names.append(part.name)
            }
        }
        var summary = names.joined(separator: ", ")
        if let head = project.sortedParts.first {
            summary += " · \(head.name) on round \(head.currentRound)"
        }
        return summary
    }
}

#Preview {
    ContentView()
        .modelContainer(for: Project.self, inMemory: true)
}
