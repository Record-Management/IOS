import SwiftUI

struct WeekView: View {
    let week: Week
    let dragProgress: CGFloat
    let hideDiffrentMonth: Bool
    let monthDate: Date
    
    @Binding var selectedDate: Date
    @Binding var currentRecord: DropDownFilter
    @Binding var calendarRecord: CalendarRecord
    @Binding var selectedMonth: Date
    
    init(week: Week, dragProgress: CGFloat, hideDiffrentMonth: Bool = false, selectedDate: Binding<Date>, currentRecord: Binding<DropDownFilter>, calendarRecord: Binding<CalendarRecord>, monthDate: Date, selectedMonth: Binding<Date>) {
        self.week = week
        self.dragProgress = dragProgress
        self.hideDiffrentMonth = hideDiffrentMonth
        self._selectedDate = selectedDate
        self._currentRecord = currentRecord
        self._calendarRecord = calendarRecord
        self.monthDate = monthDate
        self._selectedMonth = selectedMonth
    }
    
    var body: some View {
        HStack(alignment: .top ,spacing: .zero) {
            ForEach(week.days, id: \.self) { cell in
                DayView(
                    cell: cell,
                    monthDate: monthDate, selectedDate: $selectedDate,
                    currentRecord: $currentRecord,
                    calendarRecord: $calendarRecord,
                    selectedMonth: $selectedMonth
                )
                .frame(maxWidth: .infinity)
            }
        }
    }
    
    private func isDayVisible(for date: Date) -> Bool {
        guard hideDiffrentMonth else { return true }
        return Calendar.isSameMonth(date, monthDate)
    }
}

#Preview {
    WeekView(
        week: Week(
            days: Calendar.currentWeek(from: .now).map { DayCell(date: $0) },
            order: .current
        ),
        dragProgress: 1,
        selectedDate: .constant(.now),
        currentRecord: .constant(.all),
        calendarRecord: .constant(CalendarRecord(statusCode: 200, code: "1", message: "Test Message", data: nil)),
        monthDate: .now,
        selectedMonth: .constant(.now)
    )
}
