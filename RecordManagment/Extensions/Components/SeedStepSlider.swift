import SwiftUI

struct SeedStepSlider: View {
    var stage: SeedStep
    
    // TODO: 전체 배경 색상
    var backgroundColor: Color {
        Color(hex: "#F8F8F8")
    }
    
    var body: some View {
        HStack {
            ForEach(Array(stage.currentStep.enumerated()), id: \.offset) { index, step in
                
                let outerSize: CGFloat = step.point ? 36 : 22

                Circle()
                    .fill(backgroundColor)
                    .frame(width: outerSize, height: outerSize)
                    .overlay {
                        if let iconName = step.iconName {
                            let iconSize: CGFloat = step.point ? 24 : 16
                            GeometryReader { geo in
                                Circle()
                                    .fill(.white)
                                    .frame(width: outerSize, height: outerSize)
                                    .overlay {
                                        seedView(
                                            name: iconName,
                                            iconSize: iconSize,
                                            point: step.point,
                                            geo: geo,
                                            toolTipText: stage.currentToolTipText
                                        )
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


// MARK: 성장 단계별 이미지 및 ToolTip View
extension SeedStepSlider {
    func seedView(
        name iconName: String,
        iconSize: CGFloat,
        point: Bool,
        geo: GeometryProxy,
        toolTipText: String?,
    ) -> some View {
        let size = geo.size
        
        return ZStack {
            Image(iconName)
                .resizable()
                .scaledToFit()
                .frame(width: iconSize, height: iconSize)
                .overlay {
                    if let text = toolTipText {
                        if point {
                            let info = geo.frame(in: .global)
                            let tipY = info.maxY - info.minY + 6 // 툴팁 위치 값 y
                            
                            CustomToolTip(title: text)
                                .offset(y: -tipY)
                        }
                    }
                }
        }
        .frame(width: size.width, height: size.height)
    }
}

#Preview {
    SeedStepSlider(stage: .stage1)
        .frame(maxHeight: .infinity)
        .padding(.horizontal, 33)
        .background(.black)
}
