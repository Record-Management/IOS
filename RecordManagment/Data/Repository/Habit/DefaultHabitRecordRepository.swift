import Foundation
import Alamofire

/// 습관 기록(Habit Record)의 CRUD 작업을 처리하는 레포지토리 구현체입니다.
struct DefaultHabitRecordRepository: HabitRepository {
    typealias RequestType = HabitRequestBody
    typealias ResponseType = HabitDTO
    let manager: IntergrationManager
    let keyChain: KeyChainManager = .shared
    
    init(manager: IntergrationManager) {
        self.manager = manager
    }
    
    /// 새로운 습관 기록을 생성합니다.
    func create(form: HabitRequestBody) async throws(RecordRepositoryError) -> HabitDTO {
        let url = DomainManager.Path.habitCreate.url
        guard let url = url else {
            throw .inVaildURL(url: DomainManager.Path.habitCreate.urlString)
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
                let response = try await task.serializingDecodable(HabitDTO.self).value
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
            if let repoError = error as? RecordRepositoryError {
                throw repoError
            }
            throw .habitCreateFailed
        }
    }
    
    /// 기존 습관 기록을 수정합니다.
    func update(recordId: String, form: HabitRequestBody) async throws(RecordRepositoryError) -> HabitDTO {
        let urlString = DomainManager.Path.habitUpdate(recordId: recordId).urlString
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
                let response = try await task.serializingDecodable(HabitDTO.self).value
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
    
    /// 특정 습관 기록을 삭제합니다.
    func delete(recordId: String) async throws(RecordRepositoryError) -> HabitDTO {
        let urlString = DomainManager.Path.habitDelete(recordId: recordId).urlString
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
                let response = try await task.serializingDecodable(HabitDTO.self).value
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
    
    /// 습관 완료 상태(isCompleted)를 업데이트/조회합니다.
    func fetchCompletionHabit(_ isCompleted: Bool, recordId: String) async throws(RecordRepositoryError) -> HabitDTO {
        let url = DomainManager.Path.habitCompletion(recordId: recordId).url
        guard let url = url else {
            throw .inVaildURL(url: DomainManager.Path.habitCompletion(recordId: recordId).urlString)
        }
        
        guard let accessToken = await keyChain.read(account: "accessToken") else {
            throw .notToken
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
            let result = try await manager.withTokenRetry {
                let response = try await task.serializingDecodable(HabitDTO.self).value
                return response
            }
            return result
        } catch {
            Log.error(error.localizedDescription)
            throw .unknown(error)
        }
    }
}
