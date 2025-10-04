import SwiftUI
import Alamofire

class IntergrationManager {
    static let shared: IntergrationManager = .init()
    let manager: LoginNetworkManager = .init()
    private init() {}
    
    // TODO: Token 재발급 재귀 조건 함수
    // 토큰이 만료될 경우 에러전달 및 성공시 재귀적으로 함수 호출
    func withTokenRetry<T>(retryCount: Int = 0, task: @escaping () async throws -> T) async -> Result<T, LoginError> {
        do {
            let result = try await task()
            return .success(result)
        } catch {
            if let afError = error as? AFError,
               afError.responseCode == 403, retryCount < 1 {
                let refresh = await manager.authorizationToken()
                switch refresh {
                case .success(_):
                    return await withTokenRetry(retryCount: retryCount + 1,task: task)
                case .failure(_):
                    return .failure(.refreshTokenExpired)
                }
            }
            
            if let afError = error as? AFError {
                return .failure(.networkError(afError))
            }
            
            return .failure(.unknown(error))
        }
    }
}
