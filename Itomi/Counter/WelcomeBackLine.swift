// Small line above the counter after a day or more away: "Welcome back · Last counted 3 days ago"

import SwiftUI

struct WelcomeBackLine: View {
    @Environment(\.themeColor) private var themeColor
    let text: String

    var body: some View {
        HStack(spacing: 10) {
            Image(systemName: "hand.wave.fill")
                .font(.title3)
                .foregroundStyle(themeColor)
            VStack(alignment: .leading, spacing: 2) {
                Text("Welcome back")
                    .font(.headline)
                    .fontWeight(.semibold)
                Text(text)
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            }
            Spacer()
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 12)
        .background(Color.cream, in: RoundedRectangle(cornerRadius: 20))
        .accessibilityElement(children: .combine)
    }
}
