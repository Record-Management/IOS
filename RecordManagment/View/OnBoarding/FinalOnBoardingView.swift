//
//  SectionLastView.swift
//  RecordManagment
//
//  Created by 김용해 on 8/15/25.
//

import SwiftUI

struct FinalOnBoardingView: View {
    @State private var fillLevel: CGFloat = 0.0
    @State private var isAnimationComplete = false
    
    var body: some View {
        VStack {
            Spacer().frame(height: 56)
            
            Group {
                if isAnimationComplete {
                    // 최종 상태: 완벽한 단일 이미지
                    Image(systemName: "drop.fill")
                        .resizable()
                        .scaledToFit()
                        .foregroundStyle(Color.blue)
                } else {
                    // 애니메이션 상태: ZStack과 Rectangle 마스크를 사용
                    ZStack {
                        // 배경 (비어있는 물방울)
                        Image(systemName: "drop.fill")
                            .resizable()
                            .scaledToFit()
                            .foregroundStyle(Color.gray.opacity(0.4))

                        // 채워지는 전경
                        Image(systemName: "drop.fill")
                            .resizable()
                            .scaledToFit()
                            .foregroundStyle(Color.blue)
                            .mask(
                                GeometryReader { geometry in
                                    VStack {
                                        Spacer()
                                        Rectangle()
                                            .frame(height: geometry.size.height * fillLevel)
                                    }
                                }
                            )
                    }
                }
            }
            .frame(maxWidth: 112)
            .padding(35)
            
            Text("하루를 채울 준비를 마쳤어요!")
                .font(.system(size: 22, weight: .bold))
                .fontWeight(.bold)
            Spacer()
            
            VStack(alignment: .leading, spacing: 14) {
                infoBox(title: "당신에게 맞는 기록을 준비하고 있어요")
                infoBox(title: "목표를 살펴보고 있어요")
                infoBox(title: "이제 시작할 수 있어요!")
            }
            Spacer()
            Spacer()
            Button(action: {
                print("hello")
            }, label: {
                Text("다음")
                    .frame(maxWidth: .infinity)
                    .padding(14)
                    .background(Color(hex: "8A9BA8"))
                    .foregroundColor(.white)
                    .cornerRadius(8)
            })
        }
        .frame(maxWidth: .infinity)
        .onAppear(perform: animateDrop)
    }
    
    private func infoBox(title: String) -> some View {
        HStack(spacing: 0) {
            Image(systemName: "checkmark.circle.fill")
                .frame(width: 20)
                .foregroundStyle(Color(hex: "8A9BA8"))
                .padding(.trailing, 14)
            Text(title)
                .frame(maxWidth: .infinity, alignment: .leading)
                .font(.system(size: 14))
        }
        .padding(.vertical, 13)
        .padding(.horizontal, 16)
        .background(Color(hex: "F5F5F5"))
        .clipShape(.rect(cornerRadius: 8))
    }

    private func animateDrop() {
        let animationDuration = 2.5
        let delay = 0.1
        
        withAnimation(.easeInOut(duration: animationDuration).delay(delay)) {
            fillLevel = 1.0
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + delay + animationDuration) {
            withAnimation {
                isAnimationComplete = true
            }
        }
    }
}

#Preview {
    FinalOnBoardingView()
        .padding()
}
