import Foundation
import Alamofire

/// 운동 기록(Exercise Record)의 CUD 작업을 처리하는 레포지토리 구현체입니다.
struct DefaultExerciseRecordRepository: RecordRepository {
    typealias RequestType = ExerciseBody
    typealias ResponseType = ExerciseDTO
    let manager: IntergrationManager
    let keyChain: KeyChainManager = .shared
    
    init(manager: IntergrationManager) {
        self.manager = manager
    }
    
    /// 새로운 운동 기록을 생성합니다.
    func create(form: ExerciseBody) async throws(RecordRepositoryError) -> ExerciseDTO {
        let url = DomainManager.Path.exerciseCreate.url
        guard let url = url else {
            throw .inVaildURL(url: DomainManager.Path.exerciseCreate.urlString)
        }
        
        guard let accessToken = await keyChain.read(account: "accessToken") else {
            throw .notToken
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
            let result = try await manager.withTokenRetry {
                let response = try await task.serializingDecodable(ExerciseDTO.self).value
                guard let status = response.statusCode else {
                    throw LoginError.invaildRequest
                }
                switch status {
                case 200..<300:
                    break // 성공 케이스
                case 400:
                    throw RecordRepositoryError.recordLimit
                default:
                    throw LoginError.invaildRequest
                }
                return response
            }
            return result
        } catch {
            Log.error(error.localizedDescription)
            throw .exerciseCreateFailed
        }
    }
    
    /// 기존 운동 기록을 수정합니다.
    func update(recordId: String, form: ExerciseBody) async throws(RecordRepositoryError) -> ExerciseDTO {
        let urlString = DomainManager.Path.exerciseUpdate(recordId: recordId).urlString
        guard let url = URL(string: urlString) else {
            throw .inVaildURL(url: urlString)
        }
        
        guard let accessToken = await keyChain.read(account: "accessToken") else {
            throw .notToken
        }

        let headers: HTTPHeaders = [
            "Authorization": "Bearer \(accessToken)"
        ]
        
        let task = AF.request(
            url,
            method: .put,
            parameters: form,
            encoder: JSONParameterEncoder.default,
            headers: headers
        )
        
        do {
            let result = try await manager.withTokenRetry {
                let response = try await task.serializingDecodable(ExerciseDTO.self).value
                guard let status = response.statusCode else {
                    throw LoginError.invaildRequest
                }
                switch status {
                case 200..<300:
                    break // 성공 케이스
                default:
                    throw LoginError.invaildRequest
                }
                return response
            }
            return result
        } catch {
            Log.error(error.localizedDescription)
            throw .unknown(error)
        }
    }
    
    /// 특정 운동 기록을 삭제합니다.
    func delete(recordId: String) async throws(RecordRepositoryError) {
        let urlString = DomainManager.Path.exerciseDelete(recordId: recordId).urlString
        guard let url = URL(string: urlString) else {
            throw .inVaildURL(url: urlString)
        }
        
        guard let accessToken = await keyChain.read(account: "accessToken") else {
            throw .notToken
        }

        let headers: HTTPHeaders = [
            "Authorization": "Bearer \(accessToken)"
        ]
        
        let task = AF.request(
            url,
            method: .delete,
            headers: headers
        )
        
        do {
            let result = try await manager.withTokenRetry {
                let response = task.serializingData()
                return response
            }
        } catch {
            Log.error(error.localizedDescription)
            throw .unknown(error)
        }
    }
}
