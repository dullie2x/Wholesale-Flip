//
//  AppViewModel 2.swift
//  Wholesale Flip
//
//  Created by Gbolade Ariyo on 3/31/25.
//


//  AppViewModel.swift
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
    @Published var isBuyPriceUnrealistic = false

    @Published private var lastCalculatedSquareFootage = ""
    @Published private var lastCalculatedArvPrice = ""
    @Published var hasValidCalculation = false

    @Published var showPaywall = false
    @Published var showMaxReachedPaywall = false
    @Published var hasReachedCalculationLimit = false
    @Published var isPremiumUser: Bool = false

    let maxFreeCalculations = 2
    private let calculationLimitKey = "calculationCount"
    private let lastResetDateKey = "lastResetDate"
    private var cancellables = Set<AnyCancellable>()

    var calculationsUsed: Int {
        return calculationCount
    }

    var timeUntilReset: TimeInterval {
        let calendar = Calendar.current
        let now = Date()
        var components = calendar.dateComponents([.year, .month, .day], from: now)
        components.day! += 1
        components.hour = 0
        components.minute = 0
        components.second = 0

        guard let nextMidnight = calendar.date(from: components) else {
            return 0
        }
        return nextMidnight.timeIntervalSince(now)
    }

    var formattedTimeUntilReset: String {
        let seconds = Int(timeUntilReset)
        if seconds <= 0 {
            return "Today"
        }
        let hours = seconds / 3600
        let minutes = (seconds % 3600) / 60
        return hours > 0 ? "\(hours)h \(minutes)m" : "\(minutes)m"
    }

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
        isBuyPriceUnrealistic = calculatedPrice < 5000
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
            checkAndResetIfNewDay()
            return UserDefaults.standard.integer(forKey: calculationLimitKey)
        }
        set {
            UserDefaults.standard.set(newValue, forKey: calculationLimitKey)
            if newValue == 1 {
                let today = Calendar.current.startOfDay(for: Date())
                UserDefaults.standard.set(today, forKey: lastResetDateKey)
            }
            checkCalculationLimit()
        }
    }

    init() {
        checkAndResetIfNewDay()
        self.isPremiumUser = UserDefaults.standard.bool(forKey: "isPremiumUser")
        checkCalculationLimit()
        setupSubscriptionObservers()
        Task {
            await SubscriptionManager.shared.verifySubscriptions()
        }
        setupResetTimer()
    }

    private func setupResetTimer() {
        Timer.publish(every: 60, on: .main, in: .common)
            .autoconnect()
            .sink { [weak self] _ in
                self?.checkAndResetIfNewDay()
                self?.objectWillChange.send()
            }
            .store(in: &cancellables)
    }

    private func checkAndResetIfNewDay() {
        let calendar = Calendar.current
        let today = calendar.startOfDay(for: Date())

        if let lastResetDate = UserDefaults.standard.object(forKey: lastResetDateKey) as? Date {
            let lastResetDay = calendar.startOfDay(for: lastResetDate)
            if today > lastResetDay {
                UserDefaults.standard.set(0, forKey: calculationLimitKey)
                UserDefaults.standard.set(today, forKey: lastResetDateKey)
                checkCalculationLimit()
                print("🔁 Midnight reset triggered. Calculation count reset to 0.")
            }
        } else {
            UserDefaults.standard.set(today, forKey: lastResetDateKey)
        }
    }

    private func setupSubscriptionObservers() {
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

        NotificationCenter.default.publisher(for: UIApplication.didBecomeActiveNotification)
            .sink { [weak self] _ in
                guard let strongSelf = self else { return }
                Task { @MainActor in
                    strongSelf.checkAndResetIfNewDay()
                    await SubscriptionManager.shared.verifySubscriptions()
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
        checkAndResetIfNewDay()
        if !isPremiumUser {
            if calculationCount >= maxFreeCalculations {
                withAnimation {
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
        hasReachedCalculationLimit = !isPremiumUser && calculationCount >= maxFreeCalculations
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

    func togglePremiumStatus() {
        isPremiumUser.toggle()
        UserDefaults.standard.set(isPremiumUser, forKey: "isPremiumUser")
        checkCalculationLimit()
        Task {
            await SubscriptionManager.shared.verifySubscriptions()
        }
    }

    func debugForceReset() {
        let calendar = Calendar.current
        let yesterday = calendar.date(byAdding: .day, value: -1, to: Date())!
        UserDefaults.standard.set(yesterday, forKey: lastResetDateKey)
        checkAndResetIfNewDay()
    }
}
