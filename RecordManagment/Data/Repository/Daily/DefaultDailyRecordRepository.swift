import Foundation
import Alamofire

/// 일기 기록(Daily Record)의 CRUD 작업을 처리하는 레포지토리 구현체입니다.
struct DefaultDailyRecordRepository: RecordRepository {
    typealias RequestType = DailyFormat
    typealias ResponseType = DailyDTO
    let manager: IntergrationManager
    let keyChain: KeyChainManager = .shared
    
    init(manager: IntergrationManager) {
        self.manager = manager
    }
    
    /// 새로운 일기 기록을 생성합니다.
    func create(form: DailyFormat, type: String) async throws(RecordRepositoryError) -> DailyDTO {
        let url = DomainManager.Path.dailyCreate.url
        guard let url = url else {
            throw .inVaildURL(url: DomainManager.Path.dailyCreate.urlString)
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
                let response = try await task.serializingDecodable(DailyDTO.self).value
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
            throw .dailyCreateFailed
        }
    }
    
    /// 기존 일기 기록을 수정합니다.
    func update(recordId: String, form: DailyFormat, type: String) async throws(RecordRepositoryError) -> DailyDTO {
        let urlString = DomainManager.Path.dailyUpdate(recordId: recordId).urlString
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
                let response = try await task.serializingDecodable(DailyDTO.self).value
                return response
            }
            return result
        } catch {
            Log.error(error.localizedDescription)
            throw .unknown(error)
        }
    }
    
    /// 특정 일기 기록을 삭제합니다.
    func delete(recordId: String, type: String) async throws(RecordRepositoryError) -> DailyDTO {
        let urlString = DomainManager.Path.dailyDelete(recordId: recordId).urlString
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
                let response = try await task.serializingDecodable(DailyDTO.self).value
                return response
            }
            return result
        } catch {
            Log.error(error.localizedDescription)
            throw .unknown(error)
        }
    }
}
