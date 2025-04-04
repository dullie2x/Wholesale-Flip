import SwiftUI
import Combine
import StoreKit

class AppViewModel: ObservableObject {
    @Published var squareFootage = ""
    @Published var arvPricePerSquareFoot = ""
    @Published var rehabCost = ""
    @Published var closingCostPercent = ""
    @Published var carryingCostPercent = ""
    @Published var desiredProfitPercent = ""
    @Published var desiredWholesaleFee = ""
    @Published var activeFocus: FieldFocus? = nil

    // Calculation state tracking
    @Published private var lastCalculatedSquareFootage = ""
    @Published private var lastCalculatedArvPrice = ""
    @Published var hasValidCalculation = false

    // Paywall-related
    @Published var showPaywall = false
    @Published var showMaxReachedPaywall = false
    @Published var hasReachedCalculationLimit = false
    @Published var isPremiumUser: Bool = false

    let maxFreeCalculations = 2
    private let calculationLimitKey = "calculationCount"
    private let lastResetDateKey = "lastResetDate"
    private var cancellables = Set<AnyCancellable>()
    
    // Public accessor for calculation count
    var calculationsUsed: Int {
        return calculationCount
    }
    
    // Time remaining until next reset (at midnight)
    var timeUntilReset: TimeInterval {
        let calendar = Calendar.current
        let now = Date()
        
        // Calculate midnight of the next day
        var components = calendar.dateComponents([.year, .month, .day], from: now)
        components.day! += 1  // Next day
        components.hour = 0
        components.minute = 0
        components.second = 0
        
        guard let nextMidnight = calendar.date(from: components) else {
            return 0
        }
        
        return nextMidnight.timeIntervalSince(now)
    }
    
    // Formatted time until next reset
    var formattedTimeUntilReset: String {
        let seconds = Int(timeUntilReset)
        if seconds <= 0 {
            return "Today"
        }
        
        let hours = seconds / 3600
        let minutes = (seconds % 3600) / 60
        
        if hours > 0 {
            return "\(hours)h \(minutes)m"
        } else {
            return "\(minutes)m"
        }
    }
    
    // User-friendly message about when calculations reset
    var resetMessage: String {
        return "Resets at midnight"
    }

    enum FieldFocus: Hashable {
        case squareFootage, arvPrice, rehab, closing, carrying, profit, wholesaleFee, none
    }

    var propertyInputsChanged: Bool {
        return squareFootage != lastCalculatedSquareFootage ||
               arvPricePerSquareFoot != lastCalculatedArvPrice
    }

    var arvSalePrice: Double {
        if !hasValidCalculation || propertyInputsChanged {
            return 0
        }
        guard let squareFootageValue = Double(squareFootage.trimmingCharacters(in: .whitespacesAndNewlines)),
              let arvPricePerSquareFootValue = Double(arvPricePerSquareFoot.trimmingCharacters(in: .whitespacesAndNewlines)),
              !squareFootage.isEmpty, !arvPricePerSquareFoot.isEmpty else {
            return 0
        }
        return squareFootageValue * arvPricePerSquareFootValue
    }

    var buyPrice: Double {
        if arvSalePrice <= 0 { return 0 }

        guard let rehabCostValue = Double(rehabCost.trimmingCharacters(in: .whitespacesAndNewlines)),
              let desiredWholesaleFeeValue = Double(desiredWholesaleFee.trimmingCharacters(in: .whitespacesAndNewlines)),
              !rehabCost.isEmpty, !desiredWholesaleFee.isEmpty else {
            return 0
        }

        let calculatedPrice = arvSalePrice - rehabCostValue - closingCost - carryingCost - desiredProfit - desiredWholesaleFeeValue
        return max(calculatedPrice, 0)
    }

    var closingCost: Double {
        guard let val = Double(closingCostPercent.trimmingCharacters(in: .whitespacesAndNewlines)),
              !closingCostPercent.isEmpty,
              arvSalePrice > 0 else {
            return 0
        }
        return arvSalePrice * (val / 100.0)
    }

    var carryingCost: Double {
        guard let val = Double(carryingCostPercent.trimmingCharacters(in: .whitespacesAndNewlines)),
              !carryingCostPercent.isEmpty,
              arvSalePrice > 0 else {
            return 0
        }
        return arvSalePrice * (val / 100.0)
    }

    var desiredProfit: Double {
        guard let val = Double(desiredProfitPercent.trimmingCharacters(in: .whitespacesAndNewlines)),
              !desiredProfitPercent.isEmpty,
              arvSalePrice > 0 else {
            return 0
        }
        return arvSalePrice * (val / 100.0)
    }

    private var calculationCount: Int {
        get {
            // Check if we need to reset the counter
            checkAndResetIfNewDay()
            return UserDefaults.standard.integer(forKey: calculationLimitKey)
        }
        set {
            UserDefaults.standard.set(newValue, forKey: calculationLimitKey)
            
            // Store today's date to track when to reset
            if newValue == 1 {
                let today = Calendar.current.startOfDay(for: Date())
                UserDefaults.standard.set(today, forKey: lastResetDateKey)
            }
            
            checkCalculationLimit()
        }
    }

    init() {
        // Check if we need to reset the counter on startup
        checkAndResetIfNewDay()
        
        // Set initial premium status from UserDefaults
        self.isPremiumUser = UserDefaults.standard.bool(forKey: "isPremiumUser")
        
        // Check calculation limit based on current status
        checkCalculationLimit()
        
        // Setup subscription status observers
        setupSubscriptionObservers()
        
        // Verify subscription status with StoreKit
        Task {
            await SubscriptionManager.shared.verifySubscriptions()
        }
        
        // Set up a timer to periodically check if we need to reset the counter
        setupResetTimer()
    }
    
    private func setupResetTimer() {
        // Create a timer that fires every minute to check if we need to reset
        Timer.publish(every: 60, on: .main, in: .common)
            .autoconnect()
            .sink { [weak self] _ in
                self?.checkAndResetIfNewDay()
                self?.objectWillChange.send() // Update UI to refresh the countdown
            }
            .store(in: &cancellables)
    }
    
    private func checkAndResetIfNewDay() {
        let calendar = Calendar.current
        let today = calendar.startOfDay(for: Date())
        
        // Get the last reset date from UserDefaults
        if let lastResetDate = UserDefaults.standard.object(forKey: lastResetDateKey) as? Date {
            // Convert both to start of day to compare dates only
            let lastResetDay = calendar.startOfDay(for: lastResetDate)
            
            // Check if it's a new day
            if today > lastResetDay {
                // Reset the calculation counter
                UserDefaults.standard.set(0, forKey: calculationLimitKey)
                UserDefaults.standard.set(today, forKey: lastResetDateKey)
                checkCalculationLimit()
            }
        } else {
            // If no last reset date, set it to today
            UserDefaults.standard.set(today, forKey: lastResetDateKey)
        }
    }
    
    private func setupSubscriptionObservers() {
        // Watch for UserDefaults changes to isPremiumUser
        NotificationCenter.default.publisher(for: UserDefaults.didChangeNotification)
            .sink { [weak self] _ in
                let newPremiumStatus = UserDefaults.standard.bool(forKey: "isPremiumUser")
                
                DispatchQueue.main.async {
                    if self?.isPremiumUser != newPremiumStatus {
                        self?.isPremiumUser = newPremiumStatus
                        self?.checkCalculationLimit()
                    }
                }
            }
            .store(in: &cancellables)
        
        // Watch for changes to SubscriptionManager's purchased products
        SubscriptionManager.shared.$purchasedProductIDs
            .receive(on: DispatchQueue.main)
            .sink { [weak self] productIDs in
                let hasPremium = productIDs.contains(SubscriptionManager.shared.premiumID)
                
                if self?.isPremiumUser != hasPremium {
                    self?.isPremiumUser = hasPremium
                    self?.checkCalculationLimit()
                }
            }
            .store(in: &cancellables)
        
        // Observe app becoming active to refresh subscription status
        NotificationCenter.default.publisher(for: UIApplication.didBecomeActiveNotification)
            .sink { [weak self] _ in
                // Capture self strongly in a local variable to avoid the warning
                guard let strongSelf = self else { return }
                
                Task { @MainActor in
                    // Check if we need to reset the counter when app becomes active
                    strongSelf.checkAndResetIfNewDay()
                    
                    // Verify subscriptions
                    await SubscriptionManager.shared.verifySubscriptions()
                    
                    // Update UI on the main actor without referencing self in concurrent code
                    let currentPremiumStatus = SubscriptionManager.shared.purchasedProductIDs.contains(SubscriptionManager.shared.premiumID)
                    if strongSelf.isPremiumUser != currentPremiumStatus {
                        strongSelf.isPremiumUser = currentPremiumStatus
                        strongSelf.checkCalculationLimit()
                    }
                }
            }
            .store(in: &cancellables)
    }

    func reset() {
        squareFootage = ""
        arvPricePerSquareFoot = ""
        rehabCost = ""
        closingCostPercent = ""
        carryingCostPercent = ""
        desiredProfitPercent = ""
        desiredWholesaleFee = ""
        hasValidCalculation = false
        lastCalculatedSquareFootage = ""
        lastCalculatedArvPrice = ""
    }

    func performCalculation() {
        // Check if we need to reset before performing calculation
        checkAndResetIfNewDay()
        
        if !isPremiumUser {
            if calculationCount >= maxFreeCalculations {
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                    self.showMaxReachedPaywall = true
                }
                return
            }
            calculationCount += 1
        }

        lastCalculatedSquareFootage = squareFootage
        lastCalculatedArvPrice = arvPricePerSquareFoot
        hasValidCalculation = true
    }

    private func checkCalculationLimit() {
        if !isPremiumUser {
            hasReachedCalculationLimit = calculationCount >= maxFreeCalculations
        } else {
            hasReachedCalculationLimit = false
        }
    }

    func trackCalculation() {
        if !isPremiumUser {
            calculationCount += 1
        }
    }

    func resetCalculationCount() {
        calculationCount = 0
        checkCalculationLimit()
    }
    
    // DEBUG: Toggle premium status for testing
    func togglePremiumStatus() {
        // This is for debug UI testing only
        // It doesn't actually change the subscription status in StoreKit
        // We need to manually verify the subscription status after toggling
        isPremiumUser.toggle()
        UserDefaults.standard.set(isPremiumUser, forKey: "isPremiumUser")
        checkCalculationLimit()
        
        // Update StoreKit status to match our debug toggle
        Task {
            await SubscriptionManager.shared.verifySubscriptions()
        }
    }
    
    // Force a reset for testing
    func debugForceReset() {
        // Set the last reset date to yesterday to force a reset
        let calendar = Calendar.current
        let yesterday = calendar.date(byAdding: .day, value: -1, to: Date())!
        UserDefaults.standard.set(yesterday, forKey: lastResetDateKey)
        checkAndResetIfNewDay()
    }
}
