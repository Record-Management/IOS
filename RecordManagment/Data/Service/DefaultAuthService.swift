import Foundation
import Alamofire
import StoreKit

struct DefaultAuthService: AuthService {
    static let shared = DefaultAuthService(keyChain: .shared)
    var domain: String = DomainManager.baseURL
    private let keyChain: KeyChainManager
    
    init(keyChain: KeyChainManager) {
        self.keyChain = keyChain
    }
    
    // MARK: Social Login 서버 통신 함수
    func login(socialType type: SocialType, accessToken token: String) async throws(LoginError) -> SocialLoginResponseDTO {
        let urlString = DomainManager.Path.socialLogin.urlString
        guard let url = URL(string: urlString) else {
            Log.network(LoginError.invaildURL(urlString).localizedDescription, isError: true)
            throw .invaildURL(urlString)
        }
        
        let headers: HTTPHeaders = [
            "Content-Type" : "application/json"
        ]
        
        let parameters: Parameters = [
            "socialType" : type.rawValue,
            "accessToken" : token
        ]
        
        let task = AF.request(
            url,
            method: .post,
            parameters: parameters,
            encoding: JSONEncoding.default,
            headers: headers,
        )
        .validate(statusCode: 200..<300)
        
        do {
            let response = try await task.serializingDecodable(SocialLoginResponseDTO.self).value
            guard let data = response.data else { throw LoginError.invaildRequest }
            
            await keyChain.create(account: "accessToken", data: data.accessToken)
            await keyChain.create(account: "refreshToken", data: data.refreshToken)
            // 각 소셜 로그인의 타입에 따른 로깅 삽입
            if let isNewUser = data.newUser {
                if isNewUser {
                    AnalyticsManager.shared.logSignUp(method: type.rawValue, userId: data.user?.id)
                } else {
                    AnalyticsManager.shared.logLogin(method: type.rawValue, userId: data.user?.id)
                }
            }
            return response
        } catch {
            Log.error(error.localizedDescription)
            throw .loginFailed
        }
    }

    // MARK: RefreshToken으로 AccessToken 재발급 서버 통신 함수
    func authorizationToken() async throws(LoginError) -> SocialLoginResponseDTO {
        let urlString = DomainManager.Path.refresh.urlString
        guard let url = URL(string: urlString) else {
            Log.network(LoginError.invaildURL(urlString).localizedDescription, isError: true)
            throw .invaildURL(urlString)
        }
        
        // refreshToken을 가지고 있는지 확인
        guard let refreshToken = await keyChain.read(account: "refreshToken") else {
            Log.network(LoginError.notToken.localizedDescription, isError: true)
            throw .notToken
        }
        
        let headers: HTTPHeaders = [
            "Content-Type" : "application/json"
        ]
        
        let parameters: Parameters = [
            "refreshToken" : refreshToken
        ]
        
        let task = AF.request(
            url,
            method: .post,
            parameters: parameters,
            encoding: JSONEncoding.default,
            headers: headers,
        )
        .validate(statusCode: 200..<300)
        
        do {
            let response = try await task.serializingDecodable(SocialLoginResponseDTO.self).value
            if response.code == "E40107" { // refreshToken 만료
                throw LoginError.refreshTokenExpired
            }
            
            if let data = response.data {
                await keyChain.update(account: "accessToken", data: data.accessToken)
                await keyChain.update(account: "refreshToken", data: data.refreshToken)
                Log.info("accessToken이 업데이트가 됨")
                return response
            }
            
            Log.info("StatusCode : \(response.statusCode ?? -1)")
            throw LoginError.serverError
        } catch {
            Log.error(error.localizedDescription)
            throw .retryTokenPublished
        }
    }
    
    @discardableResult
    func logout() async throws(LoginError) -> Bool {
        // 서버 /api/auth/logout 통신
        let urlString = DomainManager.Path.logout.urlString
        guard let url = URL(string: urlString) else {
            throw .invaildURL(urlString)
        }
        
        guard let accessToken = await keyChain.read(account: "accessToken") else {
            Log.error("accessToken 읽기 실패")
            return false
        }
        guard let refreshToken = await keyChain.read(account: "refreshToken") else {
            Log.error("refreshToken 읽기 실패")
            return false
        }
        
        let headers: HTTPHeaders = [
            "Authorization": "Bearer \(accessToken)"
        ]
        
        let parameters: Parameters = [
            "refreshToken" : refreshToken,
            "allDevices" : false
        ]
        
        let task = AF.request(
            url,
            method: .post,
            parameters: parameters,
            encoding: JSONEncoding.default,
            headers: headers
        )
        
        do {
            let response = try await task.serializingDecodable(LogoutDTO.self).value
            switch response.statusCode {
            case 200:
                // KeyChain All Remove
                await keyChain.delete(account: "accessToken")
                await keyChain.delete(account: "refreshToken")
                // Logging for Logout
                AnalyticsManager.shared.logLogout()
                return true
            default:
                return false
            }
        } catch {
            Log.error(error.localizedDescription)
            return false
        }
    }
    
    /// ** 회원 탈퇴 함수
    @discardableResult
    func WithdrawMembership(reason: String? = nil) async throws(LoginError) -> Bool {
        let urlString = DomainManager.Path.withdrawal.urlString
        
        guard let url = URL(string: urlString) else { throw .invaildURL(urlString) }
        guard let accessToken = await keyChain.read(account: "accessToken") else {
            Log.error("accessToken 읽기 실패")
            return false
        }
        
        let headers: HTTPHeaders = [
            "Authorization": "Bearer \(accessToken)"
        ]

        let parameters: Parameters? = reason != nil ? ["reason": reason!] : [:]

        let task = AF.request(
                url,
                method: .delete,
                parameters: parameters,
                encoding: JSONEncoding.default,
                headers: headers
            )
        
        let value = await task.serializingData().response
        if let statusCode = value.response?.statusCode {
            switch statusCode {
            case 200..<300:
                // 탈퇴 성공
                Log.info("회원 탈퇴 성공")
                await keyChain.delete(account: "accessToken")
                await keyChain.delete(account: "refreshToken")
                // Logging for Withdraw
                AnalyticsManager.shared.logWithdraw()
                return true
            case 400:
                Log.error("회원 탈퇴 실패: 이미 탈퇴한 사용자")
                // accessToken 만료라면
                let _ = try await authorizationToken()
                // 재귀
                let _ = try await WithdrawMembership(reason: reason)
            case 401:
                Log.error("회원 탈퇴 실패: 인증 실패 (notToken)")
            case 404:
                Log.error("회원 탈퇴 실패: 사용자를 찾을 수 없음")
            default:
                Log.error("회원 탈퇴 실패: unknown Error")
            }
        }
        return false
    }
}
