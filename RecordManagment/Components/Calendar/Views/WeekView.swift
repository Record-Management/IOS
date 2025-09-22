import SwiftUI

struct WeekView: View {
    let week: Week
    let dragProgress: CGFloat
    let hideDiffrentMonth: Bool
    
    @Binding var selectedDate: Date
    @Binding var currentRecord: DropDownFilter
    @Binding var calendarRecord: CalendarRecord
    
    init(week: Week, dragProgress: CGFloat, hideDiffrentMonth: Bool = false, selectedDate: Binding<Date>, currentRecord: Binding<DropDownFilter>, calendarRecord: Binding<CalendarRecord>) {
        self.week = week
        self.dragProgress = dragProgress
        self.hideDiffrentMonth = hideDiffrentMonth
        self._selectedDate = selectedDate
        self._currentRecord = currentRecord
        self._calendarRecord = calendarRecord
    }
    
    var body: some View {
        HStack(alignment: .top ,spacing: .zero) {
            ForEach(week.days, id: \.self) { cell in
                DayView(
                    cell: cell,
                    selectedDate: $selectedDate,
                    currentRecord: $currentRecord,
                    calendarRecord: $calendarRecord
                )
                .opacity(isDayVisible(for: cell.date) ? 1 : (1 - dragProgress))
                .frame(maxWidth: .infinity)
            }
        }
    }
    
    private func isDayVisible(for date: Date) -> Bool {
        guard hideDiffrentMonth else { return true }
        
        switch week.order {
            case .previous, .current:
                guard let last = week.days.last?.date else { return true }
                return Calendar.isSameMonth(date, last)
            case .next:
                guard let first = week.days.first?.date else { return true }
                return Calendar.isSameMonth(date, first)
        }
    }
}

