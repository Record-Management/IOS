import SwiftUI

struct SplashScreen: View {
    var body: some View {
        ZStack {
            Color(.white)
                .ignoresSafeArea()
            Image("SplashLogo")
                .resizable()
                .scaledToFit()
                .frame(width: 128, height: 128)
        }
    }
}

#Preview {
    SplashScreen()
}
