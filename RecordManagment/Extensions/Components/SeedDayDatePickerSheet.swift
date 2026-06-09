import SwiftUI

struct SeedDayDatePickerSheet: View {
    
    // View Properties
    @State private var selection: Date
    @Binding var dateMode: Bool
    @Binding var selectedMonth: Date
    @Binding var datePickerSize: CGSize
    @Binding var title: String
    @Binding var date: Date
    
    init(
        dateMode: Binding<Bool>,
        selectedMonth: Binding<Date>,
        datePickerSize: Binding<CGSize>,
        title: Binding<String>,
        date: Binding<Date>
    ) {
        self._dateMode = dateMode
        self._selectedMonth = selectedMonth
        self._datePickerSize = datePickerSize
        self._title = title
        self._date = date
        self.selection = selectedMonth.wrappedValue
    }
    
    var body: some View {
        VStack(spacing: 24) {
            DatePicker(
                "", // 라벨 텍스트를 빈 문자열로
                selection: $selection,
                displayedComponents: [.date] // 날짜만 선택
            )
            .datePickerStyle(.wheel)  // Wheel 스타일
            .labelsHidden()           // 라벨 숨김
            .font(.system(size: 28, weight: .bold))
            .frame(maxWidth: .infinity, maxHeight: datePickerSize.height + Calendar.monthHeight)
            .environment(\.locale, Locale(identifier: "ko_KR"))
            .scaleEffect(1.1)
            .clipped()
            
            HStack {
                Button("오늘") {
                    withAnimation {
                        title = Calendar.monthAndYear(from: .now)
                        selectedMonth = .now
                        date = selectedMonth
                        dateMode = false
                    }
                }.seedDaysButtonStyle(type: .success, state: .secondary)
                
                Button("완료") {
                    withAnimation {
                        selectedMonth = selection
                        title = Calendar.monthAndYear(from: selectedMonth)
                        date = selectedMonth
                        dateMode = false
                    }
                }.seedDaysButtonStyle(type: .success, state: .secondary)
            }
        }
        .padding(.vertical, 24)
        .padding(.horizontal)
        .presentationDetents([.fraction(0.4)])
    }
}

#Preview {
    SeedDayDatePickerSheet(
        dateMode: .constant(true),
        selectedMonth: .constant(.now),
        datePickerSize: .constant(CGSize(width: 300, height: 300)),
        title: .constant("2026년 1월"),
        date: .constant(.now)
    )
}
