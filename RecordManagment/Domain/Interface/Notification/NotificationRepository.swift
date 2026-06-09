import Foundation

/// 알림 조회 및 알림 설정 관리를 담당하는 레포지토리 인터페이스입니다.
protocol NotificationRepository {
    /// 유저의 알림 목록을 조회합니다.
    func fetchNotifications() async throws(NotificationRepositoryError) -> NotificationDTO
    
    /// 현재 알림 목록을 읽음 처리 합니다.
    func updateNotification() async throws(NotificationRepositoryError)
    
    /// 알림 상태 설정을 업데이트합니다.
    func notificationRecordUpdate(data: NotificationSettingRequestBody) async throws(NotificationRepositoryError) -> NotificationSettingDTO
    
    /// 초기 알림 설정 상태를 동기화 및 조회합니다.
    func initStateNotificationSetting() async throws(NotificationRepositoryError) -> NotificationSettingDTO
}
