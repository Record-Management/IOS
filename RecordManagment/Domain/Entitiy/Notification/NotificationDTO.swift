import Foundation

struct NotificationDTO: Decodable {
    let statusCode: Int
    let code: String
    let message: String
    let data: NotificationData?
}

struct NotificationData: Decodable {
    let notifications: NotificationResponse
    let recentCheckedAt: [Int]?
}

struct NotificationResponse: Decodable {
    let items: [NotificationItem]
    let pageInfo: PageInfo?
}

struct NotificationItem: Decodable, Hashable {
    let mainRecordType: String
    let description: String
    let sentAt: [Int]
}

struct PageInfo: Decodable {
    let page: Int
    let size: Int
    let totalElements: Int
    let totalPages: Int
}
