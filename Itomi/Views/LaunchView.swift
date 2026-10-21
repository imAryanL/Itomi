// Launch screen: the loop draws itself on plum, then fades into the app (about 1.2s)

import SwiftUI

struct LaunchView: View {
    let onFinished: () -> Void

    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    @State private var drawProgress: CGFloat = 0
    @State private var showingName = false

    var body: some View {
        ZStack {
            Color.accent
                .ignoresSafeArea()

            VStack(spacing: 22) {
                LoopMark(size: 160, color: .cream, progress: drawProgress)
                Text("Itomi")
                    .font(.system(size: 40, weight: .heavy, design: .rounded))
                    .foregroundStyle(Color.cream)
                    .opacity(showingName ? 1 : 0)
                    .offset(y: showingName ? 0 : 10)
            }
        }
        .task {
            await play()
        }
    }

    // Draw the loop, show the name, then hand over to the app
    func play() async {
        if reduceMotion {
            // Reduce Motion: show it all at once, no drawing
            drawProgress = 1
            showingName = true
            try? await Task.sleep(for: .seconds(0.6))
        } else {
            withAnimation(.easeInOut(duration: 0.8)) {
                drawProgress = 1
            }
            try? await Task.sleep(for: .seconds(0.6))
            withAnimation(.easeOut(duration: 0.3)) {
                showingName = true
            }
            try? await Task.sleep(for: .seconds(0.6))
        }

        withAnimation(.easeOut(duration: 0.3)) {
            onFinished()
        }
    }
}

#Preview {
    LaunchView(onFinished: {})
}
