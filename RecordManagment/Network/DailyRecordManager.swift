//
//  DailyRecordManager.swift
//  RecordManagment
//
//  Created by 김용해 on 9/17/25.
//

import Foundation
import Alamofire

class DailyRecordManager {
    let keyChain: KeyChainManager = .shared
    let manager: IntergrationManager = .shared
    var domain: String?
    
    init() {
        if let serverURL = Bundle.main.infoDictionary?["SERVER_DEV_URL"] as? String {
            domain = serverURL
        }
    }
    
    // TODO: File Upload 통신 함수
    func fileUpload(files: [Data?], retryCount: Int = 0) async -> Result<[String], LoginError> {
        guard let domain = domain ,let url = URL(string: "\(domain)/api/files/upload") else {
            return .failure(.networkError(.invalidURL(url: "\(domain ?? "domain")/api/files/upload")))
        }
        
        guard let accessToken = keyChain.read(account: "accessToken") else {
            return .failure(.notToken)
        }
        
        let headers: HTTPHeaders = [
            "Authorization": "Bearer \(accessToken)"
        ]
        
        let request = AF.upload(multipartFormData: { formData in
            files.enumerated().forEach { (index, fileData) in
                if let data = fileData {
                    formData.append(
                        data,
                        withName: "files",
                        fileName: "\(Int(Date().timeIntervalSince1970))_\(index).jpeg",
                    )
                }
            }
        },to: url, method: .post ,headers: headers)
        
        let result = await manager.withTokenRetry {
            let response = try await request.serializingDecodable(FileResponse.self).value
            debugPrint(response)
            return response
        }
        
        switch result {
            case .success(let data):
                if let access = data.data {
                    return .success(access.fileUrls)
                }
            case .failure(let error):
                return .failure(error)
        }
        
        return .failure(.invaildRequest)
    }
    
    // TODO: Daily Record 작성 POST API
    func dailyRecordCreate(form: DailyFormat, retryCount: Int = 0) async -> Result<DailyDTO, LoginError> {
        guard let domain = domain, let url = URL(string: "\(domain)/api/daily-records") else {
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
        
        let result = await manager.withTokenRetry {
            let response = await task.serializingData().response
            
            guard let status = response.response?.statusCode else {
                throw LoginError.networkError(.invalidURL(url: "statusCode Error: \(response.response?.statusCode, default: "0")"))
            }
            
            if let data = response.data {
                let decoded = try JSONDecoder().decode(DailyDTO.self, from: data)
                print("하루기록 Decoded 결과 : \(decoded)")
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
    
    // TODO: Daily Record 수정 PUT API
    func dailyRecordRead(form: DailyFormat,recordId: String ,retryCount: Int = 0) async -> Result<DailyDTO, LoginError> {
        guard let domain = domain, let url = URL(string: "\(domain)/api/daily-records/\(recordId)") else {
            return .failure(.networkError(.invalidURL(url: "/api/daily-records")))
        }
        
        guard let accessToken = keyChain.read(account: "accessToken") else {
            return .failure(.notToken)
        }

        let headers: HTTPHeaders = [
            "Authorization": "Bearer \(accessToken)",
            "Content-Type": "application/json"
        ]
        
        /// ** DailyRecord Form Data 형식
        struct DailyFormat: Encodable {
            let emotion: String
            let content: String
            var imageUrls: [String]
            let recordDate: String
            let recordTime: String
        }
        
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
        
        let result = await manager.withTokenRetry {
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
