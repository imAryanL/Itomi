// Shown in place of the round card when a part hits its last round: "Head done → Next: Body"

import SwiftUI

struct PartDoneCard: View {
    let part: Part
    let nextPart: Part?
    let onNext: () -> Void
    let onFinish: () -> Void
    let onKeepCounting: () -> Void

    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    @State private var drawProgress: CGFloat = 0
    @State private var loopOpacity: Double = 0
    @State private var acceptsTaps = false

    var body: some View {
        VStack(spacing: 20) {
            Spacer()

            LoopMark(size: 120, color: .cream, progress: drawProgress)
                .opacity(loopOpacity)

            VStack(spacing: 6) {
                Text("\(part.name) done")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                    .multilineTextAlignment(.center)
                Text(subtitle)
                    .font(.title3)
                    .opacity(0.8)
                    .multilineTextAlignment(.center)
            }

            Spacer()

            // Go to the next part, or finish when every part is done
            Button {
                if acceptsTaps == false {
                    return
                }
                if nextPart != nil {
                    onNext()
                } else {
                    onFinish()
                }
            } label: {
                Text(buttonTitle)
                    .font(.headline)
                    .fontWeight(.semibold)
                    .foregroundStyle(Color.accent)
                    .frame(maxWidth: .infinity)
            }
            .buttonStyle(.glassProminent)
            .tint(.white)
            .controlSize(.extraLarge)

            Button("Keep counting") {
                if acceptsTaps == false {
                    return
                }
                onKeepCounting()
            }
            .font(.headline)
            .foregroundStyle(.white)
            .frame(minHeight: 44)
        }
        .foregroundStyle(.white)
        .padding(24)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color.accent, in: RoundedRectangle(cornerRadius: 32))
        .onAppear {
            playLoop()
            announce()
        }
        // Ignore taps for a moment, so a quick extra count-tap can't press Next or Finish
        .task {
            try? await Task.sleep(for: .seconds(0.4))
            acceptsTaps = true
        }
    }

    // "Next: Body" or "Finish project"
    var buttonTitle: String {
        if let nextPart {
            return "Next: \(nextPart.name)"
        }
        return "Finish project"
    }

    // e.g. "Every round counted" or "All parts done"
    var subtitle: String {
        if nextPart == nil {
            return "All parts done"
        }
        if part.copies == 2 {
            return "Both made"
        }
        if part.copies > 2 {
            return "All \(part.copies) made"
        }
        return "Every \(part.countWord.lowercased()) counted"
    }

    // Draw the loop, or just fade it in with Reduce Motion on
    func playLoop() {
        if reduceMotion {
            drawProgress = 1
            withAnimation(.easeOut(duration: 0.4)) {
                loopOpacity = 1
            }
        } else {
            loopOpacity = 1
            withAnimation(.easeInOut(duration: 1.0)) {
                drawProgress = 1
            }
        }
    }

    // Tell VoiceOver what just happened
    func announce() {
        var message = "\(part.name) done."
        if let nextPart {
            message += " Next: \(nextPart.name)."
        } else {
            message += " All parts done."
        }
        AccessibilityNotification.Announcement(message).post()
    }
}
