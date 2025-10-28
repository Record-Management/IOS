import Foundation
import Alamofire

class DefaultNotificationRepository: NotificationRepository {
    let common: IntergrationManager = .shared
    
    func fetchNotifications() async -> Result<NotificationDTO, LoginError> {
        guard let domain = await common.manager.domain, let url = URL(string: "\(domain)/api/notifications/history") else {
            return .failure(.networkError(.invalidURL(url: "/api/notifications/history")))
        }
        guard let accessToken = await common.manager.keyChain.read(account: "accessToken") else {
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
        
        let result = await common.withTokenRetry {
            let response = try await task.serializingDecodable(NotificationDTO.self).value
            return response
        }
        
        return result
    }
}
