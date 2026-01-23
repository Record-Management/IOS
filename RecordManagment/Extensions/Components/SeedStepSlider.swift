import SwiftUI

struct SeedStepSlider: View {
    @State private var step: SeedStep = .stage1
    
    // TODO: 전체 배경 색상
    var backgroundColor: Color {
        Color(hex: "#F8F8F8")
    }
    
    var body: some View {
        HStack {
            ForEach(Array(step.currentStep.enumerated()), id: \.offset) { index, step in
                
                let outerSize: CGFloat = step.point ? 36 : 22

                Circle()
                    .fill(backgroundColor)
                    .frame(width: outerSize, height: outerSize)
                    .overlay {
                        if let iconName = step.iconName {
                            let iconSize: CGFloat = step.point ? 24 : 16
                            GeometryReader { geo in
                                let size = geo.size
                                
                                Circle()
                                    .fill(.white)
                                    .frame(width: outerSize, height: outerSize)
                                    .overlay {
                                        ZStack {
                                            Image(iconName)
                                                .resizable()
                                                .scaledToFit()
                                                .frame(width: iconSize, height: iconSize)
                                                .overlay {
                                                    if step.point {
                                                        let info = geo.frame(in: .global)
                                                        let tipY = info.maxY - info.minY + 6 // 툴팁 위치 값 y
                                                        
                                                        Rectangle()
                                                            .fill(.blue)
                                                            .frame(width: 73, height: 32)
                                                            .offset(y: -tipY)
                                                    }
                                                }
                                        }
                                        .frame(width: size.width, height: size.height)
                                }
                            }
                        }
                    }

                if index != 3 {
                    Spacer()
                }
            }
        }
        .frame(maxWidth: .infinity) 
        .background(
            Rectangle()
                .fill(backgroundColor)
                .frame(height: 8)
        )
    }
}

#Preview {
    SeedStepSlider()
        .frame(maxHeight: .infinity)
        .padding(.horizontal, 33)
        .background(.black)
}
