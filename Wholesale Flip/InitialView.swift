//import SwiftUI
//import Combine
//
//class AppViewModel: ObservableObject {
//    @Published var squareFootage = ""
//    @Published var arvPricePerSquareFoot = ""
//    @Published var rehabCost = ""
//    @Published var closingCostPercent = ""
//    @Published var carryingCostPercent = ""
//    @Published var desiredProfitPercent = ""
//    @Published var desiredWholesaleFee = ""
//    @Published var activeFocus: FieldFocus? = AppViewModel.FieldFocus.none
//    
//    enum FieldFocus: Hashable {
//        case squareFootage, arvPrice, rehab, closing, carrying, profit, wholesaleFee, none
//    }
//    
//    var arvSalePrice: Double {
//        guard let squareFootageValue = Double(squareFootage.trimmingCharacters(in: .whitespacesAndNewlines)),
//              let arvPricePerSquareFootValue = Double(arvPricePerSquareFoot.trimmingCharacters(in: .whitespacesAndNewlines)),
//              !squareFootage.isEmpty, !arvPricePerSquareFoot.isEmpty else {
//            return 0
//        }
//        return squareFootageValue * arvPricePerSquareFootValue
//    }
//    
//    var buyPrice: Double {
//        // Only calculate if we have valid values to work with
//        guard arvSalePrice > 0,
//              let rehabCostValue = Double(rehabCost.trimmingCharacters(in: .whitespacesAndNewlines)),
//              let desiredWholesaleFeeValue = Double(desiredWholesaleFee.trimmingCharacters(in: .whitespacesAndNewlines)),
//              !rehabCost.isEmpty, !desiredWholesaleFee.isEmpty else {
//            return 0
//        }
//        
//        // Ensure we don't return a negative value
//        let calculatedPrice = arvSalePrice - rehabCostValue - closingCost - carryingCost - desiredProfit - desiredWholesaleFeeValue
//        return max(calculatedPrice, 0)
//    }
//    
//    var closingCost: Double {
//        guard let closingCostPercentValue = Double(closingCostPercent.trimmingCharacters(in: .whitespacesAndNewlines)),
//              !closingCostPercent.isEmpty,
//              arvSalePrice > 0 else {
//            return 0
//        }
//        return arvSalePrice * (closingCostPercentValue / 100.0)
//    }
//    
//    var carryingCost: Double {
//        guard let carryingCostPercentValue = Double(carryingCostPercent.trimmingCharacters(in: .whitespacesAndNewlines)),
//              !carryingCostPercent.isEmpty,
//              arvSalePrice > 0 else {
//            return 0
//        }
//        return arvSalePrice * (carryingCostPercentValue / 100.0)
//    }
//    
//    var desiredProfit: Double {
//        guard let desiredProfitPercentValue = Double(desiredProfitPercent.trimmingCharacters(in: .whitespacesAndNewlines)),
//              !desiredProfitPercent.isEmpty,
//              arvSalePrice > 0 else {
//            return 0
//        }
//        return arvSalePrice * (desiredProfitPercentValue / 100.0)
//    }
//    
//    // For filling in example data
//    func fillExampleData() {
//        squareFootage = "1500"
//        arvPricePerSquareFoot = "150"
//        rehabCost = "25000"
//        closingCostPercent = "3"
//        carryingCostPercent = "2"
//        desiredProfitPercent = "10"
//        desiredWholesaleFee = "5000"
//    }
//    
//    func reset() {
//        squareFootage = ""
//        arvPricePerSquareFoot = ""
//        rehabCost = ""
//        closingCostPercent = ""
//        carryingCostPercent = ""
//        desiredProfitPercent = ""
//        desiredWholesaleFee = ""
//    }
//}
//
//// A modern, more visually appealing text field
//struct ModernTextField: View {
//    var icon: String
//    var title: String
//    @Binding var text: String
//    var keyboardType: UIKeyboardType = .default
//    var isFocused: Bool
//    var onTap: () -> Void
//    
//    @State private var isEditing = false
//    
//    var body: some View {
//        VStack(alignment: .leading, spacing: 4) {
//            HStack {
//                Image(systemName: icon)
//                    .foregroundColor(isFocused ? .accentColor : .gray)
//                    .frame(width: 24)
//                
//                Text(title)
//                    .font(.system(size: 14, weight: .medium))
//                    .foregroundColor(isFocused ? .accentColor : .gray)
//                
//                Spacer()
//            }
//            
//            HStack {
//                TextField("", text: $text) { isEditing in
//                    self.isEditing = isEditing
//                    if isEditing {
//                        onTap()
//                    }
//                }
//                .keyboardType(keyboardType)
//                .onReceive(Just(text)) { newValue in
//                    // Filter out invalid characters for decimal inputs
//                    if keyboardType == .decimalPad {
//                        let filtered = newValue.filter { "0123456789.".contains($0) }
//                        if filtered != newValue {
//                            self.text = filtered
//                        }
//                    }
//                }
//                
//                if !text.isEmpty {
//                    Button(action: {
//                        self.text = ""
//                    }) {
//                        Image(systemName: "xmark.circle.fill")
//                            .foregroundColor(.gray)
//                    }
//                    .transition(.scale)
//                    .animation(.easeInOut, value: text.isEmpty)
//                }
//            }
//        }
//        .padding(.vertical, 8)
//        .padding(.horizontal, 12)
//        .background(
//            RoundedRectangle(cornerRadius: 8)
//                .fill(Color(.systemBackground))
//                .shadow(color: isFocused ? Color.accentColor.opacity(0.3) : Color.black.opacity(0.1), radius: isFocused ? 4 : 2, x: 0, y: 1)
//        )
//        .overlay(
//            RoundedRectangle(cornerRadius: 8)
//                .stroke(isFocused ? Color.accentColor : Color.gray.opacity(0.3), lineWidth: isFocused ? 1.5 : 0.5)
//        )
//    }
//}
//
//// A card-style display for results
//struct ResultCard: View {
//    var title: String
//    var value: String
//    var icon: String
//    var color: Color
//    
//    var body: some View {
//        HStack(spacing: 16) {
//            Image(systemName: icon)
//                .font(.system(size: 24, weight: .medium))
//                .foregroundColor(color)
//                .frame(width: 32, height: 32)
//            
//            VStack(alignment: .leading, spacing: 4) {
//                Text(title)
//                    .font(.subheadline)
//                    .foregroundColor(.secondary)
//                
//                Text(value)
//                    .font(.system(size: 20, weight: .bold))
//                    .foregroundColor(.primary)
//            }
//            
//            Spacer()
//        }
//        .padding()
//        .background(
//            RoundedRectangle(cornerRadius: 12)
//                .fill(Color(.systemBackground))
//                .shadow(color: Color.black.opacity(0.1), radius: 5, x: 0, y: 2)
//        )
//    }
//}
//
//// A card-style display for expense results
//struct ExpenseCard: View {
//    var title: String
//    var value: String
//    var percentage: String
//    var icon: String
//    
//    var body: some View {
//        HStack(spacing: 12) {
//            Image(systemName: icon)
//                .font(.system(size: 18, weight: .medium))
//                .foregroundColor(.secondary)
//                .frame(width: 24, height: 24)
//            
//            Text(title)
//                .font(.subheadline)
//                .foregroundColor(.secondary)
//            
//            Spacer()
//            
//            VStack(alignment: .trailing, spacing: 2) {
//                Text(value)
//                    .font(.system(size: 17, weight: .semibold))
//                    .foregroundColor(.primary)
//                
//                if !percentage.isEmpty {
//                    Text(percentage)
//                        .font(.caption)
//                        .foregroundColor(.secondary)
//                }
//            }
//        }
//        .padding(.vertical, 8)
//    }
//}
//
//extension Double {
//    var formattedWithSeparator: String {
//        let formatter = NumberFormatter()
//        formatter.groupingSeparator = ","
//        formatter.numberStyle = .decimal
//        return formatter.string(for: self) ?? "0"
//    }
//    
//    var currencyFormatted: String {
//        let formatter = NumberFormatter()
//        formatter.numberStyle = .currency
//        formatter.currencyCode = "USD"
//        formatter.minimumFractionDigits = 0
//        formatter.maximumFractionDigits = 0
//        return formatter.string(for: self) ?? "$0"
//    }
//}
//
//extension View {
//    func hideKeyboardWhenTappedAround() -> some View {
//        return onTapGesture {
//            hideKeyboard()
//        }
//    }
//    
//    private func hideKeyboard() {
//        UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
//    }
//}
//
//struct InitialView: View {
//    @StateObject var viewModel = AppViewModel()
//    @FocusState private var focusedField: AppViewModel.FieldFocus?
//    @State private var showingExampleAlert = false
//    @State private var selectedTab = 0
//    
//    // Create a binding between the view model's activeFocus and the @FocusState
//    private var activeFocusBinding: Binding<AppViewModel.FieldFocus?> {
//        Binding(
//            get: { self.viewModel.activeFocus },
//            set: {
//                self.viewModel.activeFocus = $0
//                self.focusedField = $0
//            }
//        )
//    }
//    
//    var body: some View {
//        NavigationView {
//            VStack(spacing: 0) {
//                // Custom Tab View
//                HStack(spacing: 0) {
//                    tabButton(title: "Property Details", icon: "house.fill", index: 0)
//                    tabButton(title: "Expenses", icon: "dollarsign.circle.fill", index: 1)
//                    tabButton(title: "Results", icon: "chart.pie.fill", index: 2)
//                }
//                .background(Color(.systemBackground))
//                .shadow(color: Color.black.opacity(0.1), radius: 3, x: 0, y: 1)
//                
//                // Tab Content
//                ScrollView {
//                    VStack(spacing: 20) {
//                        // Different content based on selected tab
//                        if selectedTab == 0 {
//                            propertyDetailsView
//                        } else if selectedTab == 1 {
//                            expensesView
//                        } else {
//                            resultsView
//                        }
//                        
//                        Spacer(minLength: 30)
//                    }
//                    .padding(.horizontal)
//                    .padding(.top, 20)
//                    .frame(maxWidth: .infinity)
//                }
//                .background(Color(.systemGroupedBackground))
//            }
//            .navigationBarTitleDisplayMode(.inline)
//            .toolbar {
//                ToolbarItem(placement: .principal) {
//                    Text("Wholesale Calculator")
//                        .font(.headline)
//                        .foregroundColor(.primary)
//                }
//                
//                ToolbarItem(placement: .navigationBarTrailing) {
//                    Menu {
//                        Button(action: {
//                            showingExampleAlert = true
//                        }) {
//                            Label("Fill Example Data", systemImage: "doc.fill")
//                        }
//                        
//                        Button(action: {
//                            viewModel.reset()
//                        }) {
//                            Label("Reset All Fields", systemImage: "arrow.counterclockwise")
//                        }
//                    } label: {
//                        Image(systemName: "ellipsis.circle")
//                    }
//                }
//            }
//            .alert("Use Example Data?", isPresented: $showingExampleAlert) {
//                Button("Cancel", role: .cancel) { }
//                Button("Fill Fields") {
//                    viewModel.fillExampleData()
//                }
//            } message: {
//                Text("This will fill all fields with example data to help you understand how the calculator works.")
//            }
//        }
//        .accentColor(Color.blue)
//        .onChange(of: focusedField) { newValue in
//            viewModel.activeFocus = newValue
//        }
//    }
//    
//    private func tabButton(title: String, icon: String, index: Int) -> some View {
//        Button(action: {
//            withAnimation(.easeInOut(duration: 0.2)) {
//                selectedTab = index
//            }
//        }) {
//            VStack(spacing: 4) {
//                Image(systemName: icon)
//                    .font(.system(size: selectedTab == index ? 16 : 14))
//                
//                Text(title)
//                    .font(.system(size: 12, weight: selectedTab == index ? .semibold : .regular))
//                    .lineLimit(1)
//            }
//            .frame(maxWidth: .infinity)
//            .padding(.vertical, 10)
//            .foregroundColor(selectedTab == index ? .accentColor : .gray)
//            .background(
//                selectedTab == index ?
//                Rectangle()
//                    .fill(Color.accentColor)
//                    .frame(height: 3)
//                    .offset(y: 16)
//                : nil
//            )
//        }
//    }
//    
//    private var propertyDetailsView: some View {
//        VStack(spacing: 20) {
//            VStack(alignment: .leading, spacing: 6) {
//                Text("Property Information")
//                    .font(.headline)
//                    .padding(.leading, 8)
//                
//                ModernTextField(
//                    icon: "ruler",
//                    title: "Square Footage",
//                    text: $viewModel.squareFootage,
//                    keyboardType: .decimalPad,
//                    isFocused: focusedField == .squareFootage,
//                    onTap: { activeFocusBinding.wrappedValue = .squareFootage }
//                )
//                .focused($focusedField, equals: .squareFootage)
//                
//                ModernTextField(
//                    icon: "dollarsign.square",
//                    title: "ARV Price Per Sqft",
//                    text: $viewModel.arvPricePerSquareFoot,
//                    keyboardType: .decimalPad,
//                    isFocused: focusedField == .arvPrice,
//                    onTap: { activeFocusBinding.wrappedValue = .arvPrice }
//                )
//                .focused($focusedField, equals: .arvPrice)
//                
//                ModernTextField(
//                    icon: "hammer",
//                    title: "Rehab Cost",
//                    text: $viewModel.rehabCost,
//                    keyboardType: .decimalPad,
//                    isFocused: focusedField == .rehab,
//                    onTap: { activeFocusBinding.wrappedValue = .rehab }
//                )
//                .focused($focusedField, equals: .rehab)
//            }
//            
//            if viewModel.arvSalePrice > 0 {
//                ResultCard(
//                    title: "After Repair Value (ARV)",
//                    value: viewModel.arvSalePrice.currencyFormatted,
//                    icon: "house.fill",
//                    color: .green
//                )
//            }
//            
//            Divider()
//            
//            ModernTextField(
//                icon: "banknote",
//                title: "Desired Wholesale Fee",
//                text: $viewModel.desiredWholesaleFee,
//                keyboardType: .decimalPad,
//                isFocused: focusedField == .wholesaleFee,
//                onTap: { activeFocusBinding.wrappedValue = .wholesaleFee }
//            )
//            .focused($focusedField, equals: .wholesaleFee)
//            
//            tipCard(
//                title: "Input Tips",
//                content: "Enter the property's square footage and price per square foot to calculate its After Repair Value (ARV).",
//                icon: "lightbulb.fill"
//            )
//        }
//    }
//    
//    private var expensesView: some View {
//        VStack(spacing: 20) {
//            VStack(alignment: .leading, spacing: 6) {
//                Text("Expenses & Costs")
//                    .font(.headline)
//                    .padding(.leading, 8)
//                
//                ModernTextField(
//                    icon: "doc.text",
//                    title: "Closing Cost (%)",
//                    text: $viewModel.closingCostPercent,
//                    keyboardType: .decimalPad,
//                    isFocused: focusedField == .closing,
//                    onTap: { activeFocusBinding.wrappedValue = .closing }
//                )
//                .focused($focusedField, equals: .closing)
//                
//                ModernTextField(
//                    icon: "clock",
//                    title: "Carrying Cost (%)",
//                    text: $viewModel.carryingCostPercent,
//                    keyboardType: .decimalPad,
//                    isFocused: focusedField == .carrying,
//                    onTap: { activeFocusBinding.wrappedValue = .carrying }
//                )
//                .focused($focusedField, equals: .carrying)
//                
//                ModernTextField(
//                    icon: "chart.line.uptrend.xyaxis",
//                    title: "Desired Profit (%)",
//                    text: $viewModel.desiredProfitPercent,
//                    keyboardType: .decimalPad,
//                    isFocused: focusedField == .profit,
//                    onTap: { activeFocusBinding.wrappedValue = .profit }
//                )
//                .focused($focusedField, equals: .profit)
//            }
//            
//            if viewModel.arvSalePrice > 0 {
//                VStack(spacing: 16) {
//                    Text("Calculated Expenses")
//                        .font(.headline)
//                        .frame(maxWidth: .infinity, alignment: .leading)
//                        .padding(.leading, 8)
//                    
//                    VStack(spacing: 0) {
//                        ExpenseCard(
//                            title: "Closing Cost",
//                            value: viewModel.closingCost.currencyFormatted,
//                            percentage: !viewModel.closingCostPercent.isEmpty ? "\(viewModel.closingCostPercent)% of ARV" : "",
//                            icon: "doc.text"
//                        )
//                        
//                        Divider().padding(.leading, 36)
//                        
//                        ExpenseCard(
//                            title: "Carrying Cost",
//                            value: viewModel.carryingCost.currencyFormatted,
//                            percentage: !viewModel.carryingCostPercent.isEmpty ? "\(viewModel.carryingCostPercent)% of ARV" : "",
//                            icon: "clock"
//                        )
//                        
//                        Divider().padding(.leading, 36)
//                        
//                        ExpenseCard(
//                            title: "Desired Profit",
//                            value: viewModel.desiredProfit.currencyFormatted,
//                            percentage: !viewModel.desiredProfitPercent.isEmpty ? "\(viewModel.desiredProfitPercent)% of ARV" : "",
//                            icon: "chart.line.uptrend.xyaxis"
//                        )
//                        
//                        if !viewModel.desiredWholesaleFee.isEmpty {
//                            Divider().padding(.leading, 36)
//                            
//                            ExpenseCard(
//                                title: "Wholesale Fee",
//                                value: (Double(viewModel.desiredWholesaleFee) ?? 0).currencyFormatted,
//                                percentage: "",
//                                icon: "banknote"
//                            )
//                        }
//                    }
//                    .padding()
//                    .background(
//                        RoundedRectangle(cornerRadius: 12)
//                            .fill(Color(.systemBackground))
//                            .shadow(color: Color.black.opacity(0.1), radius: 5, x: 0, y: 2)
//                    )
//                }
//            } else {
//                tipCard(
//                    title: "Complete Property Details First",
//                    content: "Enter property details in the first tab to see expense calculations here.",
//                    icon: "arrow.left"
//                )
//            }
//        }
//    }
//    
//    private var resultsView: some View {
//        VStack(spacing: 20) {
//            if viewModel.arvSalePrice > 0 {
//                ResultCard(
//                    title: "After Repair Value (ARV)",
//                    value: viewModel.arvSalePrice.currencyFormatted,
//                    icon: "house.fill",
//                    color: .green
//                )
//                
//                ResultCard(
//                    title: "Maximum Buy Price",
//                    value: viewModel.buyPrice.currencyFormatted,
//                    icon: "tag.fill",
//                    color: .blue
//                )
//                
//                // Breakdown section
//                VStack(alignment: .leading, spacing: 16) {
//                    Text("Deal Breakdown")
//                        .font(.headline)
//                        .padding(.leading, 8)
//                    
//                    VStack(spacing: 16) {
//                        HStack {
//                            Text("ARV Sale Price")
//                                .foregroundColor(.secondary)
//                            Spacer()
//                            Text(viewModel.arvSalePrice.currencyFormatted)
//                                .fontWeight(.medium)
//                        }
//                        
//                        breakdownRow(
//                            title: "Rehab Cost",
//                            value: Double(viewModel.rehabCost) ?? 0,
//                            isSubtraction: true
//                        )
//                        
//                        breakdownRow(
//                            title: "Closing Cost",
//                            value: viewModel.closingCost,
//                            isSubtraction: true
//                        )
//                        
//                        breakdownRow(
//                            title: "Carrying Cost",
//                            value: viewModel.carryingCost,
//                            isSubtraction: true
//                        )
//                        
//                        breakdownRow(
//                            title: "Investor's Profit",
//                            value: viewModel.desiredProfit,
//                            isSubtraction: true
//                        )
//                        
//                        breakdownRow(
//                            title: "Wholesale Fee",
//                            value: Double(viewModel.desiredWholesaleFee) ?? 0,
//                            isSubtraction: true
//                        )
//                        
//                        Divider()
//                        
//                        HStack {
//                            Text("Maximum Buy Price")
//                                .fontWeight(.bold)
//                            Spacer()
//                            Text(viewModel.buyPrice.currencyFormatted)
//                                .fontWeight(.bold)
//                        }
//                    }
//                    .padding()
//                    .background(
//                        RoundedRectangle(cornerRadius: 12)
//                            .fill(Color(.systemBackground))
//                            .shadow(color: Color.black.opacity(0.1), radius: 5, x: 0, y: 2)
//                    )
//                }
//            } else {
//                tipCard(
//                    title: "No Calculation Results Yet",
//                    content: "Fill in the property details and expenses to see your results here.",
//                    icon: "exclamationmark.triangle"
//                )
//            }
//        }
//    }
//    
//    private func breakdownRow(title: String, value: Double, isSubtraction: Bool = false) -> some View {
//        HStack {
//            HStack(spacing: 4) {
//                if isSubtraction {
//                    Text("-")
//                        .foregroundColor(.red)
//                }
//                Text(title)
//                    .foregroundColor(.secondary)
//            }
//            Spacer()
//            Text(value.currencyFormatted)
//                .foregroundColor(isSubtraction ? .red : .primary)
//        }
//    }
//    
//    private func tipCard(title: String, content: String, icon: String) -> some View {
//        VStack(alignment: .leading, spacing: 8) {
//            HStack {
//                Image(systemName: icon)
//                    .foregroundColor(.blue)
//                
//                Text(title)
//                    .font(.headline)
//                    .foregroundColor(.primary)
//            }
//            
//            Text(content)
//                .font(.subheadline)
//                .foregroundColor(.secondary)
//                .fixedSize(horizontal: false, vertical: true)
//        }
//        .padding()
//        .frame(maxWidth: .infinity, alignment: .leading)
//        .background(
//            RoundedRectangle(cornerRadius: 12)
//                .fill(Color.blue.opacity(0.1))
//        )
//        .overlay(
//            RoundedRectangle(cornerRadius: 12)
//                .stroke(Color.blue.opacity(0.3), lineWidth: 1)
//        )
//    }
//}
//
//struct InitialView_Previews: PreviewProvider {
//    static var previews: some View {
//        InitialView()
//    }
//}
