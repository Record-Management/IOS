import Foundation

struct Month: Identifiable, Equatable {
    let id: String
    let weeks: [Week]
    let order: Order
    let initializedDate: Date
    
    init(from date: Date, order: Order) {
        self.order = order
        
        var components = Calendar.current.dateComponents([.year, .month], from: date)
        components.hour = 9
        components.minute = 0
        components.second = 0
        
        let monthStartDate = Calendar.current.date(from: components) ?? date
        self.initializedDate = monthStartDate
        guard let monthInterval = Calendar.current.dateInterval(of: .month, for: monthStartDate) else {
            self.weeks = []
            self.id = Calendar.monthAndYear(from: monthStartDate)
            return
        }
        
        let firstDayOfMonth = monthInterval.start
        let lastDayOfMonth = monthInterval.end
        
        let calendar = Calendar.current
        let componentsForStartDate = calendar.dateComponents([.yearForWeekOfYear, .weekOfYear], from: firstDayOfMonth)
        let gridStartDate = calendar.date(from: componentsForStartDate)!
        
        // 'date' 파라미터가 포함된 주를 찾아 기준(.current)으로 삼습니다.
        let centerWeekStartDate = calendar.date(from: calendar.dateComponents([.yearForWeekOfYear, .weekOfYear], from: date))!

        var weeks: [Week] = []
        var currentWeekStartDate = gridStartDate
        
        repeat {
            let weekDays = (0...6).map { calendar.date(byAdding: .day, value: $0, to: currentWeekStartDate)! }
            
            let weekOrder: Week.Order
            if currentWeekStartDate < centerWeekStartDate {
                weekOrder = .previous
            } else if currentWeekStartDate == centerWeekStartDate {
                weekOrder = .current
            } else {
                weekOrder = .next
            }
            
            weeks.append(Week(days: weekDays.map { DayCell(date: $0) }, order: weekOrder))
            currentWeekStartDate = calendar.date(byAdding: .weekOfYear, value: 1, to: currentWeekStartDate)!
        } while currentWeekStartDate < lastDayOfMonth
        
        self.weeks = weeks
        self.id = Calendar.monthAndYear(from: initializedDate)
    }
}

extension Month {
    var previousMonth: Month? {
        guard let previousMonthDate = Calendar.current.date(byAdding: .month, value: -1, to: initializedDate) else { return nil }
        return Month(from: previousMonthDate, order: .previous)
    }
    
    var nextMonth: Month? {
        guard let nextMonthDate = Calendar.current.date(byAdding: .month, value: 1, to: initializedDate) else { return nil }
        return Month(from: nextMonthDate, order: .next)
    }
    
    enum Order {
        case previous, current, next
    }
    
    func theSameMonth(as date: Date) -> Bool {
        Calendar.isSameMonth(initializedDate, date)
    }
}
