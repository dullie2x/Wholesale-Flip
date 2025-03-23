import SwiftUI

struct ExpensesView: View {
    @ObservedObject var viewModel: AppViewModel
    @FocusState private var focusedField: AppViewModel.FieldFocus?
    @State private var animateFields = false
    @State private var showingPaywallView = false
    @Environment(\.colorScheme) private var colorScheme
    
    // Create a binding between the view model's activeFocus and the @FocusState
    private var activeFocusBinding: Binding<AppViewModel.FieldFocus?> {
        Binding(
            get: { self.viewModel.activeFocus },
            set: {
                self.viewModel.activeFocus = $0
                self.focusedField = $0
            }
        )
    }
    
    var body: some View {
        ScrollView {
            VStack(spacing: 22) {
                // Header with animation
                WelcomeHeader(
                    icon: "dollarsign.circle.fill",
                    title: "Cost Breakdown",
                    subtitle: "Let's set your costs and profit goals"
                )
                
                // Show property change notice if needed
                recalculationNotice
                
                // Input fields section
                inputFieldsSection
                
                // Results section (conditionally shown)
                if viewModel.arvSalePrice > 0 {
                    expenseSummarySection
                    quickTipSection
                } else if viewModel.hasValidCalculation && viewModel.propertyInputsChanged {
                    // Show recalculation needed message
                    TipCard(
                        title: "Property Values Changed",
                        content: "Head back to the Property tab and press 'Calculate' to update your results with the new property values.",
                        primaryColor: Color("Gold"),
                        secondaryColor: Color("AppTeal"),
                        icon: "arrow.left.circle.fill"
                    )
                } else {
                    // Friendly tip card when no calculations yet
                    TipCard(
                        title: "One More Step!",
                        content: "Head over to the Property tab first to enter your property details. Then we'll show your expense calculations right here!",
                        primaryColor: Color("AppTeal"),
                        secondaryColor: Color("Gold"),
                        icon: "arrow.left.circle.fill"
                    )
                }
                
                Spacer(minLength: 30)
            }
            .padding(.horizontal)
            .padding(.top, 15)
            .frame(maxWidth: .infinity)
        }
        .background(Color("Background"))
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .principal) {
                Text("Expenses & Costs")
                    .font(.system(.title2, design: .rounded))
                    .fontWeight(.bold)
                    .foregroundColor(Color("NavyBlue"))
            }
        }
        .onChange(of: focusedField) { newValue in
            viewModel.activeFocus = newValue
        }
        .hideKeyboardWhenTappedAround()
        .onAppear {
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                withAnimation(.easeOut(duration: 0.5)) {
                    animateFields = true
                }
            }
        }
        .sheet(isPresented: $showingPaywallView) {
            PaywallView()
        }
    }
    
    // Recalculation Notice
    private var recalculationNotice: some View {
        Group {
            if viewModel.hasValidCalculation && viewModel.propertyInputsChanged {
                HStack {
                    Image(systemName: "exclamationmark.triangle.fill")
                        .foregroundColor(Color("Gold"))
                    
                    Text("Property values changed - recalculation needed")
                        .font(.system(size: 12, design: .rounded))
                        .foregroundColor(Color("NavyBlue"))
                    
                    Spacer()
                    
                }
                .padding(8)
                .background(Color("Gold").opacity(0.1))
                .cornerRadius(8)
                .padding(.bottom, 5)
            }
        }
    }
    
    // MARK: - Component Views
    
    // Input fields section
    private var inputFieldsSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Let's Calculate Your Costs")
                .font(.system(size: 18, weight: .medium, design: .rounded))
                .foregroundColor(Color("NavyBlue"))
                .padding(.leading, 8)
            
            // Closing Cost Field
            let closingCostField = ModernTextField(
                icon: "doc.text.fill",
                title: "Closing Cost (%)",
                text: $viewModel.closingCostPercent,
                keyboardType: .decimalPad,
                isFocused: focusedField == .closing,
                onTap: { activeFocusBinding.wrappedValue = .closing }
            )
            .focused($focusedField, equals: .closing)
            
            // Carrying Cost Field
            let carryingCostField = ModernTextField(
                icon: "clock.fill",
                title: "Carrying Cost (%)",
                text: $viewModel.carryingCostPercent,
                keyboardType: .decimalPad,
                isFocused: focusedField == .carrying,
                onTap: { activeFocusBinding.wrappedValue = .carrying }
            )
            .focused($focusedField, equals: .carrying)
            
            // Profit Field
            let profitField = ModernTextField(
                icon: "chart.line.uptrend.xyaxis.circle.fill",
                title: "Your Target Profit (%)",
                text: $viewModel.desiredProfitPercent,
                keyboardType: .decimalPad,
                isFocused: focusedField == .profit,
                onTap: { activeFocusBinding.wrappedValue = .profit }
            )
            .focused($focusedField, equals: .profit)
            
            // Apply animations
            Group {
                closingCostField
                    .offset(x: animateFields ? 0 : -20)
                    .opacity(animateFields ? 1 : 0)
                
                carryingCostField
                    .offset(x: animateFields ? 0 : -20)
                    .opacity(animateFields ? 1 : 0.2)
                
                profitField
                    .offset(x: animateFields ? 0 : -20)
                    .opacity(animateFields ? 1 : 0.4)
            }
        }
        .padding(16)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color("CardBackground"))
                .shadow(
                    color: Color("NavyBlue").opacity(0.07),
                    radius: 10,
                    x: 0,
                    y: 5
                )
        )
    }
    
    // Expense summary section
    private var expenseSummarySection: some View {
        VStack(spacing: 16) {
            HStack {
                Image(systemName: "dollarsign.square.fill")
                    .foregroundColor(Color("Gold"))
                    .font(.system(size: 20))
                
                Text("Your Expense Summary")
                    .font(.system(size: 18, weight: .medium, design: .rounded))
                    .foregroundColor(Color("NavyBlue"))
                
                Spacer()
            }
            .padding(.leading, 8)
            
            expenseCardsList
        }
        .transition(.move(edge: .bottom).combined(with: .opacity))
    }
    
    // Expense cards list
    private var expenseCardsList: some View {
        VStack(spacing: 2) {
            // Closing Cost
            ExpenseCard(
                title: "Closing Cost",
                value: viewModel.closingCost.currencyFormatted,
                percentage: !viewModel.closingCostPercent.isEmpty ? "\(viewModel.closingCostPercent)% of ARV" : "",
                icon: "doc.text.fill",
                iconColor: Color("AppTeal")
            )
            
            styledDivider
            
            // Carrying Cost
            ExpenseCard(
                title: "Carrying Cost",
                value: viewModel.carryingCost.currencyFormatted,
                percentage: !viewModel.carryingCostPercent.isEmpty ? "\(viewModel.carryingCostPercent)% of ARV" : "",
                icon: "clock.fill",
                iconColor: Color("Gold")
            )
            
            styledDivider
            
            // Target Profit
            ExpenseCard(
                title: "Your Target Profit",
                value: viewModel.desiredProfit.currencyFormatted,
                percentage: !viewModel.desiredProfitPercent.isEmpty ? "\(viewModel.desiredProfitPercent)% of ARV" : "",
                icon: "chart.line.uptrend.xyaxis.circle.fill",
                iconColor: Color("AppTeal")
            )
            
            // Wholesale Fee (conditional)
            if !viewModel.desiredWholesaleFee.isEmpty {
                styledDivider
                
                ExpenseCard(
                    title: "Your Wholesale Fee",
                    value: (Double(viewModel.desiredWholesaleFee) ?? 0).currencyFormatted,
                    percentage: "",
                    icon: "banknote.fill",
                    iconColor: Color("Gold")
                )
            }
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color("CardBackground"))
                .shadow(
                    color: Color("NavyBlue").opacity(0.07),
                    radius: 8,
                    x: 0,
                    y: 4
                )
        )
    }
    
    // Styled divider
    private var styledDivider: some View {
        Divider()
            .padding(.leading, 36)
            .padding(.trailing, 8)
            .background(Color("NavyBlue").opacity(0.05))
    }
    
    // Quick tip section
    private var quickTipSection: some View {
        VStack(alignment: .leading, spacing: 6) {
            HStack(spacing: 6) {
                Image(systemName: "lightbulb.fill")
                    .foregroundColor(Color("Gold"))
                    .font(.system(size: 14))
                
                Text("Quick Tip")
                    .font(.system(size: 14, weight: .medium, design: .rounded))
                    .foregroundColor(Color("NavyBlue").opacity(0.8))
            }
            
            Text("Adjusting these percentages helps you find the right balance between profitability and deal attractiveness.")
                .font(.system(size: 14, design: .rounded))
                .foregroundColor(Color("NavyBlue").opacity(0.6))
                .lineSpacing(2)
        }
        .padding(.horizontal, 10)
        .padding(.top, 5)
    }
}



// Dark mode compatible welcome header
struct WelcomeHeader: View {
    let icon: String
    let title: String
    let subtitle: String
    @Environment(\.colorScheme) private var colorScheme
    
    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: icon)
                .font(.system(size: 24))
                .foregroundColor(Color("Gold"))
            
            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .font(.system(size: 18, weight: .medium, design: .rounded))
                    .foregroundColor(Color("NavyBlue"))
                
                Text(subtitle)
                    .font(.system(size: 14, design: .rounded))
                    .foregroundColor(Color("NavyBlue").opacity(0.7))
            }
            
            Spacer()
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(
                    LinearGradient(
                        gradient: Gradient(
                            colors: [Color("CardBackground"), Color("AppTeal").opacity(0.1)]
                        ),
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
                .shadow(
                    color: Color("NavyBlue").opacity(0.07),
                    radius: 10,
                    x: 0,
                    y: 5
                )
        )
    }
}
//struct ExpenseCard: View {
//    let title: String
//    let value: String
//    let percentage: String
//    let icon: String
//    let iconColor: Color
//    
//    var body: some View {
//        HStack {
//            Image(systemName: icon)
//                .foregroundColor(iconColor)
//                .font(.system(size: 20))
//                .frame(width: 28, height: 28)
//            
//            VStack(alignment: .leading, spacing: 2) {
//                Text(title)
//                    .font(.system(.subheadline, design: .rounded))
//                    .foregroundColor(Color("NavyBlue").opacity(0.7))
//                
//                if !percentage.isEmpty {
//                    Text(percentage)
//                        .font(.system(.caption, design: .rounded))
//                        .foregroundColor(Color("NavyBlue").opacity(0.5))
//                }
//            }
//            
//            Spacer()
//            
//            Text(value)
//                .font(.system(.headline, design: .rounded))
//                .foregroundColor(Color("NavyBlue"))
//        }
//        .padding(.vertical, 10)
//    }
//}

struct ExpensesView_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            NavigationView {
                ExpensesView(viewModel: AppViewModel())
            }
            .preferredColorScheme(.light)
            .previewDisplayName("Light Mode")
            
            NavigationView {
                ExpensesView(viewModel: AppViewModel())
            }
            .preferredColorScheme(.dark)
            .previewDisplayName("Dark Mode")
        }
    }
}
