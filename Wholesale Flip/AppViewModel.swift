import SwiftUI
import Combine

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
    
    // Paywall related properties
    @Published var showPaywall = false
    @Published var showMaxReachedPaywall = false
    @Published var hasReachedCalculationLimit = false
    
    private let calculationLimitKey = "calculationCount"
    private let premiumStatusKey = "isPremiumUser"
    let maxFreeCalculations = 2  // User gets 2 free calculations
    
    // Public accessor for calculation count
    var calculationsUsed: Int {
        return calculationCount
    }
    
    enum FieldFocus: Hashable {
        case squareFootage, arvPrice, rehab, closing, carrying, profit, wholesaleFee, none
    }
    
    // Check if core property values have changed since calculation
    var propertyInputsChanged: Bool {
        return squareFootage != lastCalculatedSquareFootage ||
               arvPricePerSquareFoot != lastCalculatedArvPrice
    }
    
    var arvSalePrice: Double {
        // First check if core inputs have changed
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
        // Return 0 if ARV calculation is invalid
        if arvSalePrice <= 0 {
            return 0
        }
        
        // Only calculate if we have valid values to work with
        guard let rehabCostValue = Double(rehabCost.trimmingCharacters(in: .whitespacesAndNewlines)),
              let desiredWholesaleFeeValue = Double(desiredWholesaleFee.trimmingCharacters(in: .whitespacesAndNewlines)),
              !rehabCost.isEmpty, !desiredWholesaleFee.isEmpty else {
            return 0
        }
        
        // Ensure we don't return a negative value
        let calculatedPrice = arvSalePrice - rehabCostValue - closingCost - carryingCost - desiredProfit - desiredWholesaleFeeValue
        return max(calculatedPrice, 0)
    }
    
    var closingCost: Double {
        guard let closingCostPercentValue = Double(closingCostPercent.trimmingCharacters(in: .whitespacesAndNewlines)),
              !closingCostPercent.isEmpty,
              arvSalePrice > 0 else {
            return 0
        }
        return arvSalePrice * (closingCostPercentValue / 100.0)
    }
    
    var carryingCost: Double {
        guard let carryingCostPercentValue = Double(carryingCostPercent.trimmingCharacters(in: .whitespacesAndNewlines)),
              !carryingCostPercent.isEmpty,
              arvSalePrice > 0 else {
            return 0
        }
        return arvSalePrice * (carryingCostPercentValue / 100.0)
    }
    
    var desiredProfit: Double {
        guard let desiredProfitPercentValue = Double(desiredProfitPercent.trimmingCharacters(in: .whitespacesAndNewlines)),
              !desiredProfitPercent.isEmpty,
              arvSalePrice > 0 else {
            return 0
        }
        return arvSalePrice * (desiredProfitPercentValue / 100.0)
    }
    
    var isPremiumUser: Bool {
        get {
            return UserDefaults.standard.bool(forKey: premiumStatusKey)
        }
        set {
            UserDefaults.standard.set(newValue, forKey: premiumStatusKey)
            if newValue {
                hasReachedCalculationLimit = false
            } else {
                checkCalculationLimit()
            }
        }
    }
    
    private var calculationCount: Int {
        get {
            return UserDefaults.standard.integer(forKey: calculationLimitKey)
        }
        set {
            UserDefaults.standard.set(newValue, forKey: calculationLimitKey)
            checkCalculationLimit()
        }
    }
    
    init() {
        // Initialize and check existing calculation limit status
        checkCalculationLimit()
    }
    
    func reset() {
        squareFootage = ""
        arvPricePerSquareFoot = ""
        rehabCost = ""
        closingCostPercent = ""
        carryingCostPercent = ""
        desiredProfitPercent = ""
        desiredWholesaleFee = ""
        
        // Reset calculation state
        hasValidCalculation = false
        lastCalculatedSquareFootage = ""
        lastCalculatedArvPrice = ""
    }
    
    // Called when Calculate button is pressed
    func performCalculation() {
        // Only track and limit if user is not premium
        if !isPremiumUser {
            // ✅ Check BEFORE incrementing
            if calculationCount >= maxFreeCalculations {
                print("Calculation limit reached. Showing paywall.")
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                    self.showMaxReachedPaywall = true
                }
                return
            }

            // ✅ Safe to increment AFTER the check
            calculationCount += 1
            print("Tracked calculation #\(calculationCount)")
        }

        // Store property values for future change tracking
        lastCalculatedSquareFootage = squareFootage
        lastCalculatedArvPrice = arvPricePerSquareFoot
        hasValidCalculation = true
    }
    
    // MARK: - Paywall Related Methods
    
    private func checkCalculationLimit() {
        // Only enforce limit for non-premium users
        if !isPremiumUser {
            print("Calculation count: \(calculationCount), max: \(maxFreeCalculations)")
            // IMPORTANT: Use > and not >= so that exactly 2 calculations are allowed
            // AFTER the 2nd calculation is complete, we'll set hasReachedCalculationLimit to true
            hasReachedCalculationLimit = calculationCount > maxFreeCalculations - 1
            print("Has reached limit: \(hasReachedCalculationLimit)")
        } else {
            hasReachedCalculationLimit = false
        }
    }
    
    func trackCalculation() {
        // Only track for non-premium users
        if !isPremiumUser {
            // First increment the counter
            calculationCount += 1
            print("Tracked calculation #\(calculationCount)")
        }
    }
    
    func unlockPremium() {
        // This would be connected to your in-app purchase logic
        isPremiumUser = true
        hasReachedCalculationLimit = false
    }
    
    func resetCalculationCount() {
        // For testing purposes
        calculationCount = 0
        checkCalculationLimit()
    }
}
