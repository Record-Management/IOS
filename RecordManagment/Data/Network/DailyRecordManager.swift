//
//  DailyRecordManager.swift
//  RecordManagment
//
//  Created by 김용해 on 9/17/25.
//

import Foundation
import Alamofire

struct DailyRecordManager {
    private let keyChain: KeyChainManager
    private let intergrationManager: IntergrationManager
    private var domain: String?
    
    init(keyChain: KeyChainManager = .shared, intergrationManager: IntergrationManager = .shared) {
        self.keyChain = keyChain
        self.intergrationManager = intergrationManager
    }
    
    // TODO: Daily Record 작성 POST API
    func dailyRecordCreate(form: DailyFormat, retryCount: Int = 0) async -> Result<DailyDTO, LoginError> {
        guard
            let domain = await intergrationManager.manager.domain,
            let url = URL(string: "\(domain)/api/daily-records")
        else {
            return .failure(.networkError(.invalidURL(url: "/api/daily-records")))
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
            
            guard (200..<300).contains(statusCode) else {
                debugPrint("statusCode : \(statusCode)")
                switch statusCode {
                case 400:
                    // 하루 기록 제한
                    if let data = response.data {
                        let decoded = try JSONDecoder().decode(DailyDTO.self, from: data)
                        if decoded.code == "E40407" || decoded.code == "E40410" {
                            return decoded
                        }
                    }
                    throw URLError(.notConnectedToInternet)
                case 500..<600:
                    throw LoginError.serverError
                default:
                    throw LoginError.unknown(NSError(domain: "CreateDaily", code: statusCode, userInfo: nil))
                }
            }
            
            if let data = response.data {
                let decoded = try JSONDecoder().decode(DailyDTO.self, from: data)
                return decoded
            }
            
            throw LoginError.unknown(NSError(domain: "CreateDaily", code: statusCode, userInfo: nil))
        }
        
        switch result {
            case .success(let data):
                return .success(data)
            case .failure(let error):
                return .failure(error)
        }
    }
    
    // TODO: Daily Record 수정 PUT API
    func dailyRecordRead(form: DailyFormat,recordId: String ,retryCount: Int = 0) async -> Result<DailyDTO, LoginError> {
        guard
            let domain = await intergrationManager.manager.domain,
            let url = URL(string: "\(domain)/api/daily-records/\(recordId)")
        else {
            return .failure(.networkError(.invalidURL(url: "/api/daily-records")))
        }
        
        guard let accessToken = keyChain.read(account: "accessToken") else {
            return .failure(.notToken)
        }

        let headers: HTTPHeaders = [
            "Authorization": "Bearer \(accessToken)",
            "Content-Type": "application/json"
        ]
        
        let parameters: Parameters = [
            "emotion" : form.emotion,
            "content" : form.content,
            "imageUrls" : form.imageUrls,
        ]
        
        let task = AF.request(
            url,
            method: .put,
            parameters: parameters,
            encoding: JSONEncoding.default,
            headers: headers
        )
        
        let result = await intergrationManager.withTokenRetry {
            let response = try await task.serializingDecodable(DailyDTO.self).value
            return response
        }
        
        switch result {
            case .success(let data):
                return .success(data)
            case .failure(let error):
                return .failure(error)
        }
    }
    
    // TODO: Daily Record 삭제 DELETE API
    func dailyRecordRemove(recordId: String) async -> Result<DailyDTO, LoginError> {
        guard
            let domain = await intergrationManager.manager.domain,
            let url = URL(string: "\(domain)/api/daily-records/\(recordId)")
        else {
            return .failure(.networkError(.invalidURL(url: "/api/daily-records")))
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
            let response = try await task.serializingDecodable(DailyDTO.self).value
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
