// Pro heads-up under the counter when a finished round's stitches don't match what it should have

import SwiftUI

// What went wrong on the round that was just finished
struct StitchWarning: Equatable {
    let countWord: String
    let round: Int
    let counted: Int
    let expected: Int
    let expectedBefore: Int?

    // e.g. "Round 6 had 17 stitches"
    var title: String {
        return "\(countWord) \(round) had \(counted) stitches"
    }

    // e.g. "It should have 18 (6 increases). One may have been missed."
    var message: String {
        var text = "It should have \(expected)"

        // Say how many increases or decreases the round has, when the round before has a target
        if let before = expectedBefore {
            let change = expected - before
            if change == 1 {
                text += " (1 increase)"
            } else if change > 1 {
                text += " (\(change) increases)"
            } else if change == -1 {
                text += " (1 decrease)"
            } else if change < -1 {
                text += " (\(-change) decreases)"
            }
        }
        text += "."

        let difference = expected - counted
        if difference == 1 {
            text += " One may have been missed."
        } else if difference > 1 {
            text += " \(difference) may have been missed."
        } else if difference == -1 {
            text += " There may be one extra."
        } else {
            text += " There may be \(-difference) extra."
        }
        return text
    }
}

struct StitchWarningCard: View {
    let warning: StitchWarning
    let onFix: () -> Void
    let onKeepGoing: () -> Void

    let background = Color(red: 0.99, green: 0.94, blue: 0.85)
    let border = Color(red: 0.93, green: 0.82, blue: 0.61)
    let darkText = Color(red: 0.37, green: 0.23, blue: 0.03)
    let brown = Color(red: 0.54, green: 0.33, blue: 0.06)

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack(alignment: .top, spacing: 12) {
                Image(systemName: "exclamationmark.triangle")
                    .font(.title3)
                    .fontWeight(.semibold)
                    .foregroundStyle(brown)
                VStack(alignment: .leading, spacing: 2) {
                    Text(warning.title)
                        .font(.headline)
                        .fontWeight(.bold)
                    Text(warning.message)
                        .font(.subheadline)
                        .fixedSize(horizontal: false, vertical: true)
                }
                .foregroundStyle(darkText)
                Spacer(minLength: 0)
            }
            .accessibilityElement(children: .combine)

            HStack(spacing: 8) {
                Button {
                    onKeepGoing()
                } label: {
                    Text("Keep going")
                        .fontWeight(.bold)
                        .frame(maxWidth: .infinity, minHeight: 44)
                        .foregroundStyle(darkText)
                        .background(.white, in: Capsule())
                }
                Button {
                    onFix()
                } label: {
                    Text("Fix stitches")
                        .fontWeight(.bold)
                        .frame(maxWidth: .infinity, minHeight: 44)
                        .foregroundStyle(.white)
                        .background(brown, in: Capsule())
                }
                .accessibilityHint("Goes back to the \(warning.countWord.lowercased()) before, with your stitches")
            }
            .buttonStyle(.plain)
            .font(.subheadline)
        }
        .padding(16)
        .background(background, in: RoundedRectangle(cornerRadius: 24))
        .overlay {
            RoundedRectangle(cornerRadius: 24)
                .stroke(border, lineWidth: 1)
        }
    }
}
