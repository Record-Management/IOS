import Foundation

struct HabitRequestBody: Encodable {
    let habitType: String
    let notificationEnabled: Bool
    let notificationTime: String?
    let memo: String?
    let recordDate: String
}
