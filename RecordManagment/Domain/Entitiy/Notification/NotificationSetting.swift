import Foundation

struct NotificationSettingRequestBody: Encodable {
    let dailyRecordNotificationEnabled: Bool?
    let exerciseNotificationEnabled: Bool?
    let habitNotificationEnabled: Bool?
    let goalSettingNotificationEnabled: Bool?
    let scheduleNotificationEnabled: Bool?
    
    init(
        dailyRecordNotificationEnabled: Bool? = nil,
        exerciseNotificationEnabled: Bool? = nil,
        habitNotificationEnabled: Bool? = nil,
        goalSettingNotificationEnabled: Bool? = nil,
        scheduleNotificationEnabled: Bool? = nil
    ) {
        self.dailyRecordNotificationEnabled = dailyRecordNotificationEnabled
        self.exerciseNotificationEnabled = exerciseNotificationEnabled
        self.habitNotificationEnabled = habitNotificationEnabled
        self.goalSettingNotificationEnabled = goalSettingNotificationEnabled
        self.scheduleNotificationEnabled = scheduleNotificationEnabled
    }
}

struct NotificationSettingDTO: Decodable {
    let statusCode: Int
    let code: String
    let message: String
    let data: NotificationSettingData?
}

struct NotificationSettingData: Decodable {
    let userId: String
    let dailyRecordNotificationEnabled: Bool
    let exerciseNotificationEnabled: Bool
    let habitNotificationEnabled: Bool
    let goalSettingNotificationEnabled: Bool
    let scheduleNotificationEnabled: Bool
}
