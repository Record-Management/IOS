import Foundation

/// 일정 기록 http통신 중 Post, Update 용 형식
struct ScheduleFormat: Codable {
    let title: String
    let startDate: String
    let endDate: String
    let notificationType: String
    let notificationCustomHours: Int?
    let notificationCustomMinutes: Int?
    let repeatType: String
    let repeatEndsOn: String?
    let location: String?
    let color: String
    let memo: String?
}
