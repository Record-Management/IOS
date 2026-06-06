import SwiftUI
import Alamofire

struct IntergrationManager {
    static let shared = IntergrationManager(service: DefaultAuthService.shared, keyChain: .shared)
    let service: AuthService
    let keyChain: KeyChainManager
    init(
        service: AuthService,
        keyChain: KeyChainManager
    ) {
        self.service = service
        self.keyChain = keyChain
    }
    
    // MARK: - Token 재발급 재귀 조건 함수
    /// 토큰이 만료(HTTP 403)될 경우 토큰을 갱신하고, 원래 요청을 재귀적으로 다시 시도합니다.
    /// - Parameters:
    ///   - retryCount: 재시도 횟수 (최대 1회 제한)
    ///   - task: 실행할 비동기 네트워크 클로저
    /// - Returns: 네트워크 통신 결과 데이터
    /// - Throws: 토큰 갱신 실패 또는 기타 로그인 예외 상황에 따른 `LoginError`
    func withTokenRetry<T>(retryCount: Int = 0, task: @escaping () async throws -> T) async throws(LoginError) -> T {
        do {
            return try await task()
        } catch {
            // Alamofire 에러이면서 HTTP 403 Forbidden(토큰 만료)인 경우 재시도 처리
            if let afError = error as? AFError, afError.responseCode == 403, retryCount < 1 {
                do {
                    // 토큰 재발급 진행
                    _ = try await service.authorizationToken()
                    // 재발급 성공 시 재귀적으로 재시도 (재시도 횟수 + 1)
                    return try await withTokenRetry(retryCount: retryCount + 1, task: task)
                } catch {
                    Log.error("토큰 재발급 에러 : \(error.localizedDescription)")
                    throw .refreshTokenExpired // 토큰 재갱신 자체가 실패하면 리프레시 토큰 만료 처리
                }
            }
            
            // 발생한 에러를 LoginError 형태로 변환하여 던짐
            if let loginError = error as? LoginError {
                Log.error(loginError.localizedDescription)
                throw loginError
            } else if let afError = error as? AFError {
                Log.error(afError.localizedDescription)
                throw .networkError(afError)
            } else {
                Log.error(error.localizedDescription)
                throw .unknown(error)
            }
        }
    }
}
