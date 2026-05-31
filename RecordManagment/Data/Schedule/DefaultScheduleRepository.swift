import Foundation
import Alamofire

struct DefaultScheduleRepository: ScheduleRepository {
    private let network: IntergrationManager
    
    init(network: IntergrationManager) {
        self.network = network
    }
    
    func create(form: ScheduleFormat) async throws(ScheduleRepositoryError) -> ScheduleResponse {
        guard let domain = await network.manager.domain else { throw .invaildURL }
        let url: String = "\(domain)/api/schedule-records"
        
        guard let accessToken = await network.manager.keyChain.read(account: "accessToken") else {
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
        
        let result = await network.withTokenRetry {
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
        
        switch result {
        case .success(let data):
            return data
        case .failure(let failure):
            debugPrint(failure)
            if let repoError = failure as? ScheduleRepositoryError {
                throw repoError
            }
            throw .createFailed
        }
    }
    
    func update(scheduleId: String, form: ScheduleFormat) async throws(ScheduleRepositoryError) -> ScheduleResponse {
        guard let domain = await network.manager.domain else { throw .invaildURL }
        let url: String = "\(domain)/api/schedule-records/\(scheduleId)"
        
        guard let accessToken = await network.manager.keyChain.read(account: "accessToken") else {
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
        
        let result = await network.withTokenRetry {
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
        
        switch result {
        case .success(let data):
            return data
        case .failure(let failure):
            debugPrint(failure)
            if let repoError = failure as? ScheduleRepositoryError {
                throw repoError
            }
            throw .updateFailed
        }
    }
    
    func delete(scheduleId: String) async throws(ScheduleRepositoryError) {
        guard let domain = await network.manager.domain else { throw .invaildURL }
        let url: String = "\(domain)/api/schedule-records/\(scheduleId)"
        
        guard let accessToken = await network.manager.keyChain.read(account: "accessToken") else {
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
        
        let result = await network.withTokenRetry {
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
        
        switch result {
        case .success(let success):
            debugPrint(success)
        case .failure(let failure):
            debugPrint(failure)
            throw .deleteFailed
        }
    }
    
    func fetch(scheduleId: String) async throws(ScheduleRepositoryError) -> ScheduleResponse {
        guard let domain = await network.manager.domain else { throw .invaildURL }
        let url: String = "\(domain)/api/schedule-records/\(scheduleId)"
        
        guard let accessToken = await network.manager.keyChain.read(account: "accessToken") else {
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
        
        let result = await network.withTokenRetry {
            do {
                let response = try await task.serializingDecodable(ScheduleResponse.self).value
                return response
            } catch {
                throw ScheduleRepositoryError.unknown(error)
            }
        }
        
        switch result {
        case .success(let data):
            return data
        case .failure(let error):
            if let repoError = error as? ScheduleRepositoryError {
                throw repoError
            }
            throw ScheduleRepositoryError.unknown(error)
        }
    }
    
    func fetchRecordLimit() async throws(ScheduleRepositoryError) -> DailyRecordLimit {
        guard let domain = await network.manager.domain else { throw .invaildURL }
        let url: String = "\(domain)/api/daily-records/creation-limits"
        guard let accessToken = await network.manager.keyChain.read(account: "accessToken") else {
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
        
        let result = await network.withTokenRetry {
            let response = try await task.serializingDecodable(DailyRecordLimit.self).value
            return response
        }

        switch result {
        case .success(let data):
            return data
        case .failure(let error):
            if let repoError = error as? ScheduleRepositoryError {
                throw repoError
            }
            throw ScheduleRepositoryError.unknown(error)
        }
    }
}
