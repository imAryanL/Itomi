// One part in a project's parts list: name, status and a thick progress bar

import SwiftUI

struct PartRow: View {
    let part: Part

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack(spacing: 8) {
                Text(part.name)
                    .font(.headline)
                    .fontWeight(.semibold)
                if part.copies > 1 {
                    Text("×\(part.copies)")
                        .font(.caption)
                        .fontWeight(.bold)
                        .foregroundStyle(Color.accent)
                        .padding(.horizontal, 7)
                        .padding(.vertical, 2)
                        .background(Color.cream, in: Capsule())
                }
                Spacer()
                status
            }
            ThickProgressBar(value: part.progress, isDone: part.isDone)
        }
        .padding(.vertical, 6)
        // Divider lines start at the row's left edge, not under "Done"
        .alignmentGuide(.listRowSeparatorLeading) { _ in
            return 0
        }
        .accessibilityElement(children: .combine)
    }

    // Green "Done" pill, the current round, or "Not started"
    @ViewBuilder
    var status: some View {
        if part.isDone {
            HStack(spacing: 4) {
                Image(systemName: "checkmark")
                    .font(.caption)
                    .fontWeight(.black)
                Text("Done")
                    .font(.subheadline)
                    .fontWeight(.bold)
            }
            .foregroundStyle(.green)
            .padding(.horizontal, 10)
            .padding(.vertical, 4)
            .background(.green.opacity(0.14), in: Capsule())
        } else if part.lastCountedAt == nil {
            Text(part.statusText)
                .font(.subheadline)
                .foregroundStyle(.secondary)
        } else {
            Text(part.statusText)
                .font(.subheadline)
                .fontWeight(.semibold)
                .foregroundStyle(Color.accent)
        }
    }
}

// Rounded bar: plum while counting, green when the part is done
struct ThickProgressBar: View {
    let value: Double
    let isDone: Bool

    var body: some View {
        GeometryReader { geometry in
            ZStack(alignment: .leading) {
                Capsule()
                    .fill(Color.accent.opacity(0.12))
                Capsule()
                    .fill(isDone ? Color.green : Color.accent)
                    .frame(width: geometry.size.width * value)
            }
        }
        .frame(height: 8)
    }
}
