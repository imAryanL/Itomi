// "You're Pro now": a thank-you and what just switched on, right after buying

import SwiftUI

struct ProUnlockedView: View {
    let onDone: () -> Void
    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    @State private var drawProgress: CGFloat = 0

    var body: some View {
        // Scrolls at large text sizes; the button stays pinned at the bottom
        ScrollView {
            VStack(alignment: .leading, spacing: 18) {
                LoopMark(size: 54, color: .accent, progress: drawProgress)
                    .frame(width: 84, height: 84)
                    .background(Color.cream, in: RoundedRectangle(cornerRadius: 24))

                Text("You're Pro now")
                    .font(.largeTitle)
                    .fontWeight(.heavy)
                Text("Thank you for supporting Itomi. Here's what's switched on:")
                    .font(.title3)
                    .opacity(0.85)

                VStack(alignment: .leading, spacing: 14) {
                    UnlockedLine(title: "Lock Screen counter", detail: "Start counting and it shows up on your Lock Screen.")
                    UnlockedLine(title: "Stitch checks", detail: "Add stitch counts to a part to turn them on.")
                    UnlockedLine(title: "Unlimited projects", detail: "Start as many as you like.")
                    UnlockedLine(title: "Make another", detail: "Hold a finished project to start a fresh copy.")
                    UnlockedLine(title: "Themes and icons", detail: "Find them in Settings.")
                }
                .padding(.top, 8)
            }
            .padding(24)
            .padding(.top, 40)
            .frame(maxWidth: .infinity, alignment: .leading)
        }
        .safeAreaInset(edge: .bottom) {
            Button {
                Haptics.light()
                onDone()
            } label: {
                Text("Start counting")
                    .font(.headline)
                    .fontWeight(.semibold)
                    .foregroundStyle(Color.accent)
                    .frame(maxWidth: .infinity)
            }
            .buttonStyle(.glassProminent)
            .tint(.white)
            .controlSize(.extraLarge)
            .padding(.horizontal, 24)
            .padding(.bottom, 8)
        }
        .foregroundStyle(.white)
        .background(Color.accent)
        .onAppear {
            if reduceMotion {
                drawProgress = 1
            } else {
                withAnimation(.easeInOut(duration: 1.0)) {
                    drawProgress = 1
                }
            }
        }
    }
}

// One switched-on feature: cream check, title and a short how-to
struct UnlockedLine: View {
    let title: String
    let detail: String

    var body: some View {
        HStack(alignment: .top, spacing: 12) {
            Image(systemName: "checkmark")
                .font(.footnote)
                .fontWeight(.black)
                .foregroundStyle(Color.accent)
                .frame(width: 28, height: 28)
                .background(Color.cream, in: Circle())
            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .font(.headline)
                    .fontWeight(.bold)
                Text(detail)
                    .font(.subheadline)
                    .opacity(0.8)
                    .fixedSize(horizontal: false, vertical: true)
            }
        }
        .accessibilityElement(children: .combine)
    }
}
