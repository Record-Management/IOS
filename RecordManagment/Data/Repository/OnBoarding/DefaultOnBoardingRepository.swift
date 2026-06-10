import Foundation
import Alamofire

/// 온보딩 과정의 비동기 네트워크 작업을 처리하는 레포지토리 구현체입니다.
struct DefaultOnBoardingRepository: OnBoardingRepository {
    private let manager: IntergrationManager
    private let keyChain: KeyChainManager = .shared
    
    init(manager: IntergrationManager) {
        self.manager = manager
    }
    
    /// 온보딩 정보를 등록하여 온보딩 완료 단계를 진행합니다.
    func onBoardingSection(dto: OnBoardingDTO) async throws(OnBoardingError) -> OnBoardingResponseDTO {
        let url = DomainManager.Path.onboardingComplete.url
        guard let url = url else {
            throw .networkError(.invaildURL(DomainManager.Path.onboardingComplete.urlString))
        }
        
        guard let accessToken = await keyChain.read(account: "accessToken") else {
            throw .networkError(.notToken)
        }

        let headers: HTTPHeaders = [
            "Authorization": "Bearer \(accessToken)",
            "Content-Type" : "application/json"
        ]
        
        let parameters: Parameters = [
            "nickname": dto.nickName,
            "mainRecordType": dto.mainRecordType,
            "birthDate": dto.birthDate,
            "goalDays": dto.goalDays,
        ]
        
        let task = AF.request(
            url,
            method: .post,
            parameters: parameters,
            encoding: JSONEncoding.default,
            headers: headers
        )
        
        do {
            let result = try await manager.withTokenRetry {
                let response = try await task.serializingDecodable(OnBoardingResponseDTO.self).value
                AnalyticsManager.shared.logOnBoardingComplete(info: dto)
                
                return response
            }
            return result
        } catch {
            Log.error(error.localizedDescription)
            throw .unknown(error)
        }
    }
}
