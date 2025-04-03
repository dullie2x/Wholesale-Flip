import SwiftUI

struct PaywallView: View {
    @Environment(\.dismiss) var dismiss
    @Environment(\.colorScheme) private var colorScheme
    @State private var animate = false
    @State private var showThankYou = false
    @State private var isPremiumUser: Bool = false
    @State private var isProcessing = false
    
    var body: some View {
        ZStack {
            // Adjust gradient colors based on color scheme
            LinearGradient(
                gradient: Gradient(colors: [
                    colorScheme == .dark
                        ? Color("NavyBlue").opacity(0.7)
                        : Color("NavyBlue").opacity(0.9),
                    colorScheme == .dark
                        ? Color("AppTeal").opacity(0.5)
                        : Color("AppTeal").opacity(0.7)
                ]),
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .edgesIgnoringSafeArea(.all)

            VStack(spacing: 15) {
                HStack {
                    Spacer()
                    Button(action: { dismiss() }) {
                        Image(systemName: "xmark.circle.fill")
                            .resizable()
                            .frame(width: 30, height: 30)
                            .foregroundColor(.white.opacity(0.3))
                            .shadow(radius: 3)
                    }
                    .padding(.top, 10)
                    .padding(.trailing, 15)
                }

                Image("applogo")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 160, height: 160)
                    .padding(.vertical, 5)

                VStack(spacing: 8) {
                    Text("Unlimited Property Calculations")
                        .font(.system(size: 20, weight: .heavy, design: .rounded))
                        .foregroundColor(.white)
                        .shadow(radius: colorScheme == .dark ? 2 : 5)
                        .multilineTextAlignment(.center)
                }

                PaywallOption(
                    title: "Premium Access",
                    price: "$0.99 / Month",
                    features: ["Unlimited calculations", "No advertisements", "Support development"],
                    highlight: true,
                    animate: $animate,
                    isProcessing: isProcessing,
                    colorScheme: colorScheme
                ) {
                    Task {
                        // No longer blocking the flow for premium users — Apple handles it gracefully
                        await MainActor.run {
                            isProcessing = true
                        }

                        if let product = SubscriptionManager.shared.products.first(where: { $0.id == "com.Wholesaleflip.premium.monthly" }) {
                            await SubscriptionManager.shared.purchase(product: product)
                            await SubscriptionManager.shared.verifySubscriptions()

                            await MainActor.run {
                                isProcessing = false

                                if SubscriptionManager.shared.purchasedProductIDs.contains("com.Wholesaleflip.premium.monthly") {
                                    showThankYou = true
                                    DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
                                        dismiss()
                                    }
                                }
                            }
                        } else {
                            await MainActor.run {
                                isProcessing = false
                            }
                        }
                    }
                }
                .disabled(isProcessing)
                .opacity(isProcessing ? 0.6 : 1.0)
                .padding(.horizontal, 20)



                VStack(spacing: 5) {
                    Button("Restore Purchase") {
                        Task {
                            await MainActor.run {
                                isProcessing = true
                            }
                            
                            await SubscriptionManager.shared.restore()
                            
                            try? await Task.sleep(nanoseconds: 500_000_000)
                            
                            await MainActor.run {
                                isProcessing = false
                                
                                if SubscriptionManager.shared.purchasedProductIDs.contains("com.Wholesaleflip.premium.monthly") {
                                    showThankYou = true
                                    
                                    DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
                                        dismiss()
                                    }
                                }
                            }
                        }
                    }
                    .disabled(isProcessing)
                    .opacity(isProcessing ? 0.6 : 1.0)
                    .font(.system(size: 15, weight: .medium, design: .rounded))
                    .foregroundColor(.white.opacity(0.8))


                    (
                        Text("Terms of Use")
                            .font(.system(size: 13, design: .rounded))
                            .foregroundColor(.black) // You can change this to match your theme
                            .underline()
                    )
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 40)
                    .onTapGesture {
                        if let url = URL(string: "https://www.apple.com/legal/internet-services/itunes/dev/stdeula/") {
                            UIApplication.shared.open(url)
                        }
                    }

                }
                .padding(.top, 15)

                Spacer()
            }
            .padding(.top, 10)

            if showThankYou {
                VStack {
                    Spacer()
                    Text("🎉 Thank you for subscribing!")
                        .font(.system(size: 14, weight: .semibold, design: .rounded))
                        .foregroundColor(.white)
                        .padding(.horizontal, 20)
                        .padding(.vertical, 12)
                        .background(
                            colorScheme == .dark
                                ? Color.green.opacity(0.7)
                                : Color.green.opacity(0.8)
                        )
                        .cornerRadius(20)
                        .shadow(radius: colorScheme == .dark ? 2 : 5)
                        .padding(.bottom, 40)
                        .transition(.move(edge: .bottom).combined(with: .opacity))
                        .animation(.easeOut(duration: 0.3), value: showThankYou)
                }
            }
            
            if isProcessing {
                Color.black.opacity(colorScheme == .dark ? 0.5 : 0.4)
                    .edgesIgnoringSafeArea(.all)
                
                VStack {
                    ProgressView()
                        .scaleEffect(1.5)
                        .tint(.white)
                    
                    Text("Processing...")
                        .font(.system(size: 16, weight: .medium, design: .rounded))
                        .foregroundColor(.white)
                        .padding(.top, 10)
                }
            }
        }
        .onAppear {
            animate.toggle()
            
            // Get current subscription status when view appears
            Task {
                await SubscriptionManager.shared.verifySubscriptions()
                
                // Update our local state based on the subscription manager
                await MainActor.run {
                    isPremiumUser = SubscriptionManager.shared.purchasedProductIDs.contains("com.Wholesaleflip.premium.monthly")
                }
            }
        }
        .interactiveDismissDisabled(true)
    }
}


// Feature item component
struct FeatureItem: View {
    let icon: String
    let text: String
    let colorScheme: ColorScheme
    
    var body: some View {
        VStack(spacing: 5) {
            Image(systemName: icon)
                .font(.system(size: 18))
                .foregroundColor(
                    colorScheme == .dark
                        ? Color("AppTeal").opacity(0.9)
                        : Color("AppTeal")
                )
            Text(text)
                .font(.system(size: 12, design: .rounded))
                .foregroundColor(.white)
                .multilineTextAlignment(.center)
        }
        .frame(minWidth: 0, maxWidth: .infinity)
    }
}

// Paywall Option Button
struct PaywallOption: View {
    let title: String
    let price: String
    let features: [String]
    let highlight: Bool
    @Binding var animate: Bool
    var isProcessing: Bool = false
    var colorScheme: ColorScheme
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            VStack(alignment: .leading, spacing: 15) {
                HStack {
                    VStack(alignment: .leading, spacing: 5) {
                        Text(title)
                            .font(.system(size: 20, weight: .bold, design: .rounded))
                            .foregroundColor(.white)
                        
                        Text(price)
                            .font(.system(size: 18, weight: .medium, design: .rounded))
                            .foregroundColor(
                                colorScheme == .dark
                                    ? Color("Gold").opacity(0.9)
                                    : Color("Gold")
                            )
                    }
                    
                    Spacer()
                    
                    if highlight {
                        Image(systemName: "star.fill")
                            .font(.system(size: 20))
                            .foregroundColor(
                                colorScheme == .dark
                                    ? Color("Gold").opacity(0.9)
                                    : Color("Gold")
                            )
                            .scaleEffect(animate ? 1.2 : 1.0)
                            .animation(.easeInOut(duration: 1).repeatForever(), value: animate)
                    }
                }
                
                // Features list
                VStack(alignment: .leading, spacing: 8) {
                    ForEach(features, id: \.self) { feature in
                        HStack(spacing: 10) {
                            Image(systemName: "checkmark.circle.fill")
                                .foregroundColor(
                                    colorScheme == .dark
                                        ? Color("AppTeal").opacity(0.9)
                                        : Color("AppTeal")
                                )
                                .font(.system(size: 16))
                            
                            Text(feature)
                                .font(.system(size: 15, design: .rounded))
                                .foregroundColor(.white.opacity(0.9))
                        }
                    }
                }
                
                // Subscribe button
                HStack {
                    Spacer()
                    
                    if isProcessing {
                        ProgressView()
                            .tint(Color("NavyBlue"))
                            .padding(.vertical, 12)
                            .padding(.horizontal, 30)
                    } else {
                        Text("Subscribe Now")
                            .font(.system(size: 16, weight: .bold, design: .rounded))
                            .foregroundColor(Color("NavyBlue"))
                            .padding(.vertical, 12)
                            .padding(.horizontal, 30)
                            .background(
                                colorScheme == .dark
                                    ? Color("Gold").opacity(0.9)
                                    : Color("Gold")
                            )
                            .cornerRadius(25)
                            .shadow(
                                color: Color("Gold").opacity(colorScheme == .dark ? 0.3 : 0.4),
                                radius: colorScheme == .dark ? 3 : 5,
                                x: 0,
                                y: 2
                            )
                    }
                    
                    Spacer()
                }
                .padding(.top, 5)
            }
            .padding()
            .background(
                RoundedRectangle(cornerRadius: 16)
                    .fill(
                        colorScheme == .dark
                            ? Color("NavyBlue").opacity(0.2)
                            : Color("NavyBlue").opacity(0.3)
                    )
                    .overlay(
                        RoundedRectangle(cornerRadius: 16)
                            .stroke(
                                colorScheme == .dark
                                    ? Color("AppTeal").opacity(0.2)
                                    : Color("AppTeal").opacity(0.3),
                                lineWidth: 1
                            )
                    )
                    .shadow(
                        color: Color("NavyBlue").opacity(colorScheme == .dark ? 0.3 : 0.5),
                        radius: colorScheme == .dark ? 5 : 10,
                        x: 0,
                        y: 5
                    )
            )
            .scaleEffect(animate && !isProcessing ? 1.03 : 1.0)
            .animation(.easeInOut(duration: 1.5).repeatForever(autoreverses: true), value: animate && !isProcessing)
        }
        .disabled(isProcessing)
    }
}

// Preview Provider
struct PaywallView_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            PaywallView()
                .previewDisplayName("Light Mode")
            
            PaywallView()
                .preferredColorScheme(.dark)
                .previewDisplayName("Dark Mode")
        }
    }
}
