// Sheet for adding a part to a project (or editing one): name, copies, rounds and stitches per round

import SwiftUI
import SwiftData

struct AddPartSheet: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss
    @Environment(ProStore.self) private var proStore

    let project: Project

    // Set when editing an existing part instead of adding a new one
    var partToEdit: Part?

    @State private var name = ""
    @State private var copies = 1
    @State private var rounds = 10
    @State private var showingPaywall = false

    // Expected stitches for each round (index 0 is round 1), nil when not set
    @State private var stitches: [Int?] = Array(repeating: nil, count: 10)

    // Start with the part's details filled in when editing
    init(project: Project, partToEdit: Part? = nil) {
        self.project = project
        self.partToEdit = partToEdit
        if let part = partToEdit {
            let plannedRounds = part.plannedRounds ?? 10
            var savedStitches: [Int?] = Array(repeating: nil, count: plannedRounds)
            for target in part.stitchTargets {
                if target.round >= 1 && target.round <= plannedRounds {
                    savedStitches[target.round - 1] = target.stitches
                }
            }
            _name = State(initialValue: part.name)
            _copies = State(initialValue: part.copies)
            _rounds = State(initialValue: plannedRounds)
            _stitches = State(initialValue: savedStitches)
        }
    }

    var body: some View {
        NavigationStack {
            Form {
                Section {
                    LabeledContent("Name") {
                        TextField("Name", text: $name, prompt: Text("e.g. Head"))
                            .multilineTextAlignment(.trailing)
                    }
                    Stepper(value: $copies, in: 1...20) {
                        LabeledContent("Make", value: "×\(copies)")
                    }
                    Stepper(value: $rounds, in: 1...500) {
                        LabeledContent("\(project.countWord)s", value: "\(rounds)")
                    }
                }

                if proStore.isPro {
                    stitchesSection
                } else {
                    lockedStitchesSection
                }
            }
            .scrollContentBackground(.hidden)
            .background(Color.warmBackground)
            // Tick on every stepper tap
            .onChange(of: copies) {
                Haptics.light()
            }
            .onChange(of: rounds) {
                Haptics.light()
                fitStitchesToRounds()
            }
            .navigationTitle(partToEdit == nil ? "Add a part" : "Edit part")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        Haptics.light()
                        dismiss()
                    }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button(partToEdit == nil ? "Add" : "Save") {
                        savePart()
                    }
                    .disabled(trimmedName.isEmpty)
                }
            }
            .fullScreenCover(isPresented: $showingPaywall) {
                PaywallView(openedFrom: "Stitches")
            }
        }
    }

    // Pro: one row per round to type the expected stitches, plus the sphere helper
    var stitchesSection: some View {
        Section {
            Button("Fill in a sphere: 6, 12, 18…", systemImage: "circle.dotted") {
                fillInSphere()
            }
            .fontWeight(.semibold)

            ForEach(0..<rounds, id: \.self) { index in
                LabeledContent("\(project.countWord) \(index + 1)") {
                    TextField("Stitches", value: $stitches[index], format: .number, prompt: Text("–"))
                        .keyboardType(.numberPad)
                        .multilineTextAlignment(.trailing)
                        .fontWeight(.bold)
                }
            }

            if hasAnyStitches {
                Button("Clear stitches", role: .destructive) {
                    clearStitches()
                }
            }
        } header: {
            stitchesHeader
        } footer: {
            Text("Itomi checks your stitch count when you finish each \(project.countWord.lowercased()).")
        }
    }

    // Free: the same section, but tapping it opens Itomi Pro
    var lockedStitchesSection: some View {
        Section {
            Button {
                Haptics.light()
                showingPaywall = true
            } label: {
                HStack {
                    Label("Set stitches for each \(project.countWord.lowercased())", systemImage: "lock.fill")
                    Spacer()
                    Image(systemName: "chevron.right")
                        .font(.footnote)
                        .fontWeight(.semibold)
                        .foregroundStyle(.tertiary)
                }
                .contentShape(Rectangle())
            }
            .buttonStyle(.plain)
        } header: {
            stitchesHeader
        } footer: {
            Text("Get a heads-up when a \(project.countWord.lowercased()) doesn't add up.")
        }
    }

    // "Stitches per round", with a small plum PRO badge on the free plan only
    var stitchesHeader: some View {
        HStack {
            ListSectionTitle(text: "Stitches per \(project.countWord.lowercased())")
            Spacer()
            if proStore.isPro == false {
                Text("PRO")
                    .font(.caption)
                    .fontWeight(.heavy)
                    .foregroundStyle(.white)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 2)
                    .background(Color.accent, in: Capsule())
            }
        }
    }

    // The name without extra spaces at the start or end
    var trimmedName: String {
        return name.trimmingCharacters(in: .whitespaces)
    }

    var hasAnyStitches: Bool {
        for value in stitches {
            if value != nil {
                return true
            }
        }
        return false
    }

    // Keep one stitch box per round when the rounds change
    func fitStitchesToRounds() {
        while stitches.count < rounds {
            stitches.append(nil)
        }
        while stitches.count > rounds {
            stitches.removeLast()
        }
    }

    // Grow by 6 each round, stay even through the middle, then shrink by 6 back down
    func fillInSphere() {
        var increaseRounds = (rounds + 1) / 3
        if increaseRounds < 1 {
            increaseRounds = 1
        }
        let decreaseRounds = max(0, min(increaseRounds - 1, rounds - increaseRounds))
        let widest = increaseRounds * 6

        var newStitches: [Int?] = []
        for round in 1...rounds {
            if round <= increaseRounds {
                newStitches.append(round * 6)
            } else if round > rounds - decreaseRounds {
                let roundsFromEnd = rounds - round
                newStitches.append((roundsFromEnd + 1) * 6)
            } else {
                newStitches.append(widest)
            }
        }
        stitches = newStitches
        Haptics.medium()
    }

    func clearStitches() {
        stitches = Array(repeating: nil, count: rounds)
        Haptics.light()
    }

    // Add the new part (or update the edited one) and close the sheet
    func savePart() {
        let part: Part
        if let existing = partToEdit {
            part = existing
            part.name = trimmedName
            part.copies = copies
            part.plannedRounds = rounds
            // Fewer copies than the one being worked on: go back to the last copy
            if part.currentCopy > copies {
                part.currentCopy = copies
            }
        } else {
            part = Part(name: trimmedName, sortOrder: project.parts.count, copies: copies, plannedRounds: rounds)
            project.parts.append(part)
        }

        saveStitchTargets(for: part)

        // Save now so a force-quit can't lose it
        do {
            try modelContext.save()
        } catch {
            print("Couldn't save part: \(error)")
        }
        Haptics.success()
        dismiss()
    }

    // Swap the part's old stitch targets for the ones typed in (free users keep theirs as they are)
    func saveStitchTargets(for part: Part) {
        if proStore.isPro == false {
            return
        }

        for target in part.stitchTargets {
            modelContext.delete(target)
        }
        part.stitchTargets = []

        for index in 0..<stitches.count {
            if let value = stitches[index], value > 0 {
                part.stitchTargets.append(StitchTarget(round: index + 1, stitches: value))
            }
        }
    }
}
