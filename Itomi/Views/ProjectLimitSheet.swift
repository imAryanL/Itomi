// Shown when + is tapped with 2 projects going on the free plan: finish one, or see Pro

import SwiftUI

struct ProjectLimitSheet: View {
    @Environment(\.dismiss) private var dismiss
    let projectsGoing: Int
    let onSeePro: () -> Void

    var body: some View {
        VStack(spacing: 14) {
            LoopMark(size: 40, color: .accent)
                .frame(width: 64, height: 64)
                .background(Color.cream, in: RoundedRectangle(cornerRadius: 18))
                .padding(.top, 24)

            Text("You have \(projectsGoing) projects going")
                .font(.title2)
                .fontWeight(.heavy)
                .multilineTextAlignment(.center)
            Text("Free includes 2 projects at a time. Finish one to start another, or go Pro for as many as you like.")
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)

            Button {
                Haptics.light()
                onSeePro()
            } label: {
                Text("See Itomi Pro")
                    .font(.headline)
                    .fontWeight(.semibold)
                    .frame(maxWidth: .infinity)
            }
            .buttonStyle(.glassProminent)
            .controlSize(.extraLarge)
            .padding(.top, 6)

            Button("Not now") {
                Haptics.light()
                dismiss()
            }
            .font(.headline)
            .frame(minHeight: 44)
        }
        .padding(.horizontal, 24)
        .padding(.bottom, 8)
        .presentationDetents([.medium])
        .presentationBackground(Color.warmBackground)
    }
}
