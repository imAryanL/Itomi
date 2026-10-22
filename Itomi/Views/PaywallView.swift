// Itomi Pro: what Pro adds, yearly or lifetime, buy or restore (opened from +, Settings or a part's stitches)

import SwiftUI
import RevenueCat

struct PaywallView: View {
    @Environment(ProStore.self) private var proStore
    @Environment(\.dismiss) private var dismiss

    @State private var pickedYearly = true
    @State private var showingUnlocked = false

    var body: some View {
        // After buying, the thank-you takes over this screen; its button closes everything
        if showingUnlocked {
            ProUnlockedView {
                dismiss()
            }
            .transition(.opacity)
        } else {
            paywall
        }
    }

    var paywall: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                header
                featureCard
                planButtons
                if let message = proStore.errorMessage {
                    Text(message)
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                }
            }
            .padding(.horizontal, 20)
            .padding(.top, 8)
        }
        .background(Color.warmBackground)
        .safeAreaInset(edge: .bottom) {
            bottomButtons
        }
        .overlay(alignment: .topTrailing) {
            Button("Close", systemImage: "xmark") {
                Haptics.light()
                dismiss()
            }
            .labelStyle(.iconOnly)
            .buttonStyle(.glass)
            .buttonBorderShape(.circle)
            .controlSize(.large)
            .padding()
        }
        // Make sure prices are there (they load at launch, this covers a slow connection)
        .task {
            if proStore.yearly == nil {
                await proStore.loadPackages()
            }
        }
    }

    // Plum loop tile, title and the promise that counting stays free
    var header: some View {
        VStack(alignment: .leading, spacing: 12) {
            LoopMark(size: 40, color: .cream)
                .frame(width: 64, height: 64)
                .background(Color.accent, in: RoundedRectangle(cornerRadius: 18))
            Text("Itomi Pro")
                .font(.largeTitle)
                .fontWeight(.heavy)
            Text("Your counter stays free forever. Pro adds the extras.")
                .foregroundStyle(.secondary)
        }
        .padding(.top, 8)
    }

    // Everything Pro adds (keep this list to features that are in the app)
    var featureCard: some View {
        VStack(alignment: .leading, spacing: 14) {
            FeatureLine(icon: "lock.iphone", text: "Counter on your Lock Screen and Dynamic Island")
            FeatureLine(icon: "exclamationmark.triangle", text: "Stitch-count check on every round")
            FeatureLine(icon: "infinity", text: "Unlimited projects")
            FeatureLine(icon: "arrow.trianglehead.2.clockwise", text: "Make another of a finished project")
            FeatureLine(icon: "paintpalette", text: "Themes and app icons")
        }
        .padding(16)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(.background, in: RoundedRectangle(cornerRadius: 20))
    }

    // The two plans, yearly picked first
    var planButtons: some View {
        VStack(spacing: 10) {
            PlanButton(
                title: "Yearly",
                detail: yearlyDetail,
                badge: "Best value",
                isPicked: pickedYearly
            ) {
                pickedYearly = true
                Haptics.light()
            }
            PlanButton(
                title: "Lifetime",
                detail: lifetimeDetail,
                badge: nil,
                isPicked: pickedYearly == false
            ) {
                pickedYearly = false
                Haptics.light()
            }
        }
    }

    // Buy button plus Restore, Terms and Privacy
    var bottomButtons: some View {
        VStack(spacing: 12) {
            Button {
                Task {
                    await buyPickedPlan()
                }
            } label: {
                if proStore.isBusy {
                    ProgressView()
                        .frame(maxWidth: .infinity)
                        .accessibilityLabel("Processing purchase")
                } else {
                    Text(buyTitle)
                        .font(.headline)
                        .fontWeight(.semibold)
                        .frame(maxWidth: .infinity)
                }
            }
            .buttonStyle(.glassProminent)
            .controlSize(.extraLarge)
            .disabled(pickedPackage == nil || proStore.isBusy)

            // Apple asks for the renewal terms right by the buy button
            Text(disclosure)
                .font(.caption)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)

            // Side by side, or stacked when the text size is very large
            ViewThatFits {
                HStack(spacing: 20) {
                    footerLinks
                }
                VStack(spacing: 0) {
                    footerLinks
                }
            }
            .font(.footnote)
            .foregroundStyle(.secondary)
            .disabled(proStore.isBusy)
        }
        .padding(.horizontal, 20)
        .padding(.bottom, 8)
    }

    // Restore, Terms and Privacy, each at least 44pt tall
    @ViewBuilder
    var footerLinks: some View {
        Button("Restore purchases") {
            Task {
                await restore()
            }
        }
        .frame(minHeight: 44)
        Link("Terms", destination: termsURL)
            .frame(minHeight: 44)
        Link("Privacy", destination: privacyURL)
            .frame(minHeight: 44)
    }

    let termsURL = URL(string: "https://www.apple.com/legal/internet-services/itunes/dev/stdeula/")!
    let privacyURL = URL(string: "https://itomiapp.com/privacy")!

    // e.g. "7 days free, then $12.99 a year. Renews every year until you cancel in Settings."
    var disclosure: String {
        if pickedYearly == false {
            return "One payment. No subscription, nothing renews."
        }
        guard let yearly = proStore.yearly else {
            return ""
        }
        let price = yearly.storeProduct.localizedPriceString
        if proStore.canGetFreeTrial {
            return "\(trialLength) free, then \(price) a year. Renews every year until you cancel in Settings at least a day before it renews."
        }
        return "\(price) a year. Renews every year until you cancel in Settings at least a day before it renews."
    }

    // How long the free trial is, read from the App Store, e.g. "7 days"
    var trialLength: String {
        guard let period = proStore.yearly?.storeProduct.introductoryDiscount?.subscriptionPeriod else {
            return "7 days"
        }
        if period.unit == .week {
            return "\(period.value * 7) days"
        }
        if period.unit == .day {
            return "\(period.value) days"
        }
        if period.unit == .month {
            return "\(period.value) month"
        }
        return "\(period.value) year"
    }

    var pickedPackage: Package? {
        if pickedYearly {
            return proStore.yearly
        }
        return proStore.lifetime
    }

    // "Start my free week" or "Unlock Pro for life"
    var buyTitle: String {
        if pickedYearly {
            if proStore.canGetFreeTrial {
                return "Start my free week"
            }
            return "Get Pro yearly"
        }
        return "Unlock Pro for life"
    }

    // e.g. "7 days free, then $12.99 a year"
    var yearlyDetail: String {
        guard let yearly = proStore.yearly else {
            return "Loading price…"
        }
        let price = yearly.storeProduct.localizedPriceString
        if proStore.canGetFreeTrial {
            return "\(trialLength) free, then \(price) a year"
        }
        return "\(price) a year"
    }

    // e.g. "$29.99 once, yours forever"
    var lifetimeDetail: String {
        guard let lifetime = proStore.lifetime else {
            return "Loading price…"
        }
        return "\(lifetime.storeProduct.localizedPriceString) once, yours forever"
    }

    func buyPickedPlan() async {
        guard let package = pickedPackage else {
            return
        }
        Haptics.light()
        let isPro = await proStore.buy(package)
        if isPro {
            showThankYou()
        }
    }

    func restore() async {
        Haptics.light()
        let isPro = await proStore.restore()
        if isPro {
            showThankYou()
        }
    }

    func showThankYou() {
        Haptics.success()
        withAnimation {
            showingUnlocked = true
        }
    }
}

// One line in the feature card: plum icon and text
struct FeatureLine: View {
    let icon: String
    let text: String

    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: icon)
                .font(.title3)
                .foregroundStyle(Color.accent)
                .frame(width: 28)
            Text(text)
        }
    }
}

// A tappable plan card with a plum border when picked
struct PlanButton: View {
    let title: String
    let detail: String
    let badge: String?
    let isPicked: Bool
    let onTap: () -> Void

    var body: some View {
        Button {
            onTap()
        } label: {
            HStack {
                VStack(alignment: .leading, spacing: 2) {
                    Text(title)
                        .font(.headline)
                        .fontWeight(.bold)
                        .foregroundStyle(.primary)
                    Text(detail)
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                }
                Spacer()
                if let badge {
                    Text(badge)
                        .font(.caption)
                        .fontWeight(.bold)
                        .foregroundStyle(.white)
                        .padding(.horizontal, 10)
                        .padding(.vertical, 4)
                        .background(Color.accent, in: Capsule())
                }
            }
            .padding(16)
            .frame(minHeight: 64)
            .background(.background, in: RoundedRectangle(cornerRadius: 18))
            .overlay {
                if isPicked {
                    RoundedRectangle(cornerRadius: 18)
                        .stroke(Color.accent, lineWidth: 2)
                } else {
                    RoundedRectangle(cornerRadius: 18)
                        .stroke(Color.accent.opacity(0.15), lineWidth: 2)
                }
            }
        }
        .buttonStyle(.plain)
        .accessibilityAddTraits(selectedTrait)
    }

    // VoiceOver says "Selected" on the picked plan
    var selectedTrait: AccessibilityTraits {
        if isPicked {
            return .isSelected
        }
        return []
    }
}
