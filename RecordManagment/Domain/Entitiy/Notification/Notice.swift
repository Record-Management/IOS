import Foundation

struct Notice: Hashable {
    let record: NotificationFilter
    let title: String
    let time: Date
    let text: String
    let isRead: Bool
}
