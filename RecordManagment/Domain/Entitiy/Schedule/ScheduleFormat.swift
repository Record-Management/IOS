import Foundation

/// 일정 기록 http통신 중 Post, Update 용 형식
struct ScheduleFormat: Codable {
    let title: String
    let startDate: [Int]
    let endDate: [Int]
    let notificationType: String
    let notificationCustomHours: Int?
    let notificationCustomMinutes: Int?
    let repeatType: String
    let repeatEndsOn: String?
    let location: String?
    let color: String
    let memo: String?
}

/// 일정 기록 응답 형식 DTO
struct ScheduleResponse: Decodable, Hashable, Equatable, Sendable {
    let scheduleRecordId: String
    let userId: String?
    let title: String
    let startDate: [Int]
    let endDate: [Int]
    let notificationType: String?
    let notificationCustomHours: Int?
    let notificationCustomMinutes: Int?
    let repeatType: String?
    let repeatEndsOn: Date?
    let location: String?
    let color: String
    let memo: String?
    
    var scheduleId: String {
        return scheduleRecordId
    }
    
    enum CodingKeys: String, CodingKey {
        case scheduleRecordId, scheduleId
        case userId
        case title
        case startDate, endDate
        case notificationType
        case notificationCustomHours, notificationCustomMinutes
        case repeatType
        case repeatEndsOn
        case location
        case color
        case memo
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        
        // Decode ID
        if let id = try container.decodeIfPresent(String.self, forKey: .scheduleRecordId) {
            self.scheduleRecordId = id
        } else if let id = try container.decodeIfPresent(String.self, forKey: .scheduleId) {
            self.scheduleRecordId = id
        } else {
            throw DecodingError.dataCorruptedError(forKey: .scheduleRecordId, in: container, debugDescription: "No scheduleRecordId or scheduleId found")
        }
        
        self.userId = try container.decodeIfPresent(String.self, forKey: .userId)
        self.title = try container.decode(String.self, forKey: .title)
        
        self.startDate = try container.decode([Int].self, forKey: .startDate)
        self.endDate = try container.decode([Int].self, forKey: .endDate)
        
        self.notificationType = try container.decodeIfPresent(String.self, forKey: .notificationType)
        self.notificationCustomHours = try container.decodeIfPresent(Int.self, forKey: .notificationCustomHours)
        self.notificationCustomMinutes = try container.decodeIfPresent(Int.self, forKey: .notificationCustomMinutes)
        self.repeatType = try container.decodeIfPresent(String.self, forKey: .repeatType)
        
        // Decode repeatEndsOn
        if let endsOnStr = try container.decodeIfPresent(String.self, forKey: .repeatEndsOn) {
            let formatter = DateFormatter()
            formatter.dateFormat = "yyyy-MM-dd"
            self.repeatEndsOn = formatter.date(from: endsOnStr)
        } else {
            self.repeatEndsOn = nil
        }
        
        self.location = try container.decodeIfPresent(String.self, forKey: .location)
        self.color = try container.decode(String.self, forKey: .color)
        self.memo = try container.decodeIfPresent(String.self, forKey: .memo)
    }
}
