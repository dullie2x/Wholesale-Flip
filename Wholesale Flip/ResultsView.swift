import SwiftUI


struct ResultsView: View {
    @ObservedObject var viewModel: AppViewModel
    @State private var showBreakdown = false
    @Environment(\.colorScheme) private var colorScheme
    
    var body: some View {
        ScrollView {
            VStack(spacing: 22) {
                // Results header with animation
                WelcomeHeader(
                    icon: "chart.pie.fill",
                    title: "Deal Analysis",
                    subtitle: "Here's your property breakdown"
                )
                
                if viewModel.arvSalePrice > 0 {
                    // Main result cards
                    VStack(spacing: 16) {
                        ResultCard(
                            title: "After Repair Value (ARV)",
                            value: viewModel.arvSalePrice.currencyFormatted,
                            icon: "house.fill",
                            color: Color("AppTeal")
                        )
                        .transition(.scale.combined(with: .opacity))
                        
                        ResultCard(
                            title: "Your Maximum Buy Price",
                            value: viewModel.buyPrice.currencyFormatted,
                            icon: "tag.circle.fill",
                            color: Color("Gold")
                        )
                        .transition(.scale.combined(with: .opacity))
                    }
                    
                    // Breakdown section toggle button
                    Button(action: {
                        withAnimation(.spring()) {
                            showBreakdown.toggle()
                        }
                    }) {
                        HStack {
                            Text(showBreakdown ? "Hide Deal Breakdown" : "Show Deal Breakdown")
                                .font(.system(.headline, design: .rounded))
                                .foregroundColor(Color("NavyBlue"))
                            
                            Image(systemName: showBreakdown ? "chevron.up.circle.fill" : "chevron.down.circle.fill")
                                .foregroundColor(Color("AppTeal"))
                                .font(.system(size: 18))
                        }
                        .padding(.vertical, 10)
                        .padding(.horizontal, 16)
                        .background(
                            RoundedRectangle(cornerRadius: 10)
                                .fill(Color("AppTeal").opacity(0.1))
                        )
                    }
                    .padding(.top, 5)
                    
                    if showBreakdown {
                        // Breakdown section
                        VStack(alignment: .leading, spacing: 16) {
                            HStack {
                                Image(systemName: "list.bullet.clipboard.fill")
                                    .foregroundColor(Color("Gold"))
                                    .font(.system(size: 20))
                                
                                Text("Your Deal Breakdown")
                                    .font(.system(size: 18, weight: .medium, design: .rounded))
                                    .foregroundColor(Color("NavyBlue"))
                            }
                            .padding(.leading, 8)
                            .padding(.bottom, 4)
                            
                            VStack(spacing: 16) {
                                HStack {
                                    Text("ARV Sale Price")
                                        .foregroundColor(Color("NavyBlue").opacity(0.7))
                                        .font(.system(.body, design: .rounded))
                                    Spacer()
                                    Text(viewModel.arvSalePrice.currencyFormatted)
                                        .fontWeight(.medium)
                                        .foregroundColor(Color("NavyBlue"))
                                }
                                
                                breakdownRow(
                                    title: "Rehab Cost",
                                    value: Double(viewModel.rehabCost) ?? 0,
                                    isSubtraction: true
                                )
                                
                                breakdownRow(
                                    title: "Closing Cost",
                                    value: viewModel.closingCost,
                                    isSubtraction: true
                                )
                                
                                breakdownRow(
                                    title: "Carrying Cost",
                                    value: viewModel.carryingCost,
                                    isSubtraction: true
                                )
                                
                                breakdownRow(
                                    title: "Investor's Profit",
                                    value: viewModel.desiredProfit,
                                    isSubtraction: true
                                )
                                
                                breakdownRow(
                                    title: "Your Wholesale Fee",
                                    value: Double(viewModel.desiredWholesaleFee) ?? 0,
                                    isSubtraction: true
                                )
                                
                                // Stylish divider
                                HStack {
                                    Rectangle()
                                        .frame(height: 2)
                                        .foregroundColor(Color("AppTeal").opacity(0.2))
                                    
                                    Image(systemName: "dollarsign.circle.fill")
                                        .foregroundColor(Color("Gold"))
                                        .font(.title3)
                                    
                                    Rectangle()
                                        .frame(height: 2)
                                        .foregroundColor(Color("AppTeal").opacity(0.2))
                                }
                                .padding(.vertical, 5)
                                
                                HStack {
                                    Text("Maximum Buy Price")
                                        .fontWeight(.bold)
                                        .font(.system(.body, design: .rounded))
                                        .foregroundColor(Color("NavyBlue"))
                                    Spacer()
                                    Text(viewModel.buyPrice.currencyFormatted)
                                        .fontWeight(.bold)
                                        .font(.system(.title3, design: .rounded))
                                        .foregroundColor(Color("AppTeal"))
                                }
                            }
                            .padding()
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
                        .transition(.move(edge: .top).combined(with: .opacity))
                    }
                } else {
                    // No results view
                    TipCard(
                        title: "Ready When You Are!",
                        content: "Fill in your property details to see your results here. We'll help you crunch the numbers!",
                        primaryColor: Color("AppTeal"),
                        secondaryColor: Color("Gold"),
                        icon: "lightbulb.fill"
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
                Text("Results")
                    .font(.system(.title2, design: .rounded))
                    .fontWeight(.bold)
                    .foregroundColor(Color("NavyBlue"))
            }
        }
        .hideKeyboardWhenTappedAround()
    }
    
    private func breakdownRow(title: String, value: Double, isSubtraction: Bool = false) -> some View {
        HStack {
            HStack(spacing: 4) {
                if isSubtraction {
                    Text("-")
                        .foregroundColor(Color("Gold").opacity(0.9))
                        .font(.system(.body, design: .rounded))
                }
                Text(title)
                    .foregroundColor(
                        isSubtraction ? Color("NavyBlue").opacity(0.7) : Color("NavyBlue")
                    )
                    .font(.system(.body, design: .rounded))
            }
            Spacer()
            Text(value.currencyFormatted)
                .foregroundColor(
                    isSubtraction ? Color("Gold").opacity(0.9) : Color("NavyBlue")
                )
                .font(.system(.body, design: .rounded))
        }
    }
}

struct ResultsView_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            NavigationView {
                ResultsView(viewModel: AppViewModel())
            }
            .preferredColorScheme(.light)
            .previewDisplayName("Light Mode")
            
            NavigationView {
                ResultsView(viewModel: AppViewModel())
            }
            .preferredColorScheme(.dark)
            .previewDisplayName("Dark Mode")
        }
    }
}
