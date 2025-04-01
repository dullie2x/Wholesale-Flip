import SwiftUI

struct SplashPage: View {
    @State private var scale = 0.7
    @State private var opacity = 0.0
    @State private var rotation = 0.0
    @State private var glowOpacity = 0.0
    
    var body: some View {
        ZStack {
            // Background
            Color.black
                .edgesIgnoringSafeArea(.all)
            
            // Animated glow effect
            Image("applogo")
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(width: 180, height: 180)
                .blur(radius: 30)
                .opacity(glowOpacity)
                .scaleEffect(1.2)
            
            // Main logo
            Image("applogo")
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(width: 150, height: 150)
                .scaleEffect(scale)
                .opacity(opacity)
                .rotationEffect(Angle(degrees: rotation))
        }
        .onAppear {
            // Sequence of animations for the logo
            withAnimation(.easeOut(duration: 0.5)) {
                scale = 1.0
                opacity = 1.0
            }
            
            withAnimation(.easeInOut(duration: 0.7).delay(0.3)) {
                rotation = 360.0
            }
            
            // Glow effect animation
            withAnimation(.easeIn(duration: 0.7).delay(0.5)) {
                glowOpacity = 0.5
            }
            
            // Pulse animation after initial animations
            withAnimation(
                .easeInOut(duration: 1.5)
                .repeatForever(autoreverses: true)
                .delay(1.2)
            ) {
                scale = 1.05
                glowOpacity = 0.7
            }
        }
    }
}

// Preview
struct SplashPage_Previews: PreviewProvider {
    static var previews: some View {
        SplashPage()
    }
}
