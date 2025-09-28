import SwiftUI

// Helper for specific corner radius
extension View {
    func cornerRadius(_ radius: CGFloat, corners: UIRectCorner) -> some View {
        clipShape( RoundedCorner(radius: radius, corners: corners) )
    }
}

struct RoundedCorner: Shape {
    var radius: CGFloat = .infinity
    var corners: UIRectCorner = .allCorners

    func path(in rect: CGRect) -> Path {
        let path = UIBezierPath(roundedRect: rect, byRoundingCorners: corners, cornerRadii: CGSize(width: radius, height: radius))
        return Path(path.cgPath)
    }
}

// View ContentShape min Size 44pt
extension View {
    func higBackSize() -> some View {
        self
            .padding([.bottom, .trailing, .top])
            .contentShape(Rectangle())
    }
    
    // FullScreenCover dismiss Button
    func higFullScreenBackSize() -> some View {
        self
            .padding([.top, .bottom, .leading])
            .contentShape(Rectangle())
    }
}
