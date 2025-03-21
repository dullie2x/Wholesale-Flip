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
    
    enum FieldFocus: Hashable {
        case squareFootage, arvPrice, rehab, closing, carrying, profit, wholesaleFee, none
    }
    
    var arvSalePrice: Double {
        guard let squareFootageValue = Double(squareFootage.trimmingCharacters(in: .whitespacesAndNewlines)),
              let arvPricePerSquareFootValue = Double(arvPricePerSquareFoot.trimmingCharacters(in: .whitespacesAndNewlines)),
              !squareFootage.isEmpty, !arvPricePerSquareFoot.isEmpty else {
            return 0
        }
        return squareFootageValue * arvPricePerSquareFootValue
    }
    
    var buyPrice: Double {
        // Only calculate if we have valid values to work with
        guard arvSalePrice > 0,
              let rehabCostValue = Double(rehabCost.trimmingCharacters(in: .whitespacesAndNewlines)),
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
    
    // For filling in example data
    func fillExampleData() {
        squareFootage = "1500"
        arvPricePerSquareFoot = "150"
        rehabCost = "25000"
        closingCostPercent = "3"
        carryingCostPercent = "2"
        desiredProfitPercent = "10"
        desiredWholesaleFee = "5000"
    }
    
    func reset() {
        squareFootage = ""
        arvPricePerSquareFoot = ""
        rehabCost = ""
        closingCostPercent = ""
        carryingCostPercent = ""
        desiredProfitPercent = ""
        desiredWholesaleFee = ""
    }
}
