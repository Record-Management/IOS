import SwiftUI

struct DayView: View {
    let cell: DayCell
    @Binding var selectedDate: Date
    @Binding var currentRecord: DropDownFilter
    @Binding var calendarRecord: CalendarRecord
    let monthDate: Date
    
    typealias RecordType = (type: DropDownFilter, isCompleted: Bool?)
    
    private var isDifferentMonth: Bool {
        !Calendar.isSameMonth(cell.date, monthDate)
    }
    
    private var recordsAndMainTypeForThisDate: ([RecordType], DropDownFilter) {
        guard let monthlyRecords = calendarRecord.data?.monthlyRecords else { return ([], .all) }
        guard let data = monthlyRecords.first(where: {
            Calendar.current.isDate(cell.date, inSameDayAs: Date.convertDateForIntArray($0.date) ?? .now)
        }) else { return ([], .all) }
        let mainType = DropDownFilter.matchingType(type: data.mainRecordTypeForDate ?? "")
        let records: [RecordType] = data.records.map { (type: DropDownFilter.matchingType(type: $0.type), isCompleted: $0.isCompleted) }
        return (records, mainType)
    }
    
    var body: some View {
        VStack {
            Text("\(Calendar.current.component(.day, from: cell.date))")
                .typography(.p12Medium)
                .foregroundStyle(
                    isDifferentMonth ? Color.Gray._300() :
                    (Calendar.current.isDate(cell.date, inSameDayAs: selectedDate) ? .white : .black)
                )
                .padding(.horizontal, 8)
                .background(
                    Calendar.current.isDate(cell.date, inSameDayAs: selectedDate) ? Color.Primary.main() : .clear
                )
                .clipShape(.rect(cornerRadius: 100))
            
            if !isDifferentMonth {
                readRecords()
            }
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
        let (records, mainRecordTypeForCell) = recordsAndMainTypeForThisDate
        switch records.count {
        case 0:
            EmptyView()
        case 1:
            if let firstRecord: RecordType = records.first {
                if currentRecord == .all || currentRecord == firstRecord.type {
                    switch firstRecord.type {
                        case .habit:
                            if let isCompleted = firstRecord.isCompleted {
                                Image(isCompleted ? firstRecord.type.getImage() : firstRecord.type.getNoneImage())
                                    .resizable()
                                    .scaledToFit()
                                    .frame(maxWidth: 24, maxHeight: 24)
                            }
                        default:
                            Image(firstRecord.type.getImage())
                                .resizable()
                                .scaledToFit()
                                .frame(maxWidth: 24, maxHeight: 24)
                    }
                }
            }
        default:
            if currentRecord == .all {
                if let findDayRecord: RecordType = records.first(where: { $0.type == mainRecordTypeForCell && $0.isCompleted == true}) {
                    if let isCompleted = findDayRecord.isCompleted {
                        if findDayRecord.type == .habit && isCompleted {
                            multipleRecords(for: findDayRecord.type.getImage())
                        } else {
                            multipleRecords(for: findDayRecord.type.getNoneImage())
                        }
                    } else {
                        multipleRecords(for: mainRecordTypeForCell.getNoneImage())
                    }
                } else if let findDayRecord: RecordType = records.first( where: { $0.type == mainRecordTypeForCell} ){
                    multipleRecords(for: findDayRecord.type.getImage())
                } else {
                    multipleRecords(for: mainRecordTypeForCell.getNoneImage())
                }
            } else {
                
                if let record = records.first(where: { $0.type == currentRecord }) {
                    let count = records.count(where: { $0.type == currentRecord})
                    
                    if count > 1 {
                        multipleRecords(for: record.type.getImage())
                    } else {
                        multipleRecords(for: record.type.getImage(), several: false)
                    }
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
        calendarRecord: .constant(CalendarRecord(statusCode: 200, code: "1", message: "Test Message", data: nil)),
        monthDate: .now
    )
}
