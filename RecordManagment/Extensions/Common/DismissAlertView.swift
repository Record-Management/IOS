import SwiftUI

struct DismissAlertView: View {
    @EnvironmentObject var coordinator: Coordinator
    @Binding var isDismiss: Bool
    @Binding var isEditing: Bool
    @Binding var isDeleting: Bool
    
    var body: some View {
        ZStack {
            Color(hex: "#222222").opacity(0.5)
                .ignoresSafeArea()
            
            VStack {
                Text(isDeleting ? "기록을 삭제하시겠습니까?" : "기록을 남기지 않고 나가시겠습니까?")
                    .typography(.p16SemiBold)
                    .padding(.bottom,8)
                Text("작성 중인 기록은 저장되지 않아요.")
                    .typography(.p14Regular)
                    .padding(.bottom, 16)
                HStack(spacing: 10) {
                    Text(isDeleting ? "취소" : "나가기")
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                        .background(Color.Gray._100())
                        .foregroundStyle(Color.Gray._400())
                        .clipShape(.rect(cornerRadius: 8))
                        .onTapGesture {
                            isDismiss = false
                            if !isDeleting {
                                coordinator.dismissScreen()
                            }
                            isDeleting = false
                        }
                    Text(isDeleting ? "삭제하기" : "작성하기")
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                        .background(Color.Primary.main())
                        .foregroundStyle(.white)
                        .clipShape(.rect(cornerRadius: 8))
                        .onTapGesture {
                            isDismiss = false
                            if isDeleting {
                                // 삭제기능 넣을 것
                                coordinator.pop()
                                isDeleting = false
                            }
                        }
                }
                .frame(maxWidth: .infinity, maxHeight: 52)
            }
            .padding()
            .frame(maxWidth: .infinity)
            .background(
                RoundedRectangle(cornerRadius: 16)
                    .fill(Color.white)
            )
            .padding(.horizontal, 32)
            .toolbarBackgroundVisibility(.hidden, for: .navigationBar)
        }
    }
}
