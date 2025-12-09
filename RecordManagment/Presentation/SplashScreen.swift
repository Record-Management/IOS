import SwiftUI

struct SplashScreen: View {
    var body: some View {
        ZStack {
            Color(.white)
                .ignoresSafeArea()
            Image("SplashLogo")
                .resizable()
                .scaledToFit()
                .frame(width: 64, height: 64)
        }
    }
}

#Preview {
    SplashScreen()
}
