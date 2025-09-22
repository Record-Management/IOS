import SwiftUI

struct CalendarView: View {
    @StateObject private var vm: ViewModel = .init()
    @State private var focusedWeek: Week = .current
    @State private var title: String = Calendar.monthAndYear(from: .now)
    let columns = Array(repeating: GridItem(.flexible(), spacing: 0), count: 7)
    var dragProgress: CGFloat = 1
    var body: some View {
        VStack(spacing: 0) {
            headerView
                .padding(.bottom, 10)
                .zIndex(1)
            middleDays
            
            MonthCalendarView(
                isDragging: false,
                dragProgress: dragProgress,
                title: $title,
                focused: $focusedWeek,
                selection: $vm.date,
                currentRecord: $vm.currentRecord,
                calendarRecord: $vm.calendarRecord,
                selectedMonth: $vm.selectedMonth
            )
            .frame(maxHeight: Calendar.monthHeight)
        }
        .padding(.horizontal)
        .contentShape(Rectangle())
    }
    
    // TODO: 상단 현재 year, month 및 색상 뷰
    private var headerView: some View {
        HStack {
            Text(title)
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
            .frame(maxHeight: 44)
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
}

extension CalendarView {
    var weekdays: [String] {
        ["일", "월", "화", "수", "목", "금", "토"]
    }
}


// Data Structure
extension CalendarView {
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

#Preview {
    CalendarView()
}
