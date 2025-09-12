import SwiftUI

struct DayCell: Identifiable {
    let id: UUID
    let date: Date?
    let isCurrentMonth: Bool
    
    init(id: UUID = UUID(), date: Date? = nil, isCurrentMonth: Bool = true) {
        self.id = id
        self.date = date
        self.isCurrentMonth = isCurrentMonth
    }
}

struct CalenderView: View {
    @State private var date = Date.now
    @State private var color: Color = .blue
    @State private var selectedDay: Date? = nil
    @State private var isFilterBox: Bool = false
    @State private var currentRecord: DropDownFilter = .all
    
    let columns = Array(repeating: GridItem(.flexible(), spacing: 0), count: 7)
    
    var body: some View {
        VStack(spacing: 0) {
            headerView
                .padding(.bottom, 10)
                .zIndex(1)
            middleDays
            daysView
        }
        .padding(.horizontal)
        .contentShape(Rectangle())
        .gesture(
            DragGesture().onEnded { value in
                if value.translation.width < -50 {
                    if let next = Calendar.current.date(byAdding: .month, value: 1, to: date) {
                        withAnimation(.smooth) {
                            date = next
                        }
                    }
                } else if value.translation.width > 50 {
                    if let prev = Calendar.current.date(byAdding: .month, value: -1, to: date) {
                        withAnimation(.smooth) {
                            date = prev
                        }
                    }
                }
            }
        )
    }
    
    // TODO: 상단 현재 year, month 및 색상 뷰
    private var headerView: some View {
        HStack {
            Text(getDayOfWeek(date))
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
                            Image(currentRecord.getImage())
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
                self.isFilterBox.toggle()
            }
        }
        .overlay(alignment: .topTrailing) {
            if isFilterBox {
                FilterDropDownView(
                    currentRecord: $currentRecord,
                    isFilterBox: $isFilterBox,
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
        LazyVGrid(columns: columns, spacing: 12.5) {
            ForEach(generateDaysInMonth(from: date)) { cell in
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
    private func getDayOfWeek(_ date: Date) -> String {
        let calendar = Calendar.current
        
        let year = calendar.component(.year, from: date)
        let month = calendar.component(.month, from: date)
        
        return "\(year)년 \(month)월"
    }
    
    private func generateDaysInMonth(from date: Date) -> [DayCell] {
        var calendar = Calendar.current
        calendar.locale = Locale(identifier: "ko_KR")
        
        guard let monthRange = calendar.range(of: .day, in: .month, for: date),
              let firstDay = calendar.date(from: calendar.dateComponents([.year, .month], from: date)) else {
            return []
        }
        
        let firstWeekday = calendar.component(.weekday, from: firstDay) // 1=Sunday
        var days: [DayCell] = []
        
        if firstWeekday > 1 {
            let prevMonth = calendar.date(byAdding: .month, value: -1, to: firstDay)!
            let prevMonthRange = calendar.range(of: .day, in: .month, for: prevMonth)!
            let prevMonthLastDay = prevMonthRange.count
            
            for day in (prevMonthLastDay - (firstWeekday - 2))...prevMonthLastDay {
                if let date = calendar.date(from: DateComponents(year: calendar.component(.year, from: prevMonth), month: calendar.component(.month, from: prevMonth), day: day)) {
                    days.append(DayCell(id: UUID(), date: date, isCurrentMonth: false))
                }
            }
        }
        
        // Current month days
        for day in monthRange {
            if let date = calendar.date(byAdding: .day, value: day - 1, to: firstDay) {
                days.append(DayCell(id: UUID() ,date: date, isCurrentMonth: true))
            }
        }
        
        if let nextMonth = calendar.date(byAdding: .month, value: 1, to: firstDay) {
            var nextMonthDay = 1
            while days.count % 7 != 0 {
                if let date = calendar.date(from: DateComponents(year: calendar.component(.year, from: nextMonth), month: calendar.component(.month, from: nextMonth), day: nextMonthDay)) {
                    days.append(DayCell(id: UUID(), date: date, isCurrentMonth: false))
                }
                nextMonthDay += 1
            }
        }
        
        return days
    }
    
    // TODO: 일반 뷰빌더 로직
    @ViewBuilder
    private func generalDayCell(_ cell: DayCell) -> some View {
        let isToday = {
            guard let date = cell.date else { return false }
            return Calendar.current.isDateInToday(date)
        }()
        
        if let date = cell.date {
            VStack {
                Text("\(Calendar.current.component(.day, from: date))")
                    .typography(.p12Medium)
                    .foregroundStyle(cell.isCurrentMonth ? isToday ? .white : .black : .gray)
                    .padding(.horizontal, 8)
                    .background(isToday ? Color.Primary.main() : .clear)
                    .clipShape(.rect(cornerRadius: 100))
            }
            .frame(height: 80, alignment: .top)
            .frame(maxWidth: .infinity)
            .onTapGesture {
                selectedDay = date
            }
        } else {
            Text("")
        }
    }
}
