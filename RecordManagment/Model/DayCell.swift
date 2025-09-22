import SwiftUI

struct DayCell: Identifiable, Hashable, Equatable {
    let id: UUID
    let date: Date
    let isCurrentMonth: Bool
    var records: [DropDownFilter]
    
    init(id: UUID = UUID(), date: Date, isCurrentMonth: Bool = true, records: [DropDownFilter] = []) {
        self.id = id
        self.date = date
        self.isCurrentMonth = isCurrentMonth
        self.records = records
    }
    
    static func == (lhs: DayCell, rhs: DayCell) -> Bool {
        Calendar.current.isDate(lhs.date, inSameDayAs: rhs.date)
    }
}
