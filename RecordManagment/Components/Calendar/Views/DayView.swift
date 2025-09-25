import SwiftUI

struct DayView: View {
    let cell: DayCell
    @Binding var selectedDate: Date
    @Binding var currentRecord: DropDownFilter
    @Binding var calendarRecord: CalendarRecord
    
    private var recordsForThisDate: [DropDownFilter] {
        guard let monthlyRecords = calendarRecord.data?.monthlyRecords else { return [] }
        guard let data = monthlyRecords.first(where: {
            Calendar.current.isDate(cell.date, inSameDayAs: Date.convertDateForIntArray($0.date) ?? .now)
        }) else { return [] }
        return data.records.map { DropDownFilter.matchingType(type: $0.type) }
    }
    
    var body: some View {
        VStack {
            Text("\(Calendar.current.component(.day, from: cell.date))")
                .typography(.p12Medium)
                .foregroundStyle(
                    Calendar.current.isDate(cell.date, inSameDayAs: selectedDate) ? .white : .black)
                .padding(.horizontal, 8)
                .background(
                    Calendar.current.isDate(cell.date, inSameDayAs: selectedDate) ? Color.Primary.main() : .clear
                )
                .clipShape(.rect(cornerRadius: 100))
            readRecords()
        }
        .frame(height: 80, alignment: .top)
        .frame(maxWidth: .infinity)
        .onTapGesture {
            withAnimation(.easeInOut) {
                self.selectedDate = cell.date
            }
        }
    }
    
    // TODO: 기록 이미지가 있다면 반환하는 함수
    @ViewBuilder
    private func readRecords() -> some View {
        let records = recordsForThisDate
        switch records.count {
        case 0:
            EmptyView()
        case 1:
            if let firstRecord = records.first {
                if currentRecord == .all || currentRecord == firstRecord {
                    Image(firstRecord.getImage())
                        .resizable()
                        .scaledToFit()
                        .frame(maxWidth: 24, maxHeight: 24)
                }
            }
        default:
            if currentRecord == .all {
                if let findDayRecord = records.first(where: { $0 == .daily }) {
                    multipleRecords(for: findDayRecord.getImage())
                } else {
                    multipleRecords(for: "None_DayRecord")
                }
            } else {
                if let record = records.first(where: { $0 == currentRecord}) {
                    multipleRecords(for: record.getImage(), several: false)
                }
            }
        }
    }
    
    /// ** 복잡한 연산 로직을 함수로 분리하기 위함
    /// parameter
    /// - icon: 각 FilterDown 타입에 맞는 이미지 이름값
    /// - several: 다중 기록의 유무를 표시하는 Bool 값
    private func multipleRecords(for icon: String, several: Bool = true) -> some View {
        Image(icon)
        .resizable()
        .scaledToFit()
        .frame(maxWidth: 24, maxHeight: 24)
        .overlay(alignment: .topTrailing) {
            if several {
                Circle()
                    .fill(.red)
                    .frame(width: 6, height: 6)
                    .offset(x: 4.5, y : 1)
            }
        }
    }
}

#Preview {
    DayView(
        cell: DayCell(date: .now),
        selectedDate: .constant(.now),
        currentRecord: .constant(.all),
        calendarRecord: .constant(CalendarRecord(statusCode: 200, code: "1", message: "Test Message", data: nil))
    )
}
