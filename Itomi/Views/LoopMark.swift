// The Itomi loop: one cream thread looping, used for the icon, launch and placeholders

import SwiftUI

// The loop's path, taken from the 150×150 design drawing and scaled to fit
struct LoopShape: Shape {
    func path(in rect: CGRect) -> Path {
        let scale = min(rect.width, rect.height) / 150

        // Turn a point in the 150×150 drawing into a point in this rect
        func point(_ x: CGFloat, _ y: CGFloat) -> CGPoint {
            return CGPoint(x: rect.minX + x * scale, y: rect.minY + y * scale)
        }

        var path = Path()
        path.move(to: point(30, 112))
        path.addCurve(to: point(102, 85), control1: point(30, 60), control2: point(120, 40))
        path.addCurve(to: point(68, 70), control1: point(88, 120), control2: point(45, 98))
        path.addCurve(to: point(122, 112), control1: point(92, 44), control2: point(126, 66))
        return path
    }
}

// The loop drawn as a thread; progress below 1 draws only part of it (for the launch animation)
struct LoopMark: View {
    let size: CGFloat
    let color: Color
    var progress: CGFloat = 1

    var body: some View {
        LoopShape()
            .trim(from: 0, to: progress)
            .stroke(color, style: StrokeStyle(lineWidth: size * 0.075, lineCap: .round, lineJoin: .round))
            .frame(width: size, height: size)
            .accessibilityHidden(true)
    }
}
