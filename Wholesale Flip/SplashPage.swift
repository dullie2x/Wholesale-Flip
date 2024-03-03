import SwiftUI

struct SplashPage: View {
    var body: some View {
        ZStack {
            Color.black
                .edgesIgnoringSafeArea(.all)

            Image("applogo")
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(width: 150, height: 150)
        }
    }
}

// Preview
struct SplashPage_Previews: PreviewProvider {
    static var previews: some View {
        SplashPage()
    }
}
