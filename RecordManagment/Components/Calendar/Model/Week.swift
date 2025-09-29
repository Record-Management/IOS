import Foundation

struct Week: Hashable, Identifiable {
    let id: String
    let days: [DayCell]
    let order: Order
    
    init(days: [DayCell], order: Order) {
        self.id = Calendar.weekAndYear(from: days.last?.date ?? .now)
        self.days = days
        self.order = order
    }
    
    enum Order {
        case previous, current, next
    }
}

extension Week: Equatable {
    static func == (lhs: Week, rhs: Week) -> Bool {
        lhs.id == rhs.id
    }
}

extension Week {
    static let current = Week(
        days: Calendar.currentWeek(from: Calendar.nearestSunday(from: .now))
            .map { DayCell(date: $0) },
        order: .current
    )
}
