import SwiftUI

struct ChangeMainHabitRecord: View {
    let cancel: () -> Void
    let action: () -> Void
    
    var body: some View {
        ZStack {
            Color(hex: "#222222").opacity(0.5)
                .ignoresSafeArea()
            
            VStack {
                Text("메인 습관 기록을 변경할까요?")
                    .typography(.p16SemiBold)
                    .padding(.bottom,8)
                Text("연속 달성 기록은 유지된채\n메인 습관의 종류가 변경됩니다.")
                    .typography(.p14Regular)
                    .multilineTextAlignment(.center)
                    .foregroundStyle(Color.Gray._600())
                    .padding(.bottom,8)
                HStack {
                    Text("닫기")
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 14)
                        .background(Color.Gray._100())
                        .foregroundStyle(Color.Gray._400())
                        .clipShape(.rect(cornerRadius: 8))
                        .onTapGesture {
                            cancel()
                        }
                    
                    Text("변경하기")
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 14)
                        .background(Color.Primary.main())
                        .foregroundStyle(.white)
                        .clipShape(.rect(cornerRadius: 8))
                        .onTapGesture {
                            action()
                        }
                }
            }
            .padding()
            .frame(maxWidth: .infinity)
            .toolbarBackgroundVisibility(.hidden, for: .navigationBar)
            .background(
                RoundedRectangle(cornerRadius: 16)
                    .fill(Color.white)
            )
            .padding(.horizontal, 32)
        }
    }
}
