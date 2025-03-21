import SwiftUI

struct PaywallView: View {
    @Environment(\.dismiss) var dismiss
    @State private var animate = false
    // No ad view needed

    var body: some View {
        ZStack {
            // Background gradient
            LinearGradient(
                gradient: Gradient(colors: [Color("NavyBlue").opacity(0.9), Color("AppTeal").opacity(0.7)]),
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .edgesIgnoringSafeArea(.all)
            
            VStack(spacing: 15) {  // Reduced spacing between elements
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
                    .padding(.top, 10)  // Reduced top padding
                    .padding(.trailing, 15)
                }
                
                // Removed top Spacer to move content higher
                
                // App Logo
                Image("applogo")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 160, height: 160)  // Reduced size slightly
                    .padding(.vertical, 5)  // Reduced padding
                
                // Title & Subtitle
                VStack(spacing: 8) {  // Reduced spacing
                    Text("Unlimited Property Calculations")
                        .font(.system(size: 20, weight: .heavy, design: .rounded))
                        .foregroundColor(.white)
                        .shadow(radius: 5)
                        .multilineTextAlignment(.center)
                }

                // Pricing Option
                PaywallOption(
                    title: "Premium Access",
                    price: "$0.99 / Month",
                    features: ["Unlimited calculations", "No advertisements", "Support development"],
                    highlight: true,
                    animate: $animate
                ) {
                    // Purchase logic for Monthly Plan
                }
                .padding(.horizontal, 20)

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
                .padding(.top, 15)  // Reduced top padding
                
                Spacer()
            }
            .padding(.top, 10)  // Added padding to the entire VStack to move content up
        }
        .onAppear { animate.toggle() }
        .interactiveDismissDisabled(true) // Prevents swipe-down dismissal
    }
}

// Feature item component
struct FeatureItem: View {
    let icon: String
    let text: String
    
    var body: some View {
        VStack(spacing: 5) {
            Image(systemName: icon)
                .font(.system(size: 18))
                .foregroundColor(Color("AppTeal"))
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
                            .foregroundColor(Color("Gold"))
                    }
                    
                    Spacer()
                    
                    if highlight {
                        Image(systemName: "star.fill")
                            .font(.system(size: 20))
                            .foregroundColor(Color("Gold"))
                            .scaleEffect(animate ? 1.2 : 1.0)
                            .animation(.easeInOut(duration: 1).repeatForever(), value: animate)
                    }
                }
                
                // Features list
                VStack(alignment: .leading, spacing: 8) {
                    ForEach(features, id: \.self) { feature in
                        HStack(spacing: 10) {
                            Image(systemName: "checkmark.circle.fill")
                                .foregroundColor(Color("AppTeal"))
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
                    Text("Subscribe Now")
                        .font(.system(size: 16, weight: .bold, design: .rounded))
                        .foregroundColor(Color("NavyBlue"))
                        .padding(.vertical, 12)
                        .padding(.horizontal, 30)
                        .background(Color("Gold"))
                        .cornerRadius(25)
                        .shadow(color: Color("Gold").opacity(0.4), radius: 5, x: 0, y: 2)
                    Spacer()
                }
                .padding(.top, 5)
            }
            .padding()
            .background(
                RoundedRectangle(cornerRadius: 16)
                    .fill(Color("NavyBlue").opacity(0.3))
                    .overlay(
                        RoundedRectangle(cornerRadius: 16)
                            .stroke(Color("AppTeal").opacity(0.3), lineWidth: 1)
                    )
                    .shadow(color: Color("NavyBlue").opacity(0.5), radius: 10, x: 0, y: 5)
            )
            .scaleEffect(animate ? 1.03 : 1.0)
            .animation(.easeInOut(duration: 1.5).repeatForever(autoreverses: true), value: animate)
        }
    }
}

struct PaywallView_Previews: PreviewProvider {
    static var previews: some View {
        PaywallView()
    }
}
