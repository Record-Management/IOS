import SwiftUI

struct DayCell: Identifiable {
    let id: UUID
    let date: Date?
    let isCurrentMonth: Bool
    var records: [DropDownFilter]
    
    init(id: UUID = UUID(), date: Date? = nil, isCurrentMonth: Bool = true, records: [DropDownFilter] = []) {
        self.id = id
        self.date = date
        self.isCurrentMonth = isCurrentMonth
        self.records = records
    }
}
