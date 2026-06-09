import SwiftUI

struct MonthView: View {
    let month: Month
    let dragProgress: CGFloat
    
    @Binding var focused: Week
    @Binding var selectedDate: Date
    @Binding var currentRecord: DropDownFilter
    @Binding var monthlyRecords: [AllRecord]
    @Binding var selectedMonth: Date
    
    var body: some View {
        // spacing between week rows
        let rowSpacing: CGFloat = 10
        let weeksCount = CGFloat(max(1, month.weeks.count))
        // compute per-week height but ensure it is at least the canonical weekHeight (80)
        let computedHeight = (Calendar.monthHeight - rowSpacing * CGFloat(max(0, month.weeks.count - 1))) / weeksCount
        let perWeekHeight = max(computedHeight, Calendar.weekHeight)

        VStack(spacing: rowSpacing) {
            ForEach(month.weeks) { week in
                WeekView(
                    week: week,
                    dragProgress: dragProgress,
                    hideDiffrentMonth: true,
                    selectedDate: $selectedDate,
                    currentRecord: $currentRecord,
                    monthlyRecords: $monthlyRecords,
                    monthDate: month.initializedDate,
                    selectedMonth: $selectedMonth
                )
                .opacity(focused == week ? 1 : dragProgress)
                .frame(height: perWeekHeight)
            }
        }
    }
}

#Preview {
    MonthView(
        month: .init(
            from: .now,
            order: .current
        ),
        dragProgress: 1,
        focused: .constant(.current),
        selectedDate: .constant(.now),
        currentRecord: .constant(.all),
        monthlyRecords: .constant([]),
        selectedMonth: .constant(.now)
    )
}
