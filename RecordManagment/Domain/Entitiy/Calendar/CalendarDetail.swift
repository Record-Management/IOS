import SwiftUI

/// ** 특정 Calender DTO

struct CalendarDetail: Decodable {
    let statusCode: Int
    let code: String
    let message: String
    let data: CalendarDetailData?
}

struct CalendarDetailData: Decodable {
    let date: [Int]
    let records: [IntergrationRecord]
}

/// ** 공통 프로퍼티
struct RecordResponse: Decodable, Identifiable, Equatable, Hashable {
    let id: String
    let type: String
    let recordDate: [Int]
    let recordTime: [Int]?
    let createdAt: [Int]
    let updatedAt: [Int]
}

/// ** 일정 기록
struct DailyResponse: Decodable, Equatable, Hashable {
    let base: RecordResponse
    let emotion: String
    let content: String
    let imageUrls: [String]
    
    enum CodingKeys: String, CodingKey {
        case id, type, recordDate, recordTime, createdAt, updatedAt
        case emotion, content, imageUrls
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        let id = try container.decode(String.self, forKey: .id)
        let type = try container.decode(String.self, forKey: .type)
        let imageUrls = try container.decodeIfPresent([String].self, forKey: .imageUrls) ?? []
        let recordDate = try container.decode([Int].self, forKey: .recordDate)
        let recordTime = try container.decode([Int].self, forKey: .recordTime)
        let createdAt = try container.decode([Int].self, forKey: .createdAt)
        let updatedAt = try container.decode([Int].self, forKey: .updatedAt)
        let emotion = try container.decode(String.self, forKey: .emotion)
        let content = try container.decode(String.self, forKey: .content)
        self.base = RecordResponse(id: id, type: type, recordDate: recordDate, recordTime: recordTime, createdAt: createdAt, updatedAt: updatedAt)
        self.emotion = emotion
        self.content = content
        self.imageUrls = imageUrls
    }
}

/// ** 운동 기록
struct ExerciseResponse: Decodable, Equatable, Hashable {
    let base: RecordResponse
    let exerciseType: String
    let caloriesBurned: Int?
    let exerciseTimeMinutes: Int?
    let stepCount: Int?
    let weight: Int?
    let dailyNote: String
    let imageUrls: [String]
    
    enum CodingKeys: String, CodingKey {
        case id, type, recordDate, recordTime, createdAt, updatedAt
        case exerciseType, caloriesBurned, exerciseTimeMinutes, stepCount, weight, dailyNote, imageUrls
    }
    
    init(
        base: RecordResponse,
        exerciseType: String,
        caloriesBurned: Int? = nil,
        exerciseTimeMinutes: Int? = nil,
        stepCount: Int? = nil,
        weight: Int? = nil,
        dailyNote: String,
        imageUrls: [String] = []
    ) {
        self.base = base
        self.exerciseType = exerciseType
        self.caloriesBurned = caloriesBurned
        self.exerciseTimeMinutes = exerciseTimeMinutes
        self.stepCount = stepCount
        self.weight = weight
        self.dailyNote = dailyNote
        self.imageUrls = imageUrls
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        let id = try container.decode(String.self, forKey: .id)
        let type = try container.decode(String.self, forKey: .type)
        let imageUrls = try container.decodeIfPresent([String].self, forKey: .imageUrls) ?? []
        let recordDate = try container.decode([Int].self, forKey: .recordDate)
        let recordTime = try container.decode([Int].self, forKey: .recordTime)
        let createdAt = try container.decode([Int].self, forKey: .createdAt)
        let updatedAt = try container.decode([Int].self, forKey: .updatedAt)
        let exerciseType = try container.decode(String.self, forKey: .exerciseType)
        let caloriesBurned = try container.decodeIfPresent(Int.self, forKey: .caloriesBurned)
        let exerciseTimeMinutes = try container.decodeIfPresent(Int.self, forKey: .exerciseTimeMinutes)
        let stepCount = try container.decodeIfPresent(Int.self, forKey: .stepCount)
        let weight = try container.decodeIfPresent(Int.self, forKey: .weight)
        let dailyNote = try container.decode(String.self, forKey: .dailyNote)
        self.base = RecordResponse(id: id, type: type, recordDate: recordDate, recordTime: recordTime, createdAt: createdAt, updatedAt: updatedAt)
        self.exerciseType = exerciseType
        self.caloriesBurned = caloriesBurned
        self.exerciseTimeMinutes = exerciseTimeMinutes
        self.stepCount = stepCount
        self.weight = weight
        self.dailyNote = dailyNote
        self.imageUrls = imageUrls
    }
}

struct HabitResponse: Decodable, Hashable, Equatable {
    let base: RecordResponse
    let habitType: String
    let notificationEnabled: Bool
    let notificationTime: [Int]?
    let memo: String?
    let isCompleted: Bool?
    let isMainRecord: Bool
    
    init(base: RecordResponse, habitType: String, notificationEnabled: Bool, notificationTime: [Int]?, memo: String?, isCompleted: Bool?, isMainRecord: Bool) {
        self.base = base
        self.habitType = habitType
        self.notificationEnabled = notificationEnabled
        self.notificationTime = notificationTime
        self.memo = memo
        self.isCompleted = isCompleted
        self.isMainRecord = isMainRecord
    }
    
    enum CodingKeys: String, CodingKey {
        case id, type, recordDate, recordTime, createdAt, updatedAt
        case habitType, notificationEnabled, notificationTime, memo, isCompleted, isMainRecord
    }
    
    init(from decoder: any Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        let id = try container.decode(String.self, forKey: .id)
        let type = try container.decode(String.self, forKey: .type)
        let recordDate = try container.decode([Int].self, forKey: .recordDate)
        let recordTime = try container.decodeIfPresent([Int].self, forKey: .recordTime) ?? []
        let createdAt = try container.decode([Int].self, forKey: .createdAt)
        let updatedAt = try container.decode([Int].self, forKey: .updatedAt)
        self.base = RecordResponse(id: id, type: type, recordDate: recordDate, recordTime: recordTime, createdAt: createdAt, updatedAt: updatedAt)
        let habitType = try container.decode(String.self, forKey: .habitType)
        let notificationEnabled = try container.decode(Bool.self, forKey: .notificationEnabled)
        let notificationTime = try container.decodeIfPresent([Int].self, forKey: .notificationTime) ?? []
        let memo = try container.decodeIfPresent(String.self, forKey: .memo) ?? ""
        let isCompleted = try container.decodeIfPresent(Bool.self, forKey: .isCompleted)
        let isMainRecord = try container.decode(Bool.self, forKey: .isMainRecord)
        self.habitType = habitType
        self.notificationEnabled = notificationEnabled
        self.notificationTime = notificationTime
        self.memo = memo
        self.isCompleted = isCompleted
        self.isMainRecord = isMainRecord
    }
}

// MARK: 통합 기록 분류 Enum
enum IntergrationRecord: Decodable, Hashable, Equatable {
    case daily(DailyResponse)
    case exercise(ExerciseResponse)
    case habit(HabitResponse)
    
    init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        let base = try container.decode(RecordResponse.self)
        
        switch base.type {
            case "DAILY":
                self = .daily(try container.decode(DailyResponse.self))
            case "EXERCISE":
                self = .exercise(try container.decode(ExerciseResponse.self))
            case "HABIT":
                self = .habit(try container.decode(HabitResponse.self))
            default:
                throw DecodingError.dataCorruptedError(in: container, debugDescription: "UnKown Type: \(base.type)")
        }
    }
    
    var name: String {
        switch self {
        case .daily(_):
            "DAILY"
        case .exercise(_):
            "EXERCISE"
        case .habit(_):
            "HABIT"
        }
    }
}
