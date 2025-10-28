import Foundation

class NotificationUseCase {
    private let repository: NotificationRepository
    
    init(repository: NotificationRepository) {
        self.repository = repository
    }
    
    func fetch() async throws -> NotificationData {
        let result = await repository.fetchNotifications()
        
        switch result {
            case .success(let res):
                if let data = res.data {
                    return data
                }
                throw URLError(.badServerResponse)
            case .failure(let err):
                throw err
        }
    }
}
