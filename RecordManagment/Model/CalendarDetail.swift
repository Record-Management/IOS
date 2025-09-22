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
    let records: [DailyResponse]
}

