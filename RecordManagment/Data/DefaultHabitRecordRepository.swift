import Foundation
import Alamofire

class DefaultHabitRecordRepository: HabitRecordRepository {
    let common: IntergrationManager = .shared
    
    // TODO: Habit Record 작성 POST API
    func createHabitRecord(form: HabitRequestBody) async -> Result<HabitDTO, LoginError> {
        guard let domain = await common.manager.domain, let url = URL(string: "\(domain)/api/habit-records") else {
            return .failure(.networkError(.invalidURL(url: "/api/habit-records")))
        }
        
        guard let accessToken = await common.manager.keyChain.read(account: "accessToken") else {
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
        
        let result = await common.withTokenRetry {
            let response = await task.serializingData().response
            let statusCode = response.response?.statusCode ?? -1
            
            guard (200..<300).contains(statusCode) else {
                print("statusCode : \(statusCode)")
                switch statusCode {
                case 400:
                    // 하루 기록 제한
                    if let data = response.data {
                        let decoded = try JSONDecoder().decode(HabitDTO.self, from: data)
                        if decoded.code == "E40409" || decoded.code == "E40410" {
                            return decoded
                        }
                    }
                    throw URLError(.notConnectedToInternet)
                case 500..<600:
                    throw LoginError.serverError
                default:
                    throw LoginError.unknown(NSError(domain: "CreateHabit", code: statusCode, userInfo: nil))
                }
            }
            
            if let data = response.data {
                let decoded = try JSONDecoder().decode(HabitDTO.self, from: data)
                return decoded
            }
            
            throw LoginError.unknown(NSError(domain: "CreateHabit", code: statusCode, userInfo: nil))
        }
        
        switch result {
            case .success(let data):
                return .success(data)
            case .failure(let error):
                return .failure(error)
        }
    }
    
    // TODO: Habit Record 수정 PUT API
    func updateHabitRecord(form: HabitRequestBody, recordId: String) async -> Result<HabitDTO, LoginError> {
        guard let domain = await common.manager.domain, let url = URL(string: "\(domain)/api/habit-records/\(recordId)") else {
            return .failure(.networkError(.invalidURL(url: "/api/habit-records/\(recordId)")))
        }
        
        guard let accessToken = await common.manager.keyChain.read(account: "accessToken") else {
            return .failure(.notToken)
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
        
        let result = await common.withTokenRetry {
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
    
    // TODO: Habit Record 삭제 DELETE API
    func deleteHabitRecord(recordId: String) async -> Result<HabitDTO, LoginError> {
        guard let domain = await common.manager.domain, let url = URL(string: "\(domain)/api/habit-records/\(recordId)") else {
            return .failure(.networkError(.invalidURL(url: "/api/habit-records/\(recordId)")))
        }
        
        guard let accessToken = await common.manager.keyChain.read(account: "accessToken") else {
            return .failure(.notToken)
        }

        let headers: HTTPHeaders = [
            "Authorization": "Bearer \(accessToken)"
        ]
        
        let task = AF.request(
            url,
            method: .delete,
            headers: headers
        )
        
        let result = await common.withTokenRetry {
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
