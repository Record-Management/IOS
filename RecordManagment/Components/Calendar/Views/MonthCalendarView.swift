//
//  MonthCalendarView.swift
//  RecordManagment
//
//  Created by 김용해 on 9/20/25.
//

import SwiftUI

struct MonthCalendarView: View {
    let isDragging: Bool
    let dragProgress: CGFloat
    
    @Binding var title: String
    @Binding var focused: Week
    @Binding var selection: Date
    @Binding var currentRecord: DropDownFilter
    @Binding var calendarRecord: CalendarRecord
    @Binding var selectedMonth: Date
    
    @State private var months: [Month]
    @State private  var position: ScrollPosition
    @State private var calendarWidth: CGFloat = .zero
    
    init(isDragging: Bool, dragProgress: CGFloat, title: Binding<String>, focused: Binding<Week>, selection: Binding<Date>, currentRecord: Binding<DropDownFilter>, calendarRecord: Binding<CalendarRecord>, selectedMonth: Binding<Date>) {
        self._title = title
        self._focused = focused
        self._selection = selection
        self._currentRecord = currentRecord
        self._calendarRecord = calendarRecord
        self.isDragging = isDragging
        self.dragProgress = dragProgress
        self._selectedMonth = selectedMonth
        
        let creationDate = focused.wrappedValue.days.last
        var currentMonth = Month(from: creationDate?.date ?? .now, order: .current)
        
        let selection = selection.wrappedValue
        if let lastDayOfTheMonth = currentMonth.weeks.first?.days.last,
           !Calendar.isSameMonth(lastDayOfTheMonth.date, selection),
           let previousMonth = currentMonth.previousMonth {
            if let firstDay = focused.wrappedValue.days.first, firstDay.date == selection {
                currentMonth = previousMonth
            }
        }
        
        _months = State(
            initialValue: [
                currentMonth.previousMonth,
                currentMonth,
                currentMonth.nextMonth
            ].compactMap(\.self)
        )
        _position = State(initialValue: ScrollPosition(id: currentMonth.id))
    }
    
    
    var body: some View {
        ScrollView(.horizontal) {
            LazyHStack(spacing: .zero) {
                ForEach(months) { month in
                    VStack {
                        MonthView(
                            month: month,
                            dragProgress: dragProgress,
                            focused: $focused,
                            selectedDate: $selection,
                            currentRecord: $currentRecord,
                            calendarRecord: $calendarRecord
                        )
                        .frame(width: calendarWidth)
                        .frame(minHeight: Calendar.monthHeight)
                        .onAppear {
                            loadMonth(from: month)
                        }
                    }
                }
            }
            .scrollTargetLayout()
            .frame(height: Calendar.monthHeight)
        }
        .scrollDisabled(isDragging)
        .scrollPosition($position)
        .scrollTargetBehavior(.viewAligned)
        .scrollIndicators(.hidden)
        .onGeometryChange(for: CGFloat.self) { proxy in
            proxy.size.width
        }action: { newValue in
            calendarWidth = newValue
        }
        .onChange(of: position) { _, newValue in
            guard let focusedMonth = months.first(where: { $0.id == (newValue.viewID as? String)}),
                  let focusedWeek = focusedMonth.weeks.first
            else { return }
            
            if focusedMonth.weeks.flatMap(\.days).contains(where: { Calendar.current.isDate($0.date, inSameDayAs: selection) }),
               let selectedWeek = focusedMonth.weeks.first(where: { $0.days.contains(where: { Calendar.current.isDate($0.date, inSameDayAs: selection) }) }) {
                self.focused = selectedWeek
            } else {
                self.focused = focusedWeek
            }
            
            selectedMonth = focusedWeek.days.last!.date
            title = Calendar.monthAndYear(from: selectedMonth)
        }
        .onChange(of: selection) { _ ,newValue in
            guard
                  let week = months.flatMap(\.weeks).first(where: { (week) -> Bool in
                      week.days.contains(where: { Calendar.current.isDate($0.date, inSameDayAs: selection) })
                  })
            else { return }
            focused = week
        }
        .onChange(of: dragProgress) {_, newValue in
            guard newValue == 1 else { return }
            if
               let currentMonth = months.first(where: { $0.id == (position.viewID as? String)}),
               currentMonth.weeks.flatMap(\.days).contains(where: { Calendar.current.isDate($0.date, inSameDayAs: selection) }),
               let newFocus = currentMonth.weeks.first(where: {$0.days.contains(where: { Calendar.current.isDate($0.date, inSameDayAs: selection) })}) {
                focused = newFocus
            }
            
        }
    }
}

extension MonthCalendarView {
    func loadMonth(from month: Month) {
        if month.order == .previous, months.first == month, let previousMonth = month.previousMonth {
            var months = self.months
            months.insert(previousMonth, at: 0)
            self.months = months
        } else if month.order == .next, months.last == month, let nextMonth = month.nextMonth {
            var months = months
            months.append(nextMonth)
            self.months = months
        }
    }
}

#Preview {
    MonthCalendarView(
        isDragging: false,
        dragProgress: 1,
        title: .constant("2025년 9월"),
        focused: .constant(.current),
        selection: .constant(.now),
        currentRecord: .constant(.all),
        calendarRecord: .constant(CalendarRecord(statusCode: 200, code: "1", message: "test meesage", data: nil)),
        selectedMonth: .constant(.now)
    )
}
