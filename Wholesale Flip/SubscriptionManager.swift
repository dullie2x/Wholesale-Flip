import Foundation
import StoreKit
import Combine

class SubscriptionManager: ObservableObject {
    static let shared = SubscriptionManager()

    @Published var products: [Product] = []
    @Published var purchasedProductIDs: Set<String> = []

    let premiumID = "com.Wholesaleflip.premium.monthly"
    private var updateTask: Task<Void, Error>? = nil

    private init() {
        // Initial setup
        Task {
            await requestProducts()
            await verifySubscriptions() // This will set the correct initial state
            
            // Then start observing future transactions
            await observeTransactionUpdates()
        }
        
        // Also set up app lifecycle observation to verify when app becomes active
        setupAppLifecycleObservers()
    }

    // MARK: - Fetch Available Products
    func requestProducts() async {
        do {
            let storeProducts = try await Product.products(for: [premiumID])
            DispatchQueue.main.async {
                self.products = storeProducts
            }
        } catch {
            print("❌ Failed to fetch products: \(error)")
        }
    }

    // MARK: - Purchase Subscription
    func purchase(product: Product) async {
        do {
            let result = try await product.purchase()
            switch result {
            case .success(let verification):
                switch verification {
                case .verified(let transaction):
                    print("✅ Purchase verified!")
                    // Check if subscription is valid (not expired)
                    if isSubscriptionActive(transaction) {
                        await updatePremiumStatus(true)
                    } else {
                        await updatePremiumStatus(false)
                    }
                    await transaction.finish()
                case .unverified:
                    print("⚠️ Purchase unverified.")
                    await updatePremiumStatus(false)
                }
            case .userCancelled:
                print("❌ User canceled purchase.")
            default:
                print("⚠️ Unknown purchase result.")
            }
        } catch {
            print("❌ Purchase failed: \(error)")
        }
    }

    // MARK: - Restore Purchases
    func restore() async {
        do {
            try await AppStore.sync()
            await verifySubscriptions()
        } catch {
            print("❌ Failed to restore purchases: \(error)")
        }
    }
    
    // MARK: - Verify Subscriptions
    // This is the key method that checks if subscriptions are still valid
    func verifySubscriptions() async {
        // These local variables will be captured
        var hasActiveSubscription = false
        var purchased: Set<String> = []

        // Check current entitlements
        for await result in Transaction.currentEntitlements {
            switch result {
            case .verified(let transaction):
                if transaction.productID == premiumID {
                    // Check if this subscription is still active
                    if isSubscriptionActive(transaction) {
                        hasActiveSubscription = true
                        purchased.insert(transaction.productID)
                    }
                }
            case .unverified:
                break
            }
        }
        
        // Create local copies to avoid capturing the variables in the task
        let finalHasActiveSubscription = hasActiveSubscription
        let finalPurchased = purchased
        
        // Update state based on verification results
        await MainActor.run {
            self.purchasedProductIDs = finalPurchased
            // Update UserDefaults to match the actual subscription state
            UserDefaults.standard.set(finalHasActiveSubscription, forKey: "isPremiumUser")
        }
    }
    
    // Helper to check if a subscription is currently active
    private func isSubscriptionActive(_ transaction: Transaction) -> Bool {
        // For auto-renewable subscriptions
        if transaction.productType == .autoRenewable {
            // Check if it's revoked or expired
            if transaction.revocationDate != nil {
                return false
            }
            
            if let expirationDate = transaction.expirationDate {
                // Is the subscription still valid?
                return Date() < expirationDate
            }
        }
        
        // For non-subscription products, consider them active if not revoked
        return transaction.revocationDate == nil
    }

    // MARK: - Transaction Listener (Keeps Premium Updated)
    func observeTransactionUpdates() async {
        for await result in Transaction.updates {
            switch result {
            case .verified(let transaction):
                print("🔁 Transaction updated: \(transaction.productID)")
                
                if transaction.productID == premiumID {
                    // Check if this transaction is currently valid
                    let isActive = isSubscriptionActive(transaction)
                    await updatePremiumStatus(isActive)
                    await transaction.finish()
                }
            case .unverified:
                print("⚠️ Unverified transaction update")
                // When in doubt, verify all subscriptions
                await verifySubscriptions()
            }
        }
    }
    
    // Helper to update premium status across the app
    private func updatePremiumStatus(_ isPremium: Bool) async {
        await MainActor.run {
            // Update UserDefaults
            UserDefaults.standard.set(isPremium, forKey: "isPremiumUser")
            
            // Update purchased IDs set
            if isPremium {
                self.purchasedProductIDs.insert(premiumID)
            } else {
                self.purchasedProductIDs.remove(premiumID)
            }
        }
    }
    
    // Setup app lifecycle observers to check subscription status when app becomes active
    private func setupAppLifecycleObservers() {
        NotificationCenter.default.addObserver(
            forName: UIApplication.didBecomeActiveNotification,
            object: nil,
            queue: .main
        ) { [weak self] _ in
            // Cancel any existing task
            self?.updateTask?.cancel()
            
            // Create a new task
            self?.updateTask = Task {
                // Verify subscriptions when app becomes active
                await self?.verifySubscriptions()
                return
            }
        }
    }
}
