import SwiftUI

struct PropertyDetailsView: View {
    @ObservedObject var viewModel: AppViewModel
    @FocusState private var focusedField: AppViewModel.FieldFocus?
    @State private var showingExampleAlert = false
    @State private var showingPaywallView = false
    @State private var animateFields = false
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
                // Header with friendly welcome
                welcomeHeader
                
                // Property Information Section
                propertyInputSection
                
                // ARV Result Card (if available)
                if viewModel.arvSalePrice > 0 {
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
                
                // Tip card with friendly style
                TipCard(
                    title: "Quick Tip 💡",
                    content: "Enter your property's square footage and the local price per square foot to instantly see its After Repair Value (ARV).",
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
        .alert("Use Sample Property Data?", isPresented: $showingExampleAlert) {
            Button("Cancel", role: .cancel) { }
            Button("Let's See It!") {
                withAnimation {
                    viewModel.fillExampleData()
                }
            }
        } message: {
            Text("We'll fill in some sample numbers to help you see how the calculator works.")
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
        }.sheet(isPresented: $showingPaywallView) {
            PaywallView()
        }
    }
    
    // MARK: - Component Views
    
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
    
    // Menu Button
    private var menuButton: some View {
        Menu {
            Button(action: {
                showingExampleAlert = true
            }) {
                Label("Use Sample Property", systemImage: "doc.fill")
            }
            
            Button(action: {
                withAnimation {
                    viewModel.reset()
                }
            }) {
                Label("Start Fresh", systemImage: "arrow.counterclockwise")
            }
            
            Divider()
            
            Button(action: {
                // Show paywall view
                showingPaywallView = true
            }) {
                Label("Upgrade to Premium", systemImage: "star.fill")
                    .foregroundColor(Color("Gold"))
            }
        } label: {
            Image(systemName: "ellipsis.circle.fill")
                .foregroundColor(Color("AppTeal"))
                .font(.system(size: 22))
        }
    }
    
    // Original Tip Card for backward compatibility
    private func tipCard(title: String, content: String, primaryColor: Color, secondaryColor: Color) -> some View {
        TipCard(
            title: title,
            content: content,
            primaryColor: primaryColor,
            secondaryColor: secondaryColor
        )
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
