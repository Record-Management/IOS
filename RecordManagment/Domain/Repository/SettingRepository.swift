import Foundation

protocol SettingRepository {
    func updateProfile(form: [String : Any]) async throws -> Result<User, LoginError>
    // 알림 상태 업데이트
    func notificationRecordUpdate(data: NotificationSettingRequestBody) async -> Result<NotificationSettingDTO, LoginError>
    // 초기 알림 Init 함수
    func initStateNotificationSetting() async -> Result<NotificationSettingDTO, LoginError>
    
    // 목표 재설정 Test API Code
    func apiTest() async throws
}
