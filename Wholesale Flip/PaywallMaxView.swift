import SwiftUI

struct PaywallMaxView: View {
    @Environment(\.dismiss) var dismiss
    @State private var animate = false
    // No ad view needed

    var body: some View {
        ZStack {
            // Background gradient - using a more urgent color scheme
            LinearGradient(
                gradient: Gradient(colors: [Color("Gold").opacity(0.9), Color("NavyBlue").opacity(0.8)]),
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .edgesIgnoringSafeArea(.all)
            
            VStack(spacing: 15) {
                // Close Button (Top-Right)
                HStack {
                    Spacer()
                    Button(action: { dismiss() }) {
                        Image(systemName: "xmark.circle.fill")
                            .resizable()
                            .frame(width: 30, height: 30)
                            .foregroundColor(.white.opacity(0.2))
                            .shadow(radius: 5)
                    }
                    .padding(.top, 10)
                    .padding(.trailing, 15)
                }
                
                // App Logo with alert icon
                ZStack {
                    Image("applogo")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 160, height: 160)
                        .padding(.vertical, 5)
                    
                    // Alert badge
                    Image(systemName: "exclamationmark.circle.fill")
                        .font(.system(size: 40))
                        .foregroundColor(Color("AppTeal"))
                        .background(Circle().fill(Color.white))
                        .offset(x: 60, y: -55)
                        .shadow(color: Color.black.opacity(0.2), radius: 4, x: 0, y: 2)
                }
                
                // Title & Subtitle - more urgent messaging
                VStack(spacing: 8) {
                    Text("Maximum Limit Reached!")
                        .font(.system(size: 22, weight: .heavy, design: .rounded))
                        .foregroundColor(.white)
                        .shadow(radius: 5)
                        .multilineTextAlignment(.center)
                    
                    Text("You've reached the maximum free calculations.\nUpgrade now to continue your property analysis.")
                        .font(.system(size: 16, weight: .medium, design: .rounded))
                        .foregroundColor(.white.opacity(0.9))
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, 20)
                        .padding(.vertical, 5)
                }

                // Pricing Option - enhanced with "most popular" tag
                VStack {
                    Text("MOST POPULAR")
                        .font(.system(size: 12, weight: .bold, design: .rounded))
                        .foregroundColor(Color("NavyBlue"))
                        .padding(.horizontal, 12)
                        .padding(.vertical, 4)
                        .background(
                            Capsule()
                                .fill(Color("Gold"))
                        )
                        .offset(y: 10)
                        .zIndex(1)
                    
                    PaywallOption(
                        title: "Premium Access",
                        price: "$0.99 / Month",
                        features: [
                            "Unlimited calculations",
                            "No advertisements",
                            "All future updates"
                        ],
                        highlight: true,
                        animate: $animate
                    ) {
                        // Purchase logic for Monthly Plan
                    }
                    .padding(.horizontal, 20)
                }

                // Enhanced CTA
                Text("Unlock your full potential as a property investor!")
                    .font(.system(size: 14, weight: .medium, design: .rounded))
                    .foregroundColor(.white.opacity(0.9))
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 40)
                    .padding(.top, 5)
                
                // Terms & Restore Purchase
                VStack(spacing: 5) {
                    Button("Restore Purchase") {
                        // Restore purchases logic
                    }
                    .font(.system(size: 15, weight: .medium, design: .rounded))
                    .foregroundColor(.white.opacity(0.8))
                    
                    Text("By subscribing, you agree to our Terms & Conditions.")
                        .font(.system(size: 13, design: .rounded))
                        .foregroundColor(.white.opacity(0.7))
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, 40)
                }
                .padding(.top, 10)
                
                Spacer()
            }
            .padding(.top, 10)
        }
        .onAppear { animate.toggle() }
        .interactiveDismissDisabled(true) // Prevents swipe-down dismissal
    }
}

// PaywallOption component remains the same but with updated accent colors
struct PaywallMaxOption: View {
    let title: String
    let price: String
    let features: [String]
    let highlight: Bool
    @Binding var animate: Bool
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
                            .foregroundColor(Color("AppTeal"))
                    }
                    
                    Spacer()
                    
                    if highlight {
                        Image(systemName: "checkmark.seal.fill")
                            .font(.system(size: 20))
                            .foregroundColor(Color("AppTeal"))
                            .scaleEffect(animate ? 1.2 : 1.0)
                            .animation(.easeInOut(duration: 1).repeatForever(), value: animate)
                    }
                }
                
                // Features list
                VStack(alignment: .leading, spacing: 8) {
                    ForEach(features, id: \.self) { feature in
                        HStack(spacing: 10) {
                            Image(systemName: "checkmark.circle.fill")
                                .foregroundColor(Color("Gold"))
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
                    Text("Upgrade Now")
                        .font(.system(size: 16, weight: .bold, design: .rounded))
                        .foregroundColor(Color("NavyBlue"))
                        .padding(.vertical, 12)
                        .padding(.horizontal, 30)
                        .background(Color("AppTeal"))
                        .cornerRadius(25)
                        .shadow(color: Color("AppTeal").opacity(0.4), radius: 5, x: 0, y: 2)
                    Spacer()
                }
                .padding(.top, 5)
            }
            .padding()
            .background(
                RoundedRectangle(cornerRadius: 16)
                    .fill(Color("NavyBlue").opacity(0.5))
                    .overlay(
                        RoundedRectangle(cornerRadius: 16)
                            .stroke(Color("Gold").opacity(0.3), lineWidth: 1)
                    )
                    .shadow(color: Color("NavyBlue").opacity(0.5), radius: 10, x: 0, y: 5)
            )
            .scaleEffect(animate ? 1.03 : 1.0)
            .animation(.easeInOut(duration: 1.5).repeatForever(autoreverses: true), value: animate)
        }
    }
}

struct PaywallMaxView_Previews: PreviewProvider {
    static var previews: some View {
        PaywallMaxView()
    }
}
