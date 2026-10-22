// Fake projects for checking screens in the simulator (debug builds only, launch with -sampleData)

#if DEBUG
import SwiftUI
import SwiftData

enum SampleData {
    // Fill an empty app with sample projects when launched with -sampleData
    static func addIfAsked(into modelContext: ModelContext, existing: [Project]) {
        if CommandLine.arguments.contains("-sampleData") == false {
            return
        }
        if existing.isEmpty == false {
            return
        }
        addAll(into: modelContext)
    }

    // Add every sample project (also from the Testing button in Settings)
    static func addAll(into modelContext: ModelContext) {
        // In progress
        let bunny = Project(name: "Bunny", hookSize: "3.5 mm", yarn: "Cotton, cream")
        bunny.photo = photo(symbol: "hare.fill", color: .pink)
        addPart(to: bunny, name: "Head", rounds: 22, at: 22)
        // One round left on the Body, so one tap shows "Body done → Next: Ears"
        addPart(to: bunny, name: "Body", rounds: 18, at: 17, stitches: 14)
        addPart(to: bunny, name: "Ears", copies: 2, rounds: 12, at: 0)
        addPart(to: bunny, name: "Arms", copies: 2, rounds: 10, at: 0)
        modelContext.insert(bunny)

        let scarf = Project(name: "Winter scarf", hookSize: "5.0 mm", yarn: "Merino, sage", usesParts: false, countsInRounds: false)
        scarf.usesNeedles = true
        addPart(to: scarf, name: "Winter scarf", rounds: nil, at: 64)
        // Last counted 3 days ago, to show the "Welcome back" line
        scarf.parts.first?.lastCountedAt = Calendar.current.date(byAdding: .day, value: -3, to: Date.now)
        modelContext.insert(scarf)

        // One round left on the last part, to show the "Put it together" checklist
        let teddy = Project(name: "Teddy", hookSize: "3.0 mm", yarn: "Cotton, honey")
        teddy.photo = photo(symbol: "teddybear.fill", color: .brown)
        addPart(to: teddy, name: "Head", rounds: 20, at: 20)
        addPart(to: teddy, name: "Body", rounds: 18, at: 18)
        addPart(to: teddy, name: "Arm", rounds: 10, at: 9)
        modelContext.insert(teddy)

        // Finished (the Kitty has no photo, to show the loop tile)
        let finished: [(String, String?, Color, Int)] = [
            ("Frog", "tortoise.fill", .green, 3),
            ("Whale", "fish.fill", .blue, 12),
            ("Little bird", "bird.fill", .orange, 30),
            ("Kitty", nil, .purple, 45),
        ]
        for (name, symbol, color, daysAgo) in finished {
            let project = Project(name: name, hookSize: "4.0 mm", yarn: "Acrylic")
            if let symbol {
                project.photo = photo(symbol: symbol, color: color)
            }
            addPart(to: project, name: "Body", rounds: 20, at: 20)
            addPart(to: project, name: "Head", rounds: 16, at: 16)
            project.isFinished = true
            project.finishedAt = Calendar.current.date(byAdding: .day, value: -daysAgo, to: Date.now)
            modelContext.insert(project)
        }
        try? modelContext.save()
    }

    // A part already counted up to a round
    static func addPart(to project: Project, name: String, copies: Int = 1, rounds: Int?, at round: Int, stitches: Int = 0) {
        let part = Part(name: name, sortOrder: project.parts.count, copies: copies, plannedRounds: rounds)
        part.currentRound = round
        part.currentStitch = stitches
        if round > 0 {
            part.lastCountedAt = Date.now
        }
        project.parts.append(part)
    }

    // A soft colored square with an animal symbol, standing in for a real photo
    static func photo(symbol: String, color: Color) -> Data? {
        let renderer = ImageRenderer(content:
            ZStack {
                Color.white
                color.opacity(0.25)
                Image(systemName: symbol)
                    .font(.system(size: 160))
                    .foregroundStyle(color)
            }
            .frame(width: 400, height: 400)
        )
        return renderer.uiImage?.jpegData(compressionQuality: 0.8)
    }
}
#endif
