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
        print(accessToken)
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
