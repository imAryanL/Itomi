// RevenueCat's required setup: knows if Pro is on, loads the prices, buys and restores

import Foundation
import RevenueCat

@MainActor
@Observable
final class ProStore {
    // Also saved for the Lock Screen buttons and Siri, which can run while the app is closed
    var isPro = false {
        didSet {
            UserDefaults.standard.set(isPro, forKey: "isPro")
            // Pro ended: take the counter off the Lock Screen
            if isPro == false {
                LockScreenCounter.end()
            }
        }
    }
    var yearly: Package?
    var lifetime: Package?
    var canGetFreeTrial = false
    var isBusy = false
    var errorMessage: String?

    // Must match the entitlement in the RevenueCat dashboard
    static let entitlement = "itomi_pro"

    // Builds from Xcode use RevenueCat's Test Store (fake purchases, no Apple account needed)
    static func configure() {
        #if DEBUG
        Purchases.logLevel = .warn
        Purchases.configure(withAPIKey: "test_qJoilGQocXylmrubUnXxmpsqfdp")
        #else
        Purchases.configure(withAPIKey: "appl_vwTtEDgKANiXpqOmLhwlhyFrhbB")
        #endif
    }

    // Load prices once, then keep isPro up to date for as long as the app runs
    func start() async {
        // Ask once up front, so Pro is right as soon as the app opens
        do {
            let info = try await Purchases.shared.customerInfo()
            isPro = hasPro(info)
        } catch {
            print("Couldn't check Pro: \(error)")
        }
        await loadPackages()
        for await info in Purchases.shared.customerInfoStream {
            isPro = hasPro(info)
        }
    }

    func loadPackages() async {
        do {
            let offerings = try await Purchases.shared.offerings()
            yearly = offerings.current?.annual
            lifetime = offerings.current?.lifetime
        } catch {
            print("Couldn't load prices: \(error)")
        }
        await checkFreeTrial()
    }

    // Only people who haven't had the free week before can get it
    func checkFreeTrial() async {
        guard let product = yearly?.storeProduct, product.introductoryDiscount != nil else {
            canGetFreeTrial = false
            return
        }
        let eligibility = await Purchases.shared.checkTrialOrIntroDiscountEligibility(product: product)
        canGetFreeTrial = eligibility == .eligible
    }

    // Buy yearly or lifetime; true when Pro is on afterwards
    func buy(_ package: Package) async -> Bool {
        // A quick double tap must never start two purchases
        if isBusy {
            return false
        }
        isBusy = true
        errorMessage = nil
        defer { isBusy = false }

        do {
            let result = try await Purchases.shared.purchase(package: package)
            if result.userCancelled {
                return false
            }
            isPro = hasPro(result.customerInfo)
            return isPro
        } catch {
            // Ask to Buy: a parent still has to approve it
            let code = (error as NSError).code
            if code == ErrorCode.paymentPendingError.rawValue {
                errorMessage = "Waiting for approval. Pro turns on as soon as it's approved."
            } else {
                errorMessage = "The purchase didn't go through. If you were charged, tap Restore purchases."
            }
            return false
        }
    }

    // Bring back Pro bought before (new phone, reinstall); true when Pro is on afterwards
    func restore() async -> Bool {
        if isBusy {
            return false
        }
        isBusy = true
        errorMessage = nil
        defer { isBusy = false }

        do {
            let info = try await Purchases.shared.restorePurchases()
            isPro = hasPro(info)
            if isPro == false {
                errorMessage = "No Itomi Pro purchase found on this Apple Account."
            }
            return isPro
        } catch {
            errorMessage = "Couldn't reach the App Store. Try again in a moment."
            return false
        }
    }

    func hasPro(_ info: CustomerInfo) -> Bool {
        return info.entitlements[ProStore.entitlement]?.isActive == true
    }
}
