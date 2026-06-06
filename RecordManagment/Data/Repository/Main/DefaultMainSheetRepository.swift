import Foundation
import Alamofire

struct DefaultMainSheetRepository: MainSheetRepository {
    private let intergrationManager: IntergrationManager
    
    init(intergrationManager: IntergrationManager = .shared) {
        self.intergrationManager = intergrationManager
    }
    
    func fetchCompletionHabit(_ isCompleted: Bool ,recordId: String) async -> Result<HabitDTO, LoginError> {
        let domain = intergrationManager.domain
        guard let url = URL(string: "\(domain)/api/habit-records/\(recordId)/completion") else {
            return .failure(.networkError(.invalidURL(url: "/api/habit-records/\(recordId)/completion")))
        }
        
        guard let accessToken = await intergrationManager.keyChain.read(account: "accessToken") else {
            return .failure(.notToken)
        }

        let headers: HTTPHeaders = [
            "Authorization": "Bearer \(accessToken)"
        ]
        
        let parameters: Parameters = [
            "isCompleted" : isCompleted
        ]
        
        let task = AF.request(
            url,
            method: .patch,
            parameters: parameters,
            encoding: JSONEncoding.default,
            headers: headers
        )
        
        do {
            let response = try await intergrationManager.withTokenRetry {
                return try await task.serializingDecodable(HabitDTO.self).value
            }
            return .success(response)
        } catch {
            return .failure(error)
        }
    }
}
