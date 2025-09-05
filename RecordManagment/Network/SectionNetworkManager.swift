//
//  SectionNetworkManager.swift
//  RecordManagment
//
//  Created by 김용해 on 9/4/25.
//

import Foundation
import Alamofire

class SectionNetworkManager {
    let keyChain: KeyChainManager = KeyChainManager.shared
    var domain: String?
    
    init() {
        if let serverURL = Bundle.main.infoDictionary?["SERVER_DEV_URL"] as? String {
            domain = serverURL
        }
    }
    
    // TODO: 서버에 보내는 온보딩 완료 API 함수
    func onBoardingComplete(onBoardingDTO: OnBoardingDTO) async -> Result<OnBoardingResponseDTO, LoginError> {
        let urlString = "\(domain ?? "domein")/api/users/onboarding/complete"
        guard let url = URL(string: urlString) else {
            return .failure(.networkError(.invalidURL(url: urlString)))
        }
        
        guard let accessToken = keyChain.read(account: "accessToken") else {
            return .failure(.notToken)
        }
        
        let headers: HTTPHeaders = [
            "Authorization": "Bearer \(accessToken)",
            "Content-Type" : "application/json"
        ]
        
        let parameters: Parameters = [
            "nickname": onBoardingDTO.nickName,
            "mainRecordType": onBoardingDTO.mainRecordType,
            "birthDate": onBoardingDTO.birthDate,
            "goalDays": onBoardingDTO.goalDays,
            "notificationEnabled": onBoardingDTO.notificationEnabled
        ]
        
        do {
            let decodedDTO = try await AF.request(
                url,
                method: .post,
                parameters: parameters,
                encoding: JSONEncoding.default,
                headers: headers
            )
            .serializingDecodable(OnBoardingResponseDTO.self)
            .value
            
            return .success(decodedDTO)
        } catch let err as AFError {
            return .failure(.networkError((err)))
        } catch {
            return .failure(.unknown(error))
        }
    }
}
