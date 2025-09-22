//
//  MonthView.swift
//  RecordManagment
//
//  Created by 김용해 on 9/20/25.
//

import SwiftUI

struct MonthView: View {
    let month: Month
    let dragProgress: CGFloat
    
    @Binding var focused: Week
    @Binding var selectedDate: Date
    @Binding var currentRecord: DropDownFilter
    @Binding var calendarRecord: CalendarRecord
    
    var body: some View {
        VStack(spacing: .zero) {
            ForEach(month.weeks) { week in
                WeekView(
                    week: week,
                    dragProgress: dragProgress,
                    hideDiffrentMonth: true,
                    selectedDate: $selectedDate,
                    currentRecord: $currentRecord,
                    calendarRecord: $calendarRecord
                )
                .opacity(focused == week ? 1 : dragProgress)
                .frame(height: Calendar.monthHeight / CGFloat(month.weeks.count))
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
        calendarRecord: .constant(CalendarRecord(statusCode: 200, code: "1", message: "Test Message", data: nil))
    )
}
