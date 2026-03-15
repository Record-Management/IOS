import Foundation
import Alamofire

struct DefaultMainSheetRepository: MainSheetRepository {
    private let intergrationManager: IntergrationManager
    
    init(intergrationManager: IntergrationManager = .shared) {
        self.intergrationManager = intergrationManager
    }
    
    func fetchCompletionHabit(_ isCompleted: Bool ,recordId: String) async -> Result<HabitDTO, LoginError> {
        guard let domain = await intergrationManager.manager.domain, let url = URL(string: "\(domain)/api/habit-records/\(recordId)/completion") else {
            return .failure(.networkError(.invalidURL(url: "/api/habit-records/\(recordId)/completion")))
        }
        
        guard let accessToken = await intergrationManager.manager.keyChain.read(account: "accessToken") else {
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
        
        let result = await intergrationManager.withTokenRetry {
            let response = try await task.serializingDecodable(HabitDTO.self).value
            return response
        }
        
        switch result {
            case .success(let data):
                return .success(data)
            case .failure(let error):
                return .failure(error)
        }
    }
}
