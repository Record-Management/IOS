import SwiftUI

struct CalenderView: View {
    @StateObject private var vm: ViewModel = .init()
    let columns = Array(repeating: GridItem(.flexible(), spacing: 0), count: 7)
    
    var body: some View {
        VStack(spacing: 0) {
            headerView
                .padding(.bottom, 10)
                .zIndex(1)
            middleDays
            daysView
                .simultaneousGesture(
                    vm.horizontalScrollGesture()
                )
        }
        .padding(.horizontal)
        .contentShape(Rectangle())
    }
    
    // TODO: 상단 현재 year, month 및 색상 뷰
    private var headerView: some View {
        HStack {
            Text(getDayOfWeek(vm.date))
                .typography(.p20Bold)
                .lineLimit(1)
                .minimumScaleFactor(0.5)
            Spacer()
            ZStack {
                Rectangle()
                    .fill(Color.Gray._100())
                    .frame(maxWidth: 64)
                    .clipShape(.rect(cornerRadius: 100))
                HStack(spacing: 2) {
                    Circle()
                        .fill(.white)
                        .frame(maxWidth: 30, maxHeight: 30)
                        .overlay {
                            Image(vm.currentRecord.getImage())
                                .resizable()
                                .scaledToFit()
                                .padding(3)
                        }
                    Image(systemName: "chevron.down")
                        .padding(.vertical, 5)
                }
                .padding(.vertical, 4)
                .padding(.horizontal, 6)
            }
        }
        .onTapGesture {
            withAnimation(.interactiveSpring) {
                vm.isFilterBox.toggle()
            }
        }
        .overlay(alignment: .topTrailing) {
            if vm.isFilterBox {
                FilterDropDownView(
                    currentRecord: $vm.currentRecord,
                    isFilterBox: $vm.isFilterBox,
                )
            }
        }
    }
    
    // TODO: 월 화 수 목 금 토 일
    private var middleDays: some View {
        LazyVGrid(columns: columns, spacing: 12.5) {
            ForEach(weekdays, id: \.self) { day in
                Text(day)
                    .typography(.p14Medium)
                    .padding(.vertical, 9)
                    .frame(maxWidth: .infinity)
            }
        }
    }
    
    private var daysView: some View {
        let days = self.generateDaysInMonth(from: vm.date)
        return LazyVGrid(columns: columns, spacing: 12.5) {
            ForEach(days) { cell in
                generalDayCell(cell)
            }
        }
    }
}

extension CalenderView {
    var weekdays: [String] {
        ["일", "월", "화", "수", "목", "금", "토"]
    }
}


// Data Structure
extension CalenderView {
    // MARK: 현재 년 * 월 을 반환한다.
    private func getDayOfWeek(_ date: Date) -> String {
        let calendar = Calendar.current
        
        let year = calendar.component(.year, from: date)
        let month = calendar.component(.month, from: date)
        
        return "\(year)년 \(month)월"
    }
    
    // MARK: 해당 달의 모든 날짜를 계산하고 전달과 다음달을 요일에 맞춰 반환
    private func generateDaysInMonth(from date: Date) -> [DayCell] {
        var calendar = Calendar.current
        calendar.locale = Locale(identifier: "ko_KR")
        var days: [DayCell] = []
        
        guard let monthRange = calendar.range(of: .day, in: .month, for: date),
              let firstDay = calendar.date(from: calendar.dateComponents([.year, .month], from: date)) else {
            return []
        }
        
        let firstWeekday = calendar.component(.weekday, from: firstDay) // 1=Sunday
        
        if firstWeekday > 1 {
            let prevMonth = calendar.date(byAdding: .month, value: -1, to: firstDay)!
            let prevMonthRange = calendar.range(of: .day, in: .month, for: prevMonth)!
            let prevMonthLastDay = prevMonthRange.count
            
            for day in (prevMonthLastDay - (firstWeekday - 2))...prevMonthLastDay {
                if let date = calendar.date(from: DateComponents(year: calendar.component(.year, from: prevMonth), month: calendar.component(.month, from: prevMonth), day: day)) {
                    days.append(DayCell(date: date, isCurrentMonth: false))
                }
            }
        }
        
        // Current month days
        for day in monthRange {
            if let date = calendar.date(byAdding: .day, value: day - 1, to: firstDay) {
                let dayComponent = calendar.component(.day, from: date)
                
                let recordsForDay = vm.calendarRecord.data?.monthlyRecords?.first(where: { record in
                    return record.date.count > 2 && record.date[2] == dayComponent
                })
                
                if let matchingDay = recordsForDay {
                    let records = matchingDay.records.map { DropDownFilter.matchingType(type: $0.type) }
                    days.append(DayCell(date: date, isCurrentMonth: true, records: records))
                } else {
                    days.append(DayCell(date: date, isCurrentMonth: true, records: []))
                }
            }
        }
        
        if let nextMonth = calendar.date(byAdding: .month, value: 1, to: firstDay) {
            var nextMonthDay = 1
            while vm.days.count % 7 != 0 {
                if let date = calendar.date(from: DateComponents(year: calendar.component(.year, from: nextMonth), month: calendar.component(.month, from: nextMonth), day: nextMonthDay)) {
                    days.append(DayCell(date: date, isCurrentMonth: false))
                }
                nextMonthDay += 1
            }
        }
        
        return days
    }
}


extension CalenderView {
    // TODO: generateDaysInMonth에서 cell을 받아서 날짜 UI 반환 함수
    @ViewBuilder
    private func generalDayCell(_ cell: DayCell) -> some View {
        
        if let date = cell.date {
            let isToday = Calendar.current.isDateInToday(date)
            let isSelected = Calendar.current.isDate(date, inSameDayAs: vm.selectedDay!)
            let condition = ( isToday && vm.selectedDay == nil) || isSelected
            VStack {
                Text("\(Calendar.current.component(.day, from: date))")
                    .typography(.p12Medium)
                    .foregroundStyle(cell.isCurrentMonth ? (condition ? .white : .black) : .gray)
                    .padding(.horizontal, 8)
                    .background(condition ? Color.Primary.main() : .clear)
                    .clipShape(.rect(cornerRadius: 100))
                recordIcon(for: cell)
            }
            .frame(height: 80, alignment: .top)
            .frame(maxWidth: .infinity)
            .onTapGesture {
                vm.selectedDay = date
            }
        }
    }
    
    // TODO: 기록 이미지가 있다면 반환하는 함수
    @ViewBuilder
    private func recordIcon(for cell: DayCell) -> some View {
        switch cell.records.count {
        case 0:
            EmptyView()
        case 1:
            if let firstRecord = cell.records.first {
                if vm.currentRecord == .all || vm.currentRecord == firstRecord {
                    Image(firstRecord.getImage())
                        .resizable()
                        .scaledToFit()
                        .frame(maxWidth: 24, maxHeight: 24)
                }
            }
        default:
            if vm.currentRecord == .all {
                if let findDayRecord = cell.records.first(where: { $0 == .day }) {
                    multipleRecords(for: findDayRecord.getImage())
                } else {
                    multipleRecords(for: "None_DayRecord")
                }
            } else {
                if let record = cell.records.first(where: { $0 == vm.currentRecord}) {
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
