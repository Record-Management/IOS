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
            
            if let data = response.data {
                let decoded = try JSONDecoder().decode(ExerciseDTO.self, from: data)
                print("운동기록 Decoded 결과 : \(decoded)")
                return decoded
            }
            
            throw LoginError.networkError(.responseSerializationFailed(
                reason: .inputDataNilOrZeroLength
            ))
        }
        
        switch result {
            case .success(let data):
                return .success(data)
            case .failure(let error):
                return .failure(error)
        }
    }
}
