import SwiftUI

/// ** 하루 기록  DTO
struct DailyDTO: Decodable {
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
