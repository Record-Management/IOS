import SwiftUI

// MARK: - 특정 ScrollView만 바운스를 끄기 위한 Helper
struct ScrollBounceModifier: UIViewRepresentable {
    let bounces: Bool
    
    func makeUIView(context: Context) -> UIView {
        let view = UIView()
        DispatchQueue.main.async {
            var parent = view.superview
            while parent != nil {
                if let scrollView = parent as? UIScrollView {
                    scrollView.bounces = bounces
                    break
                }
                parent = parent?.superview
            }
        }
        return view
    }
    
    func updateUIView(_ uiView: UIView, context: Context) {}
}
