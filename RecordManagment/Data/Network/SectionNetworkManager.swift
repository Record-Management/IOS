import Foundation
import Alamofire

class SectionNetworkManager {
    let common: IntergrationManager = .shared
    
    // TODO: 서버에 보내는 온보딩 완료 API 함수
    func onBoardingComplete(onBoardingDTO: OnBoardingDTO) async -> Result<OnBoardingResponseDTO, LoginError> {
        guard let domain = await common.manager.domain, let url = URL(string: "\(domain)/api/users/onboarding/complete") else {
            return .failure(.networkError(.invalidURL(url: "/api/users/onboarding/complete")))
        }
        
        guard let accessToken = await common.manager.keyChain.read(account: "accessToken") else {
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
    
    // TODO: 온보딩 재설정 함수
    func goalReSelectionOnBoardingComplete(dto: GoalReSelectionRequestBody) async -> Result<GoalReSelectionDTO, LoginError> {
        guard let domain = await common.manager.domain, let url = URL(string: "\(domain)/api/goals/new") else {
            return .failure(.networkError(.invalidURL(url: "/api/goals/new")))
        }
        
        guard let accessToken = await common.manager.keyChain.read(account: "accessToken") else {
            return .failure(.notToken)
        }
        
        let headers: HTTPHeaders = [
            "Authorization": "Bearer \(accessToken)",
        ]
        
        let task = AF.request(
            url,
            method: .post,
            parameters: dto,
            encoder: JSONParameterEncoder.default,
            headers: headers,
        )
        
        let result = await common.withTokenRetry {
            let response = try await task.serializingDecodable(GoalReSelectionDTO.self).value
            return response
        }
        
        return result
    }
}
