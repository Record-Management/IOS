import Foundation
import Alamofire

struct DefaultNotificationRepository: NotificationRepository {
    private let intergrationManager: IntergrationManager
    
    init(intergrationManager: IntergrationManager = .shared) {
        self.intergrationManager = intergrationManager
    }
    
    func fetchNotifications() async -> Result<NotificationDTO, LoginError> {
        guard let domain = await intergrationManager.manager.domain, let url = URL(string: "\(domain)/api/notifications/history") else {
            return .failure(.networkError(.invalidURL(url: "/api/notifications/history")))
        }
        guard let accessToken = await intergrationManager.manager.keyChain.read(account: "accessToken") else {
            return .failure(.notToken)
        }

        let headers: HTTPHeaders = [
            "Authorization": "Bearer \(accessToken)"
        ]
        
        let task = AF.request(
            url,
            method: .get,
            headers: headers
        )
        
        let result = await intergrationManager.withTokenRetry {
            let response = try await task.serializingDecodable(NotificationDTO.self).value
            return response
        }
        
        return result
    }
}
