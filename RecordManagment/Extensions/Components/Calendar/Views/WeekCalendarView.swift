//
//  CalendarView.swift
//  RecordManagment
//
//  Created by 김용해 on 9/20/25.
//

import SwiftUI

struct WeekCalendarView: View {
    let isDragging: Bool
    @Binding var title: String
    @Binding var focused: Week
    @Binding var selection: Date
    @Binding var currentRecord: DropDownFilter
    @Binding var calendarRecord: CalendarRecord
    
    @State private var weeks: [Week]
    @State private var position: ScrollPosition
    @State private var calendarWidth: CGFloat = .zero
    
    init(isDragging: Bool, title: Binding<String>, focused: Binding<Week>, selection: Binding<Date>, currentRecord: Binding<DropDownFilter>, calendarRecord: Binding<CalendarRecord>) {
        self._title = title
        self._focused = focused
        self._selection = selection
        self.isDragging = isDragging
        self._currentRecord = currentRecord
        self._calendarRecord = calendarRecord
        
        let theNearestSunday = Calendar.nearestSunday(from: focused.wrappedValue.days.first?.date ?? .now)
        let currentWeek = Week(
            days: Calendar.currentWeek(from: theNearestSunday).map { DayCell(date: $0) },
            order: .current
        )
        
        let previousWeek: Week = {
            if let firstDay = currentWeek.days.first {
                return Week(
                    days: Calendar.previousWeek(from: firstDay.date).map { DayCell(date: $0) },
                    order: .previous
                )
            } else {
                return Week(days: [], order: .previous)
            }
        }()
        
        let nextWeek: Week = {
            if let lastDay = currentWeek.days.last {
                return Week(
                    days: Calendar.nextWeek(from: lastDay.date).map { DayCell(date: $0) },
                    order: .next
                )
            } else {
                return Week(days: [], order: .next)
            }
        }()
        
        _weeks = .init(initialValue: [previousWeek, currentWeek, nextWeek])
        _position = State(initialValue: ScrollPosition(id: focused.wrappedValue.id))
    }
    
    var body: some View {
        ScrollView(.horizontal) {
            LazyHStack(spacing: .zero) {
                ForEach(weeks) { week in
                    VStack {
                        WeekView(
                            week: week,
                            dragProgress: .zero,
                            selectedDate: $selection,
                            currentRecord: $currentRecord,
                            calendarRecord: $calendarRecord,
                            monthDate: .now,
                            selectedMonth: .constant(.now)
                        )
                        .frame(width: calendarWidth, height: 80)
                        .onAppear {
                            loadWeek(from: week)
                        }
                    }
                }
            }
            .scrollTargetLayout()
            .frame(height: 80)
        }
        .scrollDisabled(isDragging)
        .scrollPosition($position)
        .scrollTargetBehavior(.viewAligned)
        .scrollIndicators(.hidden)
        .onGeometryChange(for: CGFloat.self) { proxy in
            proxy.size.width
        } action: { newValue in
            calendarWidth = newValue
        }
        .onChange(of: position) { _, newValue in
            guard let focusedWeek = weeks.first(where: { $0.id == (newValue.viewID as? String) }),
                  let firstDate = focusedWeek.days.first?.date
            else { return }
            focused = focusedWeek
            title = Calendar.monthAndYear(from: firstDate)
        }
        .onChange(of: selection) { _, newValue in
            guard
                let week = weeks.first(where: { $0.days.contains(where: { $0.date == selection }) })
            else { return }
            
            focused = week
        }
    }
}

extension WeekCalendarView {
    func loadWeek(from week: Week) {
        if week.order == .previous, weeks.first == week, let firstDay = week.days.first?.date {
            let previousWeek = Week(days: Calendar.previousWeek(from: firstDay).map { DayCell(date: $0) }, order: .previous)
            
            var weeks = self.weeks
            weeks.insert(previousWeek, at: 0)
            self.weeks = weeks
        } else if week.order == .next, weeks.last == week, let lastDay = week.days.last?.date {
            let nextWeek = Week(days: Calendar.nextWeek(from: lastDay).map { DayCell(date: $0) }, order: .next)
            
            var weeks = self.weeks
            weeks.append(nextWeek)
            
            self.weeks = weeks
        }
    }
}

#Preview {
    WeekCalendarView(
        isDragging: false,
        title: .constant("hello"),
        focused: .constant(Week(
            days: Calendar.currentWeek(from: .now).map { DayCell(date: $0) },
            order: .current
        )),
        selection: .constant(.now),
        currentRecord: .constant(.all),
        calendarRecord: .constant(CalendarRecord(statusCode: 200, code: "1", message: "Test Message", data: nil))
    )
}
