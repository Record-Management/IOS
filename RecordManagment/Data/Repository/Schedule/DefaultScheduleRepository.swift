import Foundation
import Alamofire

/// 일정 기록(Schedule Record)의 CRUD 작업을 처리하는 레포지토리 구현체입니다.
struct DefaultScheduleRepository: ScheduleRepository {
    private let manager: IntergrationManager
    
    init(manager: IntergrationManager) {
        self.manager = manager
    }
    
    /// 새로운 일정을 생성합니다.
    func create(form: ScheduleFormat) async throws(ScheduleRepositoryError) -> ScheduleResponse {
        let url = DomainManager.Path.scheduleCreate.url
        guard let url = url else {
            throw .unknown(NSError(domain: "DefaultScheduleRepository", code: -1, userInfo: [NSLocalizedDescriptionKey: "Invalid URL"]))
        }
        
        guard let accessToken = await manager.keyChain.read(account: "accessToken") else {
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
                let response = await task.serializingData().response
                let statusCode = response.response?.statusCode ?? -1
                
                guard (200..<300).contains(statusCode) else {
                    debugPrint("statusCode : \(statusCode)")
                    switch statusCode {
                    case 400:
                        // 일정 기록 제한
                        throw ScheduleRepositoryError.recordLimit
                    case 500..<600:
                        throw ScheduleRepositoryError.serverError
                    default:
                        throw ScheduleRepositoryError.unknown(NSError(domain: "CreateDaily", code: statusCode, userInfo: nil))
                    }
                }
                
                guard let data = response.data else {
                    throw ScheduleRepositoryError.unknown(NSError(domain: "CreateDaily", code: statusCode, userInfo: nil))
                }
                
                do {
                    let decoded = try JSONDecoder().decode(ScheduleResponse.self, from: data)
                    return decoded
                } catch {
                    throw ScheduleRepositoryError.unknown(error)
                }
            }
            return result
        } catch {
            throw ScheduleRepositoryError.from(error, defaultFailedCase: .createFailed)
        }
    }
    
    /// 기존 일정을 수정합니다.
    func update(scheduleId: String, form: ScheduleFormat) async throws(ScheduleRepositoryError) -> ScheduleResponse {
        let url = DomainManager.Path.scheduleDetail(scheduleId: scheduleId).url
        guard let url = url else {
            throw .unknown(NSError(domain: "DefaultScheduleRepository", code: -1, userInfo: [NSLocalizedDescriptionKey: "Invalid URL"]))
        }
        
        guard let accessToken = await manager.keyChain.read(account: "accessToken") else {
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
                let response = await task.serializingData().response
                let statusCode = response.response?.statusCode ?? -1
                
                guard (200..<300).contains(statusCode) else {
                    debugPrint("statusCode : \(statusCode)")
                    switch statusCode {
                    case 500..<600:
                        throw ScheduleRepositoryError.serverError
                    default:
                        throw ScheduleRepositoryError.unknown(NSError(domain: "UpdateSchedule", code: statusCode, userInfo: nil))
                    }
                }
                
                guard let data = response.data else {
                    throw ScheduleRepositoryError.unknown(NSError(domain: "UpdateSchedule", code: statusCode, userInfo: nil))
                }
                
                do {
                    let decoded = try JSONDecoder().decode(ScheduleResponse.self, from: data)
                    return decoded
                } catch {
                    throw ScheduleRepositoryError.unknown(error)
                }
            }
            return result
        } catch {
            throw ScheduleRepositoryError.from(error, defaultFailedCase: .updateFailed)
        }
    }
    
    /// 특정 일정을 삭제합니다.
    func delete(scheduleId: String) async throws(ScheduleRepositoryError) {
        let url = DomainManager.Path.scheduleDetail(scheduleId: scheduleId).url
        guard let url = url else {
            throw .unknown(NSError(domain: "DefaultScheduleRepository", code: -1, userInfo: [NSLocalizedDescriptionKey: "Invalid URL"]))
        }
        
        guard let accessToken = await manager.keyChain.read(account: "accessToken") else {
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
            _ = try await manager.withTokenRetry {
                let response = await task.serializingData().response
                let statusCode = response.response?.statusCode ?? -1
                
                guard (200..<300).contains(statusCode) else {
                    debugPrint("statusCode : \(statusCode)")
                    switch statusCode {
                    case 500..<600:
                        throw ScheduleRepositoryError.serverError
                    default:
                        throw ScheduleRepositoryError.unknown(NSError(domain: "DeleteSchedule", code: statusCode, userInfo: nil))
                    }
                }
                return true
            }
        } catch {
            throw ScheduleRepositoryError.from(error, defaultFailedCase: .deleteFailed)
        }
    }
    
    /// 특정 일정에 대한 상세 내용을 단건 조회합니다.
    func fetch(scheduleId: String) async throws(ScheduleRepositoryError) -> ScheduleResponse {
        let url = DomainManager.Path.scheduleDetail(scheduleId: scheduleId).url
        guard let url = url else {
            throw .unknown(NSError(domain: "DefaultScheduleRepository", code: -1, userInfo: [NSLocalizedDescriptionKey: "Invalid URL"]))
        }
        
        guard let accessToken = await manager.keyChain.read(account: "accessToken") else {
            throw .notToken
        }
        
        let headers: HTTPHeaders = [
            "Authorization": "Bearer \(accessToken)"
        ]
        
        let task = AF.request(
            url,
            method: .get,
            headers: headers
        )
        
        do {
            let result = try await manager.withTokenRetry {
                do {
                    let response = try await task.serializingDecodable(ScheduleResponse.self).value
                    return response
                } catch {
                    throw ScheduleRepositoryError.unknown(error)
                }
            }
            return result
        } catch {
            throw ScheduleRepositoryError.from(error, defaultFailedCase: .unknown(error))
        }
    }
    
    /// 일간 기록 생성 제한 횟수를 조회합니다.
    func fetchRecordLimit() async throws(ScheduleRepositoryError) -> DailyRecordLimit {
        let url = DomainManager.Path.dailyRecordLimit.url
        guard let url = url else {
            throw .invaildURL(DomainManager.Path.dailyRecordLimit.urlString)
        }
        
        guard let accessToken = await manager.keyChain.read(account: "accessToken") else {
            throw .notToken
        }
        
        let headers: HTTPHeaders = [
            "Authorization": "Bearer \(accessToken)"
        ]
        
        let task = AF.request(
            url,
            method: .get,
            headers: headers
        )
        
        do {
            let result = try await manager.withTokenRetry {
                let response = try await task.serializingDecodable(DailyRecordLimit.self).value
                return response
            }
            return result
        } catch {
            throw ScheduleRepositoryError.from(error, defaultFailedCase: .unknown(error))
        }
    }
}

// MARK: - ScheduleRepositoryError Helper Mapping
private extension ScheduleRepositoryError {
    static func from(_ error: Error, defaultFailedCase: ScheduleRepositoryError) -> ScheduleRepositoryError {
        if let repoError = error as? ScheduleRepositoryError {
            return repoError
        }
        if let loginError = error as? LoginError {
            switch loginError {
            case .notToken:
                return .notToken
            default:
                return .unknown(loginError)
            }
        }
        return defaultFailedCase
    }
}
