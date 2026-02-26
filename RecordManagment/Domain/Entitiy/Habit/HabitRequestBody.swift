import Foundation

struct HabitRequestBody: Encodable {
    let habitType: String
    let notificationEnabled: Bool
    let notificationTime: String?
    let memo: String?
    let recordDate: String?
    let isMainRecord: Bool
    
    init(habitType: String, notificationEnabled: Bool, notificationTime: String?, memo: String?, recordDate: String?, isMainRecord: Bool) {
        self.habitType = habitType
        self.notificationEnabled = notificationEnabled
        self.notificationTime = notificationTime
        self.memo = memo
        self.recordDate = recordDate
        self.isMainRecord = isMainRecord
    }
}
