import SwiftUI

struct WeekView: View {
    let week: Week
    let dragProgress: CGFloat
    let hideDiffrentMonth: Bool
    let monthDate: Date
    
    @Binding var selectedDate: Date
    @Binding var currentRecord: DropDownFilter
    @Binding var calendarRecord: CalendarRecord
    
    init(week: Week, dragProgress: CGFloat, hideDiffrentMonth: Bool = false, selectedDate: Binding<Date>, currentRecord: Binding<DropDownFilter>, calendarRecord: Binding<CalendarRecord>, monthDate: Date) {
        self.week = week
        self.dragProgress = dragProgress
        self.hideDiffrentMonth = hideDiffrentMonth
        self._selectedDate = selectedDate
        self._currentRecord = currentRecord
        self._calendarRecord = calendarRecord
        self.monthDate = monthDate
    }
    
    var body: some View {
        HStack(alignment: .top ,spacing: .zero) {
            ForEach(week.days, id: \.self) { cell in
                DayView(
                    cell: cell,
                    selectedDate: $selectedDate,
                    currentRecord: $currentRecord,
                    calendarRecord: $calendarRecord,
                    monthDate: monthDate
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

