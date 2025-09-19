import SwiftUI

/// ** 특정 Calender DTO

struct CalenderDetail: Codable {
    let statusCode: Int
    let code: String
    let message: String
    let data: CalenderDetailData?
}

struct CalenderDetailData: Codable {
    let date: [Int]
    let records: [DailyResponse]
}

