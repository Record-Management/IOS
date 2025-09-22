import SwiftUI

/// ** 하루 기록  DTO
struct DailyDTO: Codable {
    let statusCode: Int?
    let code: String
    let message: String
    let data: DailyResponse?
    
    enum CodingKeys: String, CodingKey {
        case statusCode
        case code
        case message
        case data
    }
}

struct DailyResponse: Codable, Identifiable {
    let id: String
    let type: String
    let emotion: String
    let content: String
    let imageUrls: [String]
    let recordDate: [Int]
    let recordTime: [Int]
    let createdAt: [Int]
    let updatedAt: [Int]
}
