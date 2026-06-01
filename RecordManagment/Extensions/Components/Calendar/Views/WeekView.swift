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
            ForEach(week.days, id: \.id) { (day: DayCell) in
                let cell = day
                let date = cell.date
                // precompute records and main type for this date
                let monthlyRecords = calendarRecord.data?.monthlyRecords
                let dayData = monthlyRecords?.first(where: {
                    Calendar.current.isDate(date, inSameDayAs: Date.convertDateForIntArray($0.date) ?? .now)
                })
                let mainType = DropDownFilter.matchingType(type: dayData?.mainRecordTypeForDate ?? "")
                let records: [(type: DropDownFilter, isCompleted: Bool?)] = dayData?.records.map { (type: DropDownFilter.matchingType(type: $0.type), isCompleted: $0.isCompleted) } ?? []
                let schedules = dayData?.schedules
                
                DayView(
                    date: date,
                    monthDate: monthDate,
                    records: records,
                    mainRecordTypeForDate: mainType,
                    schedules: schedules,
                    selectedDate: $selectedDate,
                    currentRecord: $currentRecord,
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
