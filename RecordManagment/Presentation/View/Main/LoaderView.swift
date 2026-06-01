import SwiftUI

struct LoaderView: View {
    @State private var navHeight: CGFloat = .zero
    @Binding var isShow: Bool

    init(isShow: Binding<Bool>) {
        self._isShow = isShow
    }
    
    var body: some View {
        
        GeometryReader { geo in
            let size: CGSize = geo.size
            ZStack {
                Color.white.ignoresSafeArea()
                
                NavigationBarProxy { _, bar, _ in
                    navHeight = bar.bounds.height
                }
                
                Image("Loader")
                    .resizable()
                    .frame(width: 80, height: 80)
                    .position(x: size.width / 2, y: size.height * 0.45 - navHeight)
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
        }
        .task {
            try? await Task.sleep(for: .seconds(0.3))
            isShow = false
        }
    }
}

#Preview {
    NavigationView {
        LoaderView(
            isShow: .constant(true)
        )
    }
}
