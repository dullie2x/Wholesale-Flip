import SwiftUI

struct PropertyDetailsView: View {
    @ObservedObject var viewModel: AppViewModel
    @FocusState private var focusedField: AppViewModel.FieldFocus?
    @State private var showingPaywallView = false
    @State private var showingMaxReachedPaywall = false
    @State private var animateFields = false
    @State private var showResult = false
    @Environment(\.colorScheme) private var colorScheme
    @EnvironmentObject private var reviewManager: AppReviewManager

    
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
                // Header with friendly welcome
                welcomeHeader
                
                // Property Information Section
                propertyInputSection
                
                // Property Change Warning
                propertyChangeWarning
                maxLimitReachedNotice
                // Calculate Button
                calculateButton
                
                // ARV Result Card (if available and calculation performed)
                if showResult && viewModel.arvSalePrice > 0 && !viewModel.propertyInputsChanged {
                    ResultCard(
                        title: "After Repair Value (ARV)",
                        value: viewModel.arvSalePrice.currencyFormatted,
                        icon: "house.fill",
                        color: Color("AppTeal")
                    )
                    .transition(.scale.combined(with: .opacity))
                }
                
                // Divider with style
                styledDivider
                
                // Wholesale fee input
                wholesaleFeeSection
                
                // Calculation counter
                calculationCounter
                
                // Tip card with friendly style
                TipCard(
                    title: "Quick Tip 💡",
                    content: "Enter your property's square footage and the local price per square foot, then tap Calculate to see the After Repair Value (ARV).",
                    primaryColor: Color("AppTeal"),
                    secondaryColor: Color("Gold")
                )
                
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
                Text("Property Calculator")
                    .font(.system(.title2, design: .rounded))
                    .fontWeight(.bold)
                    .foregroundColor(Color("NavyBlue"))
            }
            
            ToolbarItem(placement: .navigationBarTrailing) {
                menuButton
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
        .sheet(isPresented: $showingMaxReachedPaywall) {
            PaywallMaxView()
        }
        // Bind to viewModel's paywall state
        .onChange(of: viewModel.showMaxReachedPaywall) { newValue in
            showingMaxReachedPaywall = newValue
        }
    }
    
    // Property Change Warning
    private var propertyChangeWarning: some View {
        Group {
            if viewModel.hasValidCalculation && viewModel.propertyInputsChanged {
                HStack {
                    Image(systemName: "exclamationmark.triangle.fill")
                        .foregroundColor(Color("Gold"))
                    
                    Text("Property values changed - press 'Calculate' below to update results")
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
    // Max Calculation Limit Reached Notice
    private var maxLimitReachedNotice: some View {
        Group {
            if viewModel.hasReachedCalculationLimit && !viewModel.isPremiumUser {
                VStack(alignment: .leading, spacing: 10) {
                    HStack {
                        Image(systemName: "exclamationmark.triangle.fill")
                            .foregroundColor(.red)
                        
                        Text("You've hit your max free calculations for the day.")
                            .font(.system(size: 12, design: .rounded))
                            .foregroundColor(Color("NavyBlue"))
                        
                        Spacer()
                    }
                    
                    Button(action: {
                        // Delay slightly to ensure proper presentation
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                            // Make sure keyboard is dismissed
                            UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder),
                                                          to: nil, from: nil, for: nil)
                            
                            // Set both states to ensure proper presentation
                            self.showingMaxReachedPaywall = true
                            viewModel.showMaxReachedPaywall = true
                        }
                    }) {
                        Text("Upgrade")
                            .font(.system(size: 14, weight: .semibold, design: .rounded))
                            .foregroundColor(.white)
                            .padding(.vertical, 8)
                            .padding(.horizontal, 20)
                            .background(Color("Gold"))
                            .cornerRadius(10)
                            .shadow(color: Color("Gold").opacity(0.3), radius: 3, x: 0, y: 2)
                    }
                }
                .padding(12)
                .background(Color.red.opacity(0.08))
                .cornerRadius(12)
                .padding(.bottom, 8)
            }
        }
    }
    
    private var calculateButton: some View {
        Button(action: {
            // Add haptic feedback
            let generator = UIImpactFeedbackGenerator(style: .medium)
            generator.impactOccurred()
            
            // Hide keyboard
            UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
            
            // Validate inputs
            guard !viewModel.squareFootage.isEmpty,
                  !viewModel.arvPricePerSquareFoot.isEmpty else { return }
            
            // Only show paywall if they've already used 3 calcs (meaning this is the 4th tap)
            if viewModel.calculationsUsed >= viewModel.maxFreeCalculations && !viewModel.isPremiumUser {
                // show paywall and exit early
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                    showingMaxReachedPaywall = true
                }
                return
            }
            
            // Proceed with calculation
            viewModel.performCalculation()
            
            withAnimation {
                showResult = true
            }
            
            // Register successful calculation with the review manager
            reviewManager.registerSuccessfulCalculation()
            
        }) {
            HStack {
                Image(systemName: "function")
                    .font(.system(size: 18))
                Text("Calculate")
                    .font(.system(size: 18, weight: .medium, design: .rounded))
            }
            .foregroundColor(.white)
            .padding(.horizontal, 30)
            .padding(.vertical, 14)
            .background(
                LinearGradient(
                    gradient: Gradient(colors: [Color("AppTeal"), Color("AppTeal").opacity(0.8)]),
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
            )
            .cornerRadius(15)
            .shadow(color: Color("AppTeal").opacity(0.4), radius: 5, x: 0, y: 3)
        }
        .padding(.vertical, 5)
        .disabled(
            viewModel.squareFootage.isEmpty ||
            viewModel.arvPricePerSquareFoot.isEmpty ||
            (viewModel.hasReachedCalculationLimit && !viewModel.isPremiumUser)
        )
        .opacity(
            (viewModel.squareFootage.isEmpty ||
             viewModel.arvPricePerSquareFoot.isEmpty ||
             (viewModel.hasReachedCalculationLimit && !viewModel.isPremiumUser)) ? 0.6 : 1
        )
    }
    
    
    // Welcome header with animation
    private var welcomeHeader: some View {
        HStack(spacing: 12) {
            Image(systemName: "house.and.flag.fill")
                .font(.system(size: 24))
                .foregroundColor(Color("Gold"))
            
            VStack(alignment: .leading, spacing: 2) {
                Text("Hello, Property Pro!")
                    .font(.system(size: 18, weight: .medium, design: .rounded))
                    .foregroundColor(Color("NavyBlue"))
                
                Text("Ready to crunch some numbers?")
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
                .shadow(color: Color("NavyBlue").opacity(0.07),
                        radius: 10, x: 0, y: 5)
        )
    }
    
    // Property Input Section
    private var propertyInputSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Let's Calculate Your Property Value!")
                .font(.system(size: 18, weight: .medium, design: .rounded))
                .foregroundColor(Color("NavyBlue"))
                .padding(.leading, 8)
            
            // Square Footage Field
            let squareFootageField = ModernTextField(
                icon: "ruler",
                title: "Square Footage",
                text: $viewModel.squareFootage,
                keyboardType: .decimalPad,
                isFocused: focusedField == .squareFootage,
                onTap: { activeFocusBinding.wrappedValue = .squareFootage }
            )
                .focused($focusedField, equals: .squareFootage)
            
            // ARV Price Field
            let arvPriceField = ModernTextField(
                icon: "dollarsign.circle.fill",
                title: "ARV Price Per Sqft",
                text: $viewModel.arvPricePerSquareFoot,
                keyboardType: .decimalPad,
                isFocused: focusedField == .arvPrice,
                onTap: { activeFocusBinding.wrappedValue = .arvPrice }
            )
                .focused($focusedField, equals: .arvPrice)
            
            // Rehab Cost Field
            let rehabCostField = ModernTextField(
                icon: "hammer.fill",
                title: "Rehab Cost",
                text: $viewModel.rehabCost,
                keyboardType: .decimalPad,
                isFocused: focusedField == .rehab,
                onTap: { activeFocusBinding.wrappedValue = .rehab }
            )
                .focused($focusedField, equals: .rehab)
            
            // Apply animations
            Group {
                squareFootageField
                    .offset(x: animateFields ? 0 : -20)
                    .opacity(animateFields ? 1 : 0)
                
                arvPriceField
                    .offset(x: animateFields ? 0 : -20)
                    .opacity(animateFields ? 1 : 0.2)
                
                rehabCostField
                    .offset(x: animateFields ? 0 : -20)
                    .opacity(animateFields ? 1 : 0.4)
            }
        }
        .padding(16)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color("CardBackground"))
                .shadow(color: Color("NavyBlue").opacity(0.07),
                        radius: 10, x: 0, y: 5)
        )
        .onChange(of: viewModel.squareFootage) { newValue in
            showResult = false
        }
        .onChange(of: viewModel.arvPricePerSquareFoot) { newValue in
            showResult = false
        }
    }
    
    // Styled Divider
    private var styledDivider: some View {
        HStack {
            Rectangle()
                .frame(height: 2)
                .foregroundColor(Color("AppTeal").opacity(0.2))
            
            Image(systemName: "house.circle.fill")
                .foregroundColor(Color("Gold"))
                .font(.title2)
            
            Rectangle()
                .frame(height: 2)
                .foregroundColor(Color("AppTeal").opacity(0.2))
        }
        .padding(.vertical, 5)
    }
    
    // Wholesale Fee Section
    private var wholesaleFeeSection: some View {
        ModernTextField(
            icon: "banknote.fill",
            title: "Your Wholesale Fee",
            text: $viewModel.desiredWholesaleFee,
            keyboardType: .decimalPad,
            isFocused: focusedField == .wholesaleFee,
            onTap: { activeFocusBinding.wrappedValue = .wholesaleFee }
        )
        .focused($focusedField, equals: .wholesaleFee)
        .padding(16)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color("CardBackground"))
                .shadow(color: Color("NavyBlue").opacity(0.07),
                        radius: 10, x: 0, y: 5)
        )
    }
    
    // Calculation Counter
    private var calculationCounter: some View {
        HStack {
            Spacer()
            
            HStack(spacing: 6) {
                Image(systemName: "function")
                    .font(.system(size: 14))
                    .foregroundColor(Color("AppTeal"))
                
                if viewModel.isPremiumUser {
                    Text("Unlimited calculations")
                        .font(.system(size: 14, design: .rounded))
                        .foregroundColor(Color("Gold").opacity(0.9))
                        .bold()
                } else {
                    VStack(alignment: .leading, spacing: 2) {
                        Text("\(min(viewModel.calculationsUsed, viewModel.maxFreeCalculations)) of \(viewModel.maxFreeCalculations) free calculations used")
                            .font(.system(size: 14, design: .rounded))
                            .foregroundColor(Color("NavyBlue").opacity(0.7))
                        
                        if viewModel.calculationsUsed > 0 {
                            Text(viewModel.resetMessage)
                                .font(.system(size: 12, design: .rounded))
                                .foregroundColor(Color("NavyBlue").opacity(0.6))
                        }
                    }
                }
            }
            .padding(.vertical, 8)
            .padding(.horizontal, 12)
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(Color("CardBackground"))
                    .shadow(color: Color("NavyBlue").opacity(0.07), radius: 5, x: 0, y: 2)
            )
        }
        .padding(.horizontal, 5)
        .padding(.vertical, 5)
    }
    
    
    
    // Menu Button
    private var menuButton: some View {
        Menu {
            Button(action: {
                withAnimation {
                    viewModel.reset()
                    showResult = false
                }
            }) {
                Label("Start Fresh", systemImage: "arrow.counterclockwise")
            }

            Divider()

            Button(action: {
                // Small delay to avoid potential state conflicts
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                    UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder),
                                                   to: nil, from: nil, for: nil)
                    self.showingPaywallView = true
                }
            }) {
                Label("Upgrade to Premium", systemImage: "star.fill")
                    .foregroundColor(Color("Gold"))
            }

            Divider()

            // Privacy Policy Link
            Button(action: {
                if let url = URL(string: "https://www.ariestates.com/profit-flip") {
                    UIApplication.shared.open(url)
                }
            }) {
                Label("Privacy Policy", systemImage: "lock.shield")
            }

            // Terms of Use (EULA) Link
            Button(action: {
                if let url = URL(string: "https://www.apple.com/legal/internet-services/itunes/dev/stdeula/") {
                    UIApplication.shared.open(url)
                }
            }) {
                Label("Terms of Use", systemImage: "doc.text")
            }

        } label: {
            Image(systemName: "ellipsis.circle.fill")
                .foregroundColor(Color("AppTeal"))
                .font(.system(size: 22))
        }
    }

}

// Dark mode compatible result card
struct ResultCard: View {
    let title: String
    let value: String
    let icon: String
    let color: Color
    @Environment(\.colorScheme) private var colorScheme
    
    var body: some View {
        HStack(spacing: 15) {
            Image(systemName: icon)
                .font(.system(size: 28))
                .foregroundColor(.white)
                .frame(width: 60, height: 60)
                .background(
                    Circle()
                        .fill(
                            LinearGradient(
                                gradient: Gradient(colors: [color, color.opacity(0.8)]),
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                )
                .shadow(color: color.opacity(0.4), radius: 5, x: 0, y: 3)
            
            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(.system(size: 16, design: .rounded))
                    .foregroundColor(Color("NavyBlue").opacity(0.7))
                
                Text(value)
                    .font(.system(size: 24, weight: .bold, design: .rounded))
                    .foregroundColor(Color("NavyBlue"))
            }
            
            Spacer()
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color("CardBackground"))
                .shadow(color: Color("NavyBlue").opacity(0.07),
                        radius: 10, x: 0, y: 5)
        )
    }
}

// Dark mode compatible tip card
struct TipCard: View {
    let title: String
    let content: String
    let primaryColor: Color
    let secondaryColor: Color
    let icon: String?
    @Environment(\.colorScheme) private var colorScheme
    
    init(title: String, content: String, primaryColor: Color, secondaryColor: Color, icon: String? = nil) {
        self.title = title
        self.content = content
        self.primaryColor = primaryColor
        self.secondaryColor = secondaryColor
        self.icon = icon
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            if let icon = icon {
                HStack {
                    Image(systemName: icon)
                        .foregroundColor(secondaryColor)
                        .font(.system(size: 22))
                    
                    Text(title)
                        .font(.system(size: 18, weight: .medium, design: .rounded))
                        .foregroundColor(primaryColor)
                }
            } else {
                Text(title)
                    .font(.system(size: 18, weight: .medium, design: .rounded))
                    .foregroundColor(primaryColor)
            }
            
            Text(content)
                .font(.system(size: 15, design: .rounded))
                .foregroundColor(Color("NavyBlue").opacity(0.8))
                .fixedSize(horizontal: false, vertical: true)
                .lineSpacing(3)
        }
        .padding()
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(
                    LinearGradient(
                        gradient: Gradient(
                            colors: [primaryColor.opacity(0.1), secondaryColor.opacity(0.05)]
                        ),
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
        )
        .overlay(
            RoundedRectangle(cornerRadius: 16)
                .stroke(
                    primaryColor.opacity(0.2),
                    lineWidth: 1
                )
        )
    }
}

struct PropertyDetailsView_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            NavigationView {
                PropertyDetailsView(viewModel: AppViewModel())
            }
            .preferredColorScheme(.light)
            .previewDisplayName("Light Mode")
            
            NavigationView {
                PropertyDetailsView(viewModel: AppViewModel())
            }
            .preferredColorScheme(.dark)
            .previewDisplayName("Dark Mode")
        }
    }
}

// Extension to support the hideKeyboardWhenTappedAround modifier
//extension View {
//    func hideKeyboardWhenTappedAround() -> some View {
//        return self.onTapGesture {
//            UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
//        }
//    }
//}
//
//// Currency formatting extension (assumed to be defined elsewhere)
//extension Double {
//    var currencyFormatted: String {
//        let formatter = NumberFormatter()
//        formatter.numberStyle = .currency
//        formatter.minimumFractionDigits = 0
//        formatter.maximumFractionDigits = 0
//        return formatter.string(from: NSNumber(value: self)) ?? "$0"
//    }
//}
