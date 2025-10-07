import SwiftUI

/// ** 특정 Calender DTO

struct CalendarDetail: Codable {
    let statusCode: Int
    let code: String
    let message: String
    let data: CalendarDetailData?
}

struct CalendarDetailData: Codable {
    let date: [Int]
    let records: [IntergrationRecord]
}

/// ** 공통 프로퍼티
struct RecordResponse: Codable, Identifiable, Equatable, Hashable {
    let id: String
    let type: String
    let recordDate: [Int]
    let recordTime: [Int]
    let createdAt: [Int]
    let updatedAt: [Int]
}

/// ** 일정 기록
struct DailyResponse: Codable, Equatable, Hashable {
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
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(base.id, forKey: .id)
        try container.encode(base.type, forKey: .type)
        try container.encode(base.recordDate, forKey: .recordDate)
        try container.encode(base.recordTime, forKey: .recordTime)
        try container.encode(base.createdAt, forKey: .createdAt)
        try container.encode(base.updatedAt, forKey: .updatedAt)
        try container.encode(emotion, forKey: .emotion)
        try container.encode(content, forKey: .content)
        try container.encode(imageUrls, forKey: .imageUrls)
    }
}

/// ** 운동 기록
struct ExerciseResponse: Codable, Equatable, Hashable {
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
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(base.id, forKey: .id)
        try container.encode(base.type, forKey: .type)
        try container.encode(base.recordDate, forKey: .recordDate)
        try container.encode(base.recordTime, forKey: .recordTime)
        try container.encode(base.createdAt, forKey: .createdAt)
        try container.encode(base.updatedAt, forKey: .updatedAt)
        try container.encode(exerciseType, forKey: .exerciseType)
        try container.encodeIfPresent(caloriesBurned, forKey: .caloriesBurned)
        try container.encodeIfPresent(exerciseTimeMinutes, forKey: .exerciseTimeMinutes)
        try container.encodeIfPresent(stepCount, forKey: .stepCount)
        try container.encodeIfPresent(weight, forKey: .weight)
        try container.encode(dailyNote, forKey: .dailyNote)
        try container.encode(imageUrls, forKey: .imageUrls)
    }
}

// MARK: 통합 기록 분류 Enum
enum IntergrationRecord: Codable, Hashable, Equatable {
    case daily(DailyResponse)
    case exercise(ExerciseResponse)
    
    init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        let base = try container.decode(RecordResponse.self)
        
        switch base.type {
            case "DAILY":
                self = .daily(try container.decode(DailyResponse.self))
            case "EXERCISE":
                self = .exercise(try container.decode(ExerciseResponse.self))
        default:
            throw DecodingError.dataCorruptedError(in: container, debugDescription: "UnKown Type: \(base.type)")
        }
    }
    
    func encode(to encoder: Encoder) throws {
        switch self {
            case .daily(let record):
                try record.encode(to: encoder)
            case .exercise(let record):
                try record.encode(to: encoder)
        }
    }
    
    
}
