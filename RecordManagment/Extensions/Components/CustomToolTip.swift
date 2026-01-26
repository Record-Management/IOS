import SwiftUI

struct CustomToolTip: View {
    let title: String
    
    var body: some View {
        VStack(spacing: 0) {
            RoundedRectangle(cornerRadius: 5.46)
                .fill(.white)
                .frame(width: 73, height: 26)
                .overlay {
                    Text(title)
                        .typography(.p12SemiBold)
                }
            
            ReverseTriangle()
                .foregroundStyle(.white)
                .frame(width: 6, height: 9)
        }
    }
}


struct ReverseTriangle: Shape {
    nonisolated func path(in rect: CGRect) -> Path {
        var path = Path()
        path.move(to: CGPoint(x: rect.minX, y: rect.minY))
        path.addLine(to: CGPoint(x: rect.maxX, y: rect.minY))
        path.addLine(to: CGPoint(x: rect.midX, y: rect.maxY))
        
        return path
    }
}

#Preview {
    CustomToolTip(title: "성장 N단계")
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .scaleEffect(2)
        .background(.black)
}
