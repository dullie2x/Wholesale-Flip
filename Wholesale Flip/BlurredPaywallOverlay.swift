//import SwiftUI
//
//struct BlurredPaywallOverlay: View {
//    var title: String
//    var message: String
//    var onUpgrade: () -> Void
//    
//    @Environment(\.colorScheme) private var colorScheme
//    
//    var body: some View {
//        ZStack {
//            // Solid black backdrop to completely hide content
//            Rectangle()
//                .fill(Color("NavyBlue"))
//            
//            // Content
//            VStack(spacing: 25) {
//                Image(systemName: "lock.circle.fill")
//                    .font(.system(size: 60))
//                    .foregroundColor(Color("Gold"))
//                
//                Text(title)
//                    .font(.system(size: 24, weight: .bold, design: .rounded))
//                    .foregroundColor(.white)
//                    .multilineTextAlignment(.center)
//                
//                Text(message)
//                    .font(.system(size: 16, design: .rounded))
//                    .foregroundColor(.white.opacity(0.8))
//                    .multilineTextAlignment(.center)
//                    .padding(.horizontal, 30)
//                
//                Button(action: onUpgrade) {
//                    HStack {
//                        Image(systemName: "star.fill")
//                            .font(.system(size: 16))
//                        
//                        Text("Upgrade to Premium")
//                            .font(.system(size: 17, weight: .medium, design: .rounded))
//                    }
//                    .foregroundColor(.white)
//                    .padding(.horizontal, 30)
//                    .padding(.vertical, 14)
//                    .background(
//                        LinearGradient(
//                            gradient: Gradient(colors: [Color("Gold"), Color("Gold").opacity(0.8)]),
//                            startPoint: .topLeading,
//                            endPoint: .bottomTrailing
//                        )
//                    )
//                    .cornerRadius(15)
//                    .shadow(color: Color("Gold").opacity(0.4), radius: 5, x: 0, y: 3)
//                }
//                .padding(.top, 10)
//            }
//            .padding(40)
//        }
//        .edgesIgnoringSafeArea(.all)
//    }
//}
