import SwiftUI

class AppViewModel: ObservableObject {
    @Published var squareFootage = ""
    @Published var arvPricePerSquareFoot = ""
    @Published var rehabCost = ""
    @Published var closingCostPercent = ""
    @Published var carryingCostPercent = ""
    @Published var desiredProfitPercent = ""
    @Published var desiredWholesaleFee = ""
    
    var arvSalePrice: Double {
        guard let squareFootageValue = Double(squareFootage),
              let arvPricePerSquareFootValue = Double(arvPricePerSquareFoot) else {
            return 0
        }
        return squareFootageValue * arvPricePerSquareFootValue
    }
    
    var buyPrice: Double {
        guard let rehabCostValue = Double(rehabCost),
              let desiredWholesaleFeeValue = Double(desiredWholesaleFee) else {
            return 0
        }
        return arvSalePrice - rehabCostValue - closingCost - carryingCost - desiredProfit - desiredWholesaleFeeValue
    }
    
    var closingCost: Double {
        guard let closingCostPercentValue = Double(closingCostPercent) else {
            return 0
        }
        return arvSalePrice * (closingCostPercentValue / 100.0)
    }
    
    var carryingCost: Double {
        guard let carryingCostPercentValue = Double(carryingCostPercent) else {
            return 0
        }
        return arvSalePrice * (carryingCostPercentValue / 100.0)
    }
    
    var desiredProfit: Double {
        guard let desiredProfitPercentValue = Double(desiredProfitPercent) else {
            return 0
        }
        return arvSalePrice * (desiredProfitPercentValue / 100.0)
    }
}
struct CustomTextField: View {
    var title: String
    @Binding var text: String
    var keyboardType: UIKeyboardType = .default

    var body: some View {
        TextField(title, text: $text)
            .textFieldStyle(RoundedBorderTextFieldStyle())
            .keyboardType(keyboardType)
            .padding(5)
            .foregroundColor(.mint) // Ensure text is white for visibility
            .background(Color.darkSlateGray) // Background color for the text field
            .cornerRadius(5)
    }
}
extension Double {
    var formattedWithSeparator: String {
        let formatter = NumberFormatter()
        formatter.groupingSeparator = ","
        formatter.numberStyle = .decimal
        return formatter.string(for: self) ?? ""
    }
}

extension View {
    func hideKeyboardWhenTappedAround() -> some View {
        return onTapGesture {
            hideKeyboard()
        }
    }
    
    private func hideKeyboard() {
        let resign = #selector(UIResponder.resignFirstResponder)
        UIApplication.shared.sendAction(resign, to: nil, from: nil, for: nil)
    }
}
struct InitialView: View {
    @ObservedObject var viewModel = AppViewModel()

    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Property Details").font(.headline).foregroundColor(.mint)) {
                    CustomTextField(title: "Square Footage", text: $viewModel.squareFootage, keyboardType: .decimalPad)
                    CustomTextField(title: "ARV Price Per Sqft", text: $viewModel.arvPricePerSquareFoot, keyboardType: .decimalPad)
                    CustomTextField(title: "Rehab Cost", text: $viewModel.rehabCost, keyboardType: .decimalPad)
                }
                .listRowBackground(Color.darkSlateGray)

                Section(header: Text("Expenses").font(.headline).foregroundColor(.mint)) {
                    CustomTextField(title: "Closing Cost (%)", text: $viewModel.closingCostPercent, keyboardType: .decimalPad)
                    Text("Closing Cost: $\(viewModel.closingCost.formattedWithSeparator)")
                    CustomTextField(title: "Carrying Cost (%)", text: $viewModel.carryingCostPercent, keyboardType: .decimalPad)
                    Text("Carrying Cost: $\(viewModel.carryingCost.formattedWithSeparator)")
                    CustomTextField(title: "Desired Profit (%)", text: $viewModel.desiredProfitPercent, keyboardType: .decimalPad)
                    Text("Desired Profit: $\(viewModel.desiredProfit.formattedWithSeparator)")
                }
                .listRowBackground(Color.darkSlateGray)

                Section(header: Text("Wholesale Fee").font(.headline).foregroundColor(.mint)) {
                    CustomTextField(title: "Desired Wholesale Fee", text: $viewModel.desiredWholesaleFee, keyboardType: .decimalPad)
                }
                .listRowBackground(Color.darkSlateGray)

                Section(header: Text("Results").font(.headline).foregroundColor(.mint)) {
                    Text("ARV Sale Price: $\(viewModel.arvSalePrice.formattedWithSeparator)")
                        .bold()  // Make the text bold
                    Text("Buy Price: $\(viewModel.buyPrice.formattedWithSeparator)")
                        .bold()  // Make the text bold
                }
                .listRowBackground(Color.darkSlateGray)
            }
            .navigationBarTitle("Wholesale Calculator", displayMode: .inline)
            .background(Color.charcoal)
            .foregroundColor(.white)
            .hideKeyboardWhenTappedAround()
        }
        .navigationViewStyle(StackNavigationViewStyle())
    }
}

extension Color {
    static let darkSlateGray = Color(red: 0.18, green: 0.31, blue: 0.31)
    static let charcoal = Color(red: 0.24, green: 0.27, blue: 0.30)
    static let mint = Color(red: 0.60, green: 0.80, blue: 0.60)
}

struct InitialView_Previews: PreviewProvider {
    static var previews: some View {
        InitialView(viewModel: AppViewModel())
    }
}
