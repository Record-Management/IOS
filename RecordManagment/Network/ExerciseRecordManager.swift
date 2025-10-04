import Foundation
import Alamofire

class ExerciseRecordManager {
    let keyChain: KeyChainManager = .shared
    let manager: IntergrationManager = .shared
    var domain: String?
    
    init() {
        if let serverURL = Bundle.main.infoDictionary?["SERVER_DEV_URL"] as? String {
            domain = serverURL
        }
    }
    
    // TODO: Daily Record 작성 POST API
    func exerciseRecordCreate(form: ExerciseBody, retryCount: Int = 0) async -> Result<ExerciseDTO, LoginError> {
        guard let domain = domain, let url = URL(string: "\(domain)/api/exercise-records") else {
            return .failure(.networkError(.invalidURL(url: "/api/exercise-records")))
        }
        
        guard let accessToken = keyChain.read(account: "accessToken") else {
            return .failure(.notToken)
        }

        let headers: HTTPHeaders = [
            "Authorization": "Bearer \(accessToken)"
        ]
        
        let task = AF.request(
            url,
            method: .post,
            parameters: form,
            encoder: JSONParameterEncoder.default,
            headers: headers
        )
        
        let result = await manager.withTokenRetry {
            let response = await task.serializingData().response
            let statusCode = response.response?.statusCode ?? -1
            debugPrint("statusCode : \(statusCode)")
            guard (200..<300).contains(statusCode) else {
                switch statusCode {
                case 400..<500:
                    throw LoginError.invaildRequest
                case 500..<600:
                    throw LoginError.serverError
                default:
                    throw LoginError.unknown(NSError(domain: "CreateExercise", code: statusCode, userInfo: nil))
                }
            }
            
            if let data = response.data {
                let decoded = try JSONDecoder().decode(ExerciseDTO.self, from: data)
                return decoded
            }
            
            throw LoginError.unknown(NSError(domain: "CreateExercise", code: statusCode, userInfo: nil))
        }
        
        switch result {
            case .success(let data):
                return .success(data)
            case .failure(let error):
                debugPrint("error : \(error)")
                return .failure(error)
        }
    }
}
