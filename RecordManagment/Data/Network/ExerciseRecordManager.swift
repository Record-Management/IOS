import Foundation
import Alamofire

struct ExerciseRecordManager {
    private let keyChain: KeyChainManager
    private let intergrationManager: IntergrationManager
    private var domain: String?
    
    init(keyChain: KeyChainManager = .shared, intergrationManager: IntergrationManager = .shared) {
        self.keyChain = keyChain
        self.intergrationManager = intergrationManager
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
        
        let result = await intergrationManager.withTokenRetry {
            let response = await task.serializingData().response
            let statusCode = response.response?.statusCode ?? -1
            debugPrint("statusCode : \(statusCode)")
            guard (200..<300).contains(statusCode) else {
                switch statusCode {
                case 400:
                    // 운동 기록 제한
                    if let data = response.data {
                        let decoded = try JSONDecoder().decode(ExerciseDTO.self, from: data)
                        if decoded.code == "E40408" || decoded.code == "E40410" {
                            return decoded
                        }
                    }
                    
                    throw URLError(.notConnectedToInternet)
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
    
    // TODO: Exercise Record 수정 PUT API
    func exerciseRecordRead(form: ExerciseBody, recordId: String ,retryCount: Int = 0) async -> Result<ExerciseDTO, LoginError> {
        guard let domain = domain, let url = URL(string: "\(domain)/api/exercise-records/\(recordId)") else {
            return .failure(.networkError(.invalidURL(url: "/api/exercise-records")))
        }
        
        guard let accessToken = keyChain.read(account: "accessToken") else {
            return .failure(.notToken)
        }
        
        let headers: HTTPHeaders = [
            "Authorization": "Bearer \(accessToken)",
            "Content-Type": "application/json"
        ]
        
        let task = AF.request(
            url,
            method: .put,
            parameters: form,
            encoder: JSONParameterEncoder.default,
            headers: headers
        )
        
        let result = await intergrationManager.withTokenRetry {
            let response = try await task.serializingDecodable(ExerciseDTO.self).value
            return response
        }
        
        switch result {
        case .success(let data):
            debugPrint(data)
            return .success(data)
        case .failure(let error):
            debugPrint(error)
            return .failure(error)
        }
    }
    
    // TODO: Exercise Record 삭제 DELETE API
    func exerciseRecordRemove(recordId: String) async -> Result<ExerciseDTO, LoginError> {
        guard let domain = domain, let url = URL(string: "\(domain)/api/exercise-records/\(recordId)") else {
            return .failure(.networkError(.invalidURL(url: "/api/exercise-records")))
        }
        
        guard let accessToken = keyChain.read(account: "accessToken") else {
            return .failure(.notToken)
        }

        let headers: HTTPHeaders = [
            "Authorization": "Bearer \(accessToken)",
            "Content-Type": "application/json"
        ]
        
        let task = AF.request(
            url,
            method: .delete,
            headers: headers
        )
        
        let result = await intergrationManager.withTokenRetry {
            let response = try await task.serializingDecodable(ExerciseDTO.self).value
            return response
        }
        
        switch result {
            case .success(let data):
                debugPrint(data)
                return .success(data)
            case .failure(let error):
                debugPrint(error)
                return .failure(error)
        }
    }
}
