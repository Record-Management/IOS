import SwiftUI

struct DayView: View {
    let date: Date
    let monthDate: Date
    let records: [RecordType]
    let mainRecordTypeForDate: DropDownFilter
    let schedules: ScheduleRecord?
    
    @Binding var selectedDate: Date
    @Binding var currentRecord: DropDownFilter
    @Binding var selectedMonth: Date
    
    typealias RecordType = (type: DropDownFilter, isCompleted: Bool?)
    
    private var isDifferentMonth: Bool {
        !Calendar.isSameMonth(date, monthDate)
    }
    
    var currentDay: Bool {
        Calendar.current.isDate(date, inSameDayAs: selectedDate)
    }
    
    var body: some View {
        VStack(spacing: 2) {
                Text("\(Calendar.current.component(.day, from: date))")
                    .typography(.p12Medium)
                    .frame(height: 18)
                    .padding(.horizontal, 8)
                .foregroundStyle(
                    isDifferentMonth ? Color.Gray._300() :
                    (currentDay ? .white : .black)
                )
                .background(
                    currentDay ? Color.Primary.main() : .clear
                )
                .clipShape(.rect(cornerRadius: 100))
            
            if !isDifferentMonth {
                readRecords(using: records, mainRecordTypeForCell: mainRecordTypeForDate)
                    .frame(width: 24, height: 24)
                scheduleRecord()
            }
        }
        .frame(height: Calendar.weekHeight, alignment: .top)
        .frame(maxWidth: .infinity)
        .contentShape(Rectangle())
        .onTapGesture {
            withAnimation(.easeInOut) {
                self.selectedDate = date
            }
            self.selectedMonth = date
        }
    }
    
    // TODO: 기록 이미지가 있다면 반환하는 함수
    @ViewBuilder
    private func readRecords(using records: [RecordType], mainRecordTypeForCell: DropDownFilter) -> some View {
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
                            }
                        default:
                            Image(firstRecord.type.getImage())
                                .resizable()
                                .scaledToFit()
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
    
    
    // TODO: 일정 기록 이미지 반환 하는 함수
    
    @ViewBuilder
    private func scheduleRecord() -> some View {
        if let schedules = self.schedules {
            let color: ScheduleColor = ScheduleColor.matchingColor(schedules.color)

            VStack(alignment: .leading, spacing: 2) {
                HStack(spacing: 0) {
                    Rectangle()
                        .fill(colorBackground(color: color))
                        .frame(width: 3, height: 10)
                        .padding(2)
                    Text(schedules.title)
                        .typography(.p10Medium)
                        .foregroundStyle(Color.Gray._900())
                        .lineLimit(1)
                }
                .frame(maxWidth: .infinity, minHeight: 14, maxHeight: 14, alignment: .leading)
                .background(Color.Gray._100())
                .clipShape(.rect(cornerRadius: 2))

                if let count = schedules.extraScheduleCount {
                    HStack(spacing: 1) {
                        Image(systemName: "plus")
                            .resizable()
                            .scaledToFit()
                            .frame(width: 5, height: 5)
                        Text("\(count)")
                            .typography(.p10Medium)
                            .foregroundStyle(Color.Gray._900())
                    }
                    .frame(height: 14)
                    .padding(.horizontal, 4)
                    .background(Color.Gray._100())
                    .clipShape(.rect(cornerRadius: 4))
                }
            }
            .frame(maxHeight: 30, alignment: .top)
            .padding(.trailing, 4)
        } else {
            EmptyView()
        }
    }
    private func colorBackground(color: ScheduleColor) -> Color {
        switch color {
        case .Red:    return Color(hex: "#FF5B52")
        case .Orange: return Color.Primary.main()
        case .Yellow: return Color(hex: "#FFCC00")
        case .Green:  return Color(hex: "#34C759")
        case .Blue:   return Color(hex: "#007AFF")
        case .Indigo:   return Color(hex: "#004080")
        case .Pink:   return Color(hex: "#FF2D55")
        case .Gray:   return Color.Gray._400()
        }
    }
    
    /// ** 복잡한 연산 로직을 함수로 분리하기 위함
    /// parameter
    /// - icon: 각 FilterDown 타입에 맞는 이미지 이름값
    /// - several: 다중 기록의 유무를 표시하는 Bool 값
    @ViewBuilder
    private func multipleRecords(for icon: String, several: Bool = true) -> some View {
        Image(icon)
        .resizable()
        .scaledToFit()
        .frame(width: 24, height: 24)
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
    Group {
        // Single DAILY (completed)
        DayView(
            date: .now,
            monthDate: .now,
            records: [ (type: .daily, isCompleted: true) ],
            mainRecordTypeForDate: .daily,
            schedules: nil,
            selectedDate: .constant(.now),
            currentRecord: .constant(.all),
            selectedMonth: .constant(.now)
        )
        
        // Single DAILY if exist schedule (completed)
        DayView(
            date: .now,
            monthDate: .now,
            records: [ (type: .daily, isCompleted: true) ],
            mainRecordTypeForDate: .daily,
            schedules: ScheduleRecord(title: "일정 기록 테스트", extraScheduleCount: 3, color: "ORANGE"),
            selectedDate: .constant(.now),
            currentRecord: .constant(.all),
            selectedMonth: .constant(.now)
        )
        
        // Habit (not completed)
        DayView(
            date: .now,
            monthDate: .now,
            records: [ (type: .habit, isCompleted: false) ],
            mainRecordTypeForDate: .habit,
            schedules: nil,
            selectedDate: .constant(.now),
            currentRecord: .constant(.all),
            selectedMonth: .constant(.now)
        )
        
        // Multiple records
        DayView(
            date: .now,
            monthDate: .now,
            records: [
                (type: .daily, isCompleted: true),
                (type: .schedule, isCompleted: nil)
            ],
            mainRecordTypeForDate: .daily,
            schedules: nil,
            selectedDate: .constant(.now),
            currentRecord: .constant(.all),
            selectedMonth: .constant(.now)
        )
        
        // Different month (grayed out)
        DayView(
            date: Calendar.current.date(byAdding: .month, value: -1, to: .now) ?? .now,
            monthDate: .now,
            records: [],
            mainRecordTypeForDate: .all,
            schedules: nil,
            selectedDate: .constant(.now),
            currentRecord: .constant(.all),
            selectedMonth: .constant(.now)
        )
    }
    .frame(maxWidth: 80)
    .background(.blue)
}
