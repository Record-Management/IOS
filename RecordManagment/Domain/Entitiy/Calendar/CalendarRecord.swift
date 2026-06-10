import Foundation

struct CalendarRecord: Codable, Identifiable, Equatable {
    var id: String = UUID().uuidString
    let statusCode: Int
    let code: String
    let message: String
    let data: CalendarData?
    
    static func == (lhs: CalendarRecord, rhs: CalendarRecord) -> Bool {
        lhs.id == rhs.id
    }
    
    enum CodingKeys: String, CodingKey {
        case statusCode = "statusCode"
        case code = "code"
        case message = "message"
        case data = "data"
    }
}


struct CalendarData: Codable {
    let year: Int
    let month: Int
    let monthlyRecords: [AllRecord]?
}

struct AllRecord: Codable {
    let date: [Int]
    let mainRecordTypeForDate: String?
    let records: [DetailRecord]
    let schedules: ScheduleRecord?
}

struct DetailRecord: Codable {
    let id: String
    let type: String
    let isCompleted: Bool?
}

struct ScheduleRecord: Codable {
    let title: String
    let extraScheduleCount: Int?
    let color: String
}
