// Shown when a project is finished: a few numbers and a nudge to add a photo

import SwiftUI
import SwiftData
import PhotosUI

struct FinishView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss

    let project: Project
    @State private var pickedPhoto: PhotosPickerItem?

    var body: some View {
        VStack(spacing: 24) {
            Spacer()

            if project.photo != nil {
                ProjectThumbnail(project: project, size: 160)
            } else {
                LoopMark(size: 110, color: .cream)
                    .frame(width: 160, height: 160)
                    .background(Color.accent, in: RoundedRectangle(cornerRadius: 40))
            }

            VStack(spacing: 8) {
                Text("\(project.name) is finished")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                    .multilineTextAlignment(.center)
                Text("Every \(project.countWord.lowercased()) counted. Time to show it off.")
                    .foregroundStyle(.secondary)
                    .multilineTextAlignment(.center)
            }

            HStack(spacing: 12) {
                if project.usesParts {
                    StatTile(number: project.piecesMade, label: wordFor(project.piecesMade, "part"))
                }
                StatTile(number: project.roundsCounted, label: wordFor(project.roundsCounted, project.countWord.lowercased()))
                StatTile(number: project.daysTaken, label: wordFor(project.daysTaken, "day"))
            }

            Spacer()

            PhotosPicker(selection: $pickedPhoto, matching: .images) {
                if project.photo == nil {
                    Label("Add a photo of it", systemImage: "camera")
                        .font(.headline)
                        .fontWeight(.semibold)
                        .frame(maxWidth: .infinity)
                } else {
                    Label("Change photo", systemImage: "camera")
                        .font(.headline)
                        .fontWeight(.semibold)
                        .frame(maxWidth: .infinity)
                }
            }
            .buttonStyle(.glassProminent)
            .controlSize(.extraLarge)
            .simultaneousGesture(TapGesture().onEnded { Haptics.light() })

            Button("Done") {
                Haptics.light()
                dismiss()
            }
            .font(.headline)
            .fontWeight(.semibold)
            .controlSize(.large)
        }
        .padding()
        .background(Color.warmBackground)
        // Save a newly picked photo
        .onChange(of: pickedPhoto) {
            guard let item = pickedPhoto else {
                return
            }
            Task {
                if let data = await PhotoShrinker.load(item) {
                    project.photo = data
                    saveChanges()
                }
            }
        }
    }

    // "1 day" but "18 days"
    func wordFor(_ count: Int, _ word: String) -> String {
        if count == 1 {
            return word
        } else {
            return word + "s"
        }
    }

    func saveChanges() {
        do {
            try modelContext.save()
        } catch {
            print("Couldn't save photo: \(error)")
        }
    }
}

// One number with a label under it, e.g. "96 rounds"
struct StatTile: View {
    let number: Int
    let label: String

    var body: some View {
        VStack(spacing: 2) {
            Text("\(number)")
                .font(.title)
                .fontWeight(.bold)
                .foregroundStyle(.tint)
            Text(label)
                .font(.subheadline)
                .foregroundStyle(.secondary)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 16)
        .background(.background, in: RoundedRectangle(cornerRadius: 20))
        .accessibilityElement(children: .combine)
    }
}
