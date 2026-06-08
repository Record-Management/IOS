import Foundation

protocol NotificationUseCase {
    func fetch() async throws -> NotificationData
}

struct DefaultNotificationUseCase: NotificationUseCase {
    private let repository: NotificationRepository
    
    init(repository: NotificationRepository) {
        self.repository = repository
    }
    
    func fetch() async throws -> NotificationData {
        do {
            let res = try await repository.fetchNotifications()
            if let data = res.data {
                return data
            }
            throw URLError(.badServerResponse)
        } catch {
            throw error
        }
    }
}

