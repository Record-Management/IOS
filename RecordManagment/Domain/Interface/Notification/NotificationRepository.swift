import Foundation

protocol NotificationRepository {
    // get Notifications
    func fetchNotifications() async -> Result<NotificationDTO, LoginError>
}
