// Extra app icon drawings for Pro (the loop stays the main icon), drawn on the same 150×150 grid as LoopShape

import SwiftUI

enum IconDrawing: String, CaseIterable, Identifiable {
    case loop, doubleLoop, chainStitch, yarnBall, heart, hook

    var id: String {
        return rawValue
    }

    var name: String {
        switch self {
        case .loop:
            return "Loop"
        case .doubleLoop:
            return "Double loop"
        case .chainStitch:
            return "Chain stitch"
        case .yarnBall:
            return "Yarn ball"
        case .heart:
            return "Heart"
        case .hook:
            return "Hook"
        }
    }

    // The part of the icon's asset name, e.g. "AppIcon-DoubleLoop-Rose" (nil for the main loop)
    var assetName: String? {
        switch self {
        case .loop:
            return nil
        case .doubleLoop:
            return "DoubleLoop"
        case .chainStitch:
            return "ChainStitch"
        case .yarnBall:
            return "YarnBall"
        case .heart:
            return "Heart"
        case .hook:
            return "Hook"
        }
    }

    // Thread thickness on the 150×150 grid
    var lineWidth: CGFloat {
        switch self {
        case .loop:
            return 11.25
        case .doubleLoop, .heart:
            return 10
        case .chainStitch:
            return 8.5
        case .yarnBall:
            return 8
        case .hook:
            return 9
        }
    }

    // The drawing on the 150×150 grid
    var gridPath: Path {
        var path = Path()
        switch self {
        case .loop:
            path = LoopShape().path(in: CGRect(x: 0, y: 0, width: 150, height: 150))

        case .doubleLoop:
            path.move(to: CGPoint(x: 16, y: 112))
            path.addCurve(to: CGPoint(x: 62, y: 56), control1: CGPoint(x: 44, y: 110), control2: CGPoint(x: 62, y: 78))
            path.addCurve(to: CGPoint(x: 40, y: 57), control1: CGPoint(x: 62, y: 34), control2: CGPoint(x: 40, y: 34))
            path.addCurve(to: CGPoint(x: 72, y: 110), control1: CGPoint(x: 40, y: 86), control2: CGPoint(x: 50, y: 110))
            path.addCurve(to: CGPoint(x: 112, y: 56), control1: CGPoint(x: 98, y: 110), control2: CGPoint(x: 112, y: 78))
            path.addCurve(to: CGPoint(x: 90, y: 57), control1: CGPoint(x: 112, y: 34), control2: CGPoint(x: 90, y: 34))
            path.addCurve(to: CGPoint(x: 134, y: 112), control1: CGPoint(x: 90, y: 86), control2: CGPoint(x: 100, y: 112))

        case .chainStitch:
            // Three linked loops going down at an angle, with a tail at each end
            for center in [CGPoint(x: 50, y: 50), CGPoint(x: 75, y: 75), CGPoint(x: 100, y: 100)] {
                let oval = Path(ellipseIn: CGRect(x: -20, y: -13, width: 40, height: 26))
                let turnAndMove = CGAffineTransform(translationX: center.x, y: center.y).rotated(by: .pi / 4)
                path.addPath(oval, transform: turnAndMove)
            }
            path.move(to: CGPoint(x: 35.9, y: 35.9))
            path.addCurve(to: CGPoint(x: 18, y: 26), control1: CGPoint(x: 28, y: 28), control2: CGPoint(x: 24, y: 34))
            path.move(to: CGPoint(x: 114.1, y: 114.1))
            path.addCurve(to: CGPoint(x: 134, y: 126), control1: CGPoint(x: 122, y: 122), control2: CGPoint(x: 128, y: 118))

        case .yarnBall:
            // The ball, three wraps of yarn, then the tail running off
            path.addEllipse(in: CGRect(x: 37, y: 28, width: 76, height: 76))
            path.move(to: CGPoint(x: 43, y: 48))
            path.addCurve(to: CGPoint(x: 77, y: 104), control1: CGPoint(x: 67, y: 58), control2: CGPoint(x: 81, y: 82))
            path.move(to: CGPoint(x: 57, y: 32))
            path.addCurve(to: CGPoint(x: 101, y: 100), control1: CGPoint(x: 85, y: 44), control2: CGPoint(x: 103, y: 72))
            path.move(to: CGPoint(x: 97, y: 34))
            path.addCurve(to: CGPoint(x: 113, y: 72), control1: CGPoint(x: 109, y: 48), control2: CGPoint(x: 113, y: 60))
            path.move(to: CGPoint(x: 48, y: 93))
            path.addCurve(to: CGPoint(x: 76, y: 124), control1: CGPoint(x: 36, y: 112), control2: CGPoint(x: 52, y: 128))
            path.addCurve(to: CGPoint(x: 134, y: 128), control1: CGPoint(x: 98, y: 120), control2: CGPoint(x: 116, y: 126))

        case .heart:
            path.move(to: CGPoint(x: 16, y: 126))
            path.addCurve(to: CGPoint(x: 75, y: 114), control1: CGPoint(x: 40, y: 126), control2: CGPoint(x: 60, y: 122))
            path.addCurve(to: CGPoint(x: 34, y: 54), control1: CGPoint(x: 44, y: 92), control2: CGPoint(x: 26, y: 72))
            path.addCurve(to: CGPoint(x: 75, y: 58), control1: CGPoint(x: 42, y: 36), control2: CGPoint(x: 68, y: 36))
            path.addCurve(to: CGPoint(x: 116, y: 54), control1: CGPoint(x: 82, y: 36), control2: CGPoint(x: 108, y: 36))
            path.addCurve(to: CGPoint(x: 75, y: 114), control1: CGPoint(x: 124, y: 72), control2: CGPoint(x: 106, y: 92))
            path.addCurve(to: CGPoint(x: 134, y: 126), control1: CGPoint(x: 96, y: 124), control2: CGPoint(x: 116, y: 126))

        case .hook:
            // The hook with its tip, then the loop of yarn around it
            path.move(to: CGPoint(x: 34, y: 122))
            path.addLine(to: CGPoint(x: 104, y: 46))
            path.addCurve(to: CGPoint(x: 118, y: 44), control1: CGPoint(x: 108, y: 40), control2: CGPoint(x: 116, y: 38))
            path.addCurve(to: CGPoint(x: 110, y: 48), control1: CGPoint(x: 120, y: 50), control2: CGPoint(x: 112, y: 52))
            path.move(to: CGPoint(x: 52, y: 74))
            path.addCurve(to: CGPoint(x: 92, y: 82), control1: CGPoint(x: 58, y: 58), control2: CGPoint(x: 96, y: 56))
            path.addCurve(to: CGPoint(x: 58, y: 90), control1: CGPoint(x: 88, y: 102), control2: CGPoint(x: 60, y: 104))
        }
        return path
    }
}

// The drawing scaled to fit, like LoopShape
struct IconDrawingShape: Shape {
    let drawing: IconDrawing

    func path(in rect: CGRect) -> Path {
        let scale = min(rect.width, rect.height) / 150
        let fit = CGAffineTransform(translationX: rect.minX, y: rect.minY).scaledBy(x: scale, y: scale)
        return drawing.gridPath.applying(fit)
    }
}

// The drawing as a thread, the same way LoopMark draws the loop
struct IconDrawingMark: View {
    let drawing: IconDrawing
    let size: CGFloat
    let color: Color

    var body: some View {
        IconDrawingShape(drawing: drawing)
            .stroke(color, style: StrokeStyle(lineWidth: size * drawing.lineWidth / 150, lineCap: .round, lineJoin: .round))
            .frame(width: size, height: size)
            .accessibilityHidden(true)
    }
}
