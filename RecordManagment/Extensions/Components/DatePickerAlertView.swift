import SwiftUI

struct DatePickerAlertView: View {
    @Binding var selection: Date
    let title: String
    let cancel: () -> Void
    let update: () -> Void
    
    var body: some View {
        ZStack {
            Color(hex: "#222222").opacity(0.5)
                .ignoresSafeArea()
            VStack(spacing: 24) {
                Text(title)
                    .typography(.p18SemiBold)
                DatePicker(
                    "", // 라벨 텍스트를 빈 문자열로
                    selection: $selection,
                    displayedComponents: [.date] // 날짜만 선택
                )
                .datePickerStyle(.wheel)  // Wheel 스타일
                .labelsHidden()           // 라벨 숨김
                .font(.system(size: 28, weight: .bold))
                .frame(maxWidth: .infinity)
                .environment(\.locale, Locale(identifier: "ko_KR"))
                .scaleEffect(1.1)
                .clipped()
                buttons
            }
            .padding(.horizontal)
            .padding(.vertical, 24)
            .frame(maxWidth: .infinity)
            .background(
                RoundedRectangle(cornerRadius: 16)
                    .fill(Color.white)
            )
            .padding(.horizontal, 32)
        }
    }
    
    private var buttons: some View {
        HStack {
            Button("취소") {
                cancel()
            }.seedDaysButtonStyle(type: .normal, state: .secondary)
            
            Button("수정하기") {
                update()
            }.seedDaysButtonStyle(type: .success, state: .primary)
        }
    }
}


#Preview {
    DatePickerAlertView(
        selection: .constant(.now),
        title: "생일 수정",
        cancel: {},
        update: {}
    )
}
