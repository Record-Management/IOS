import Foundation
import Alamofire

struct SectionNetworkManager {
    private let intergrationManager: IntergrationManager
    
    init(intergrationManager: IntergrationManager = .shared) {
        self.intergrationManager = intergrationManager
    }
    
    // TODO: 서버에 보내는 온보딩 완료 API 함수
    func onBoardingComplete(onBoardingDTO: OnBoardingDTO) async -> Result<OnBoardingResponseDTO, LoginError> {
        let domain = intergrationManager.domain
        guard let url = URL(string: "\(domain)/api/users/onboarding/complete") else {
            return .failure(.networkError(.invalidURL(url: "/api/users/onboarding/complete")))
        }
        
        do {
            let result = try await intergrationManager.withTokenRetry {
                guard let accessToken = await intergrationManager.keyChain.read(account: "accessToken") else {
                    throw LoginError.notToken
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
                
                let decodedDTO = try await AF.request(
                    url,
                    method: .post,
                    parameters: parameters,
                    encoding: JSONEncoding.default,
                    headers: headers
                )
                .serializingDecodable(OnBoardingResponseDTO.self)
                .value
                
                // Logging for OnBoarding Complete!
                AnalyticsManager.shared.logOnBoardingComplete(info: onBoardingDTO)
                return decodedDTO
            }
            return .success(result)
        } catch {
            return .failure(error)
        }
    }
    
    // TODO: 온보딩 재설정 함수
    func goalReSelectionOnBoardingComplete(dto: GoalReSelectionRequestBody) async -> Result<GoalReSelectionDTO, LoginError> {
        let domain = intergrationManager.domain
        guard let url = URL(string: "\(domain)/api/goals/new") else {
            return .failure(.networkError(.invalidURL(url: "/api/goals/new")))
        }
        
        do {
            let result = try await intergrationManager.withTokenRetry {
                guard let accessToken = await intergrationManager.keyChain.read(account: "accessToken") else {
                    throw LoginError.notToken
                }
                
                let headers: HTTPHeaders = [
                    "Authorization": "Bearer \(accessToken)",
                ]
                
                return try await AF.request(
                    url,
                    method: .post,
                    parameters: dto,
                    encoder: JSONParameterEncoder.default,
                    headers: headers
                )
                .serializingDecodable(GoalReSelectionDTO.self)
                .value
            }
            return .success(result)
        } catch {
            return .failure(error)
        }
    }
}
