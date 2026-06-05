import Foundation
import Alamofire

struct ExerciseRecordManager {
    private let keyChain: KeyChainManager
    private let intergrationManager: IntergrationManager
    
    init(keyChain: KeyChainManager = .shared, intergrationManager: IntergrationManager = .shared) {
        self.keyChain = keyChain
        self.intergrationManager = intergrationManager
    }
    
    // TODO: Daily Record 작성 POST API
    func exerciseRecordCreate(form: ExerciseBody, retryCount: Int = 0) async -> Result<ExerciseDTO, LoginError> {
        let domain = intergrationManager.domain
        guard let url = URL(string: "\(domain)/api/exercise-records") else {
            return .failure(.networkError(.invalidURL(url: "/api/exercise-records")))
        }
        
        guard let accessToken = await keyChain.read(account: "accessToken") else {
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
        
        do {
            let result = try await intergrationManager.withTokenRetry {
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
            return .success(result)
        } catch {
            debugPrint("error : \(error)")
            return .failure(error)
        }
    }
    
    // TODO: Exercise Record 수정 PUT API
    func exerciseRecordRead(form: ExerciseBody, recordId: String, retryCount: Int = 0) async -> Result<ExerciseDTO, LoginError> {
        let domain = intergrationManager.domain
        guard let url = URL(string: "\(domain)/api/exercise-records/\(recordId)") else {
            return .failure(.networkError(.invalidURL(url: "/api/exercise-records")))
        }
        
        guard let accessToken = await keyChain.read(account: "accessToken") else {
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
        
        do {
            let result = try await intergrationManager.withTokenRetry {
                let response = try await task.serializingDecodable(ExerciseDTO.self).value
                return response
            }
            debugPrint(result)
            return .success(result)
        } catch {
            debugPrint(error)
            return .failure(error)
        }
    }
    
    // TODO: Exercise Record 삭제 DELETE API
    func exerciseRecordRemove(recordId: String) async -> Result<ExerciseDTO, LoginError> {
        let domain = intergrationManager.domain
        guard let url = URL(string: "\(domain)/api/exercise-records/\(recordId)") else {
            return .failure(.networkError(.invalidURL(url: "/api/exercise-records")))
        }
        
        guard let accessToken = await keyChain.read(account: "accessToken") else {
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
        
        do {
            let result = try await intergrationManager.withTokenRetry {
                let response = try await task.serializingDecodable(ExerciseDTO.self).value
                return response
            }
            debugPrint(result)
            return .success(result)
        } catch {
            debugPrint(error)
            return .failure(error)
        }
    }
}
