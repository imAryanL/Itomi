// First onboarding screen: what Itomi does, then Get started

import SwiftUI

struct WelcomeView: View {
    let onProjectCreated: (Project) -> Void

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                LoopMark(size: 60, color: .accent)
                    .frame(width: 96, height: 96)
                    .background(Color.cream, in: RoundedRectangle(cornerRadius: 24))

                VStack(alignment: .leading, spacing: 8) {
                    Text("Itomi")
                        .font(.system(size: 44, weight: .heavy, design: .rounded))
                    Text("Count every row, one stitch at a time.")
                        .font(.title3)
                        .opacity(0.85)
                }

                VStack(alignment: .leading, spacing: 18) {
                    FeatureRow(icon: "hand.tap", title: "Tap anywhere to count", detail: "A big counter you can hit without looking.")
                    FeatureRow(icon: "square.grid.2x2", title: "Split projects into parts", detail: "Head, body, arms. Each keeps its own count.")
                    FeatureRow(icon: "heart", title: "Free counter, no ads", detail: "Your projects stay yours, always.")
                }
                .padding(.top, 24)
            }
            .foregroundStyle(.white)
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(.horizontal, 28)
            .padding(.top, 60)
        }
        .background(Color.accent)
        .safeAreaInset(edge: .bottom) {
            NavigationLink {
                FirstProjectView(onProjectCreated: onProjectCreated)
            } label: {
                Text("Get started")
                    .font(.headline)
                    .foregroundStyle(Color.accent)
                    .frame(maxWidth: .infinity, minHeight: 56)
                    .background(Color.cream, in: Capsule())
            }
            .buttonStyle(.plain)
            .padding(.horizontal, 28)
            .padding(.bottom, 8)
        }
        .toolbarVisibility(.hidden, for: .navigationBar)
    }
}

// One line on the Welcome screen: icon, bold title and a short explanation
struct FeatureRow: View {
    let icon: String
    let title: String
    let detail: String

    var body: some View {
        HStack(alignment: .top, spacing: 14) {
            Image(systemName: icon)
                .font(.title3)
                .frame(width: 40, height: 40)
                .background(.white.opacity(0.14), in: RoundedRectangle(cornerRadius: 12))
                .accessibilityHidden(true)
            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .font(.headline)
                Text(detail)
                    .font(.subheadline)
                    .opacity(0.85)
            }
        }
        .accessibilityElement(children: .combine)
    }
}

#Preview {
    NavigationStack {
        WelcomeView(onProjectCreated: { _ in })
    }
}
