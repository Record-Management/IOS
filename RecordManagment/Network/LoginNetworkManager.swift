import Foundation
import Alamofire

actor LoginNetworkManager {
    let keyChain: KeyChainManager = KeyChainManager.shared
    var domain: String?
    
    init() {
        if let serverURL = Bundle.main.infoDictionary?["SERVER_DEV_URL"] as? String {
            domain = serverURL
        }
        
        debugPrint("domain : \(String(describing: domain))")
    }
    
    // MARK: Social Login 서버 통신 함수
    func login(socialType type: SocialType, accessToken token: String) async throws -> Result<SocialLoginResponseDTO, LoginError> {
        
        guard domain != nil else { return .failure(.networkError(.invalidURL(url: "domain 에러입니다")))}
        
        let urlString = "\(domain ?? "domein")/api/auth/social-login"
        guard let url = URL(string: urlString) else {
            return .failure(.networkError(.invalidURL(url: urlString)))
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
            if let data = response.data {
                keyChain.create(account: "accessToken", data: data.accessToken)
                keyChain.create(account: "refreshToken", data: data.refreshToken!)
            }
            return .success(response)
        } catch let error as AFError {
            if let statusCode = error.responseCode {
                switch statusCode {
                    // statusCode 별 Error
                    
                default:
                    return .failure(.networkError(error))
                }
            }
            return .failure(.networkError(error))
        } catch {
            debugPrint("일반적인 Login Error : \(error)")
            return .failure(.unknown(error))
        }
    }
    
    
    // MARK: 자동 로그인 기능 ( AccessToken 갱신 )
    func autoLogin(completion: () -> Void) async -> UserState {
        // login 실행
        let result = await authorizationToken()
        switch result {
            case .success(let res):
                print("자동 로그인 성공 : \(res.statusCode)")
                switch res.statusCode {
                case 200: // 기존 사용자
                    if let user = res.data?.user {
                        if user.onboardingCompleted {
                            print("자동 로그인 : 온보딩을 완료한 자!")
                            return .main
                        }else {
                            print("자동 로그인 : 온보딩 해야지!")
                            return .register
                        }
                    }
                default:  // 이상한 경로
                    return .login
                }
            case .failure(let err):
                switch err {
                    case .refreshTokenExpired:
                        print("refresh 만료되었으므로 로그인으로 이동!!!")
                        completion() // message alert 주는 Closer
                    default:
                        print("자동 로그인 err : \(err)")
                }
        }
        return .login
    }
    
    // MARK: RefreshToken으로 AccessToken 재발급 서버 통신 함수
    func authorizationToken() async -> Result<SocialLoginResponseDTO, LoginError> {
        let urlString = "\(domain ?? "domain")/api/auth/refresh"
        guard domain != nil else { return .failure(.networkError(.invalidURL(url: "domain 에러입니다")))}
        
        // refreshToken을 가지고 있는지 확인
        guard let refreshToken = keyChain.read(account: "refreshToken"),
              let url = URL(string: urlString) else {
            return .failure(.notToken)
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
            let dataResponse = await task.serializingData().response
            
            if let statusCode = dataResponse.response?.statusCode,
               !(200..<300).contains(statusCode){
                if let data = dataResponse.data {
                    let errorResponse = try JSONDecoder().decode(SocialLoginResponseDTO.self, from: data)
                    if errorResponse.code == "E40107" { // refreshToken 만료
                        return .failure(.refreshTokenExpired)
                    }
                }
            }

            if let data = dataResponse.data {
                let decodedData = try JSONDecoder().decode(SocialLoginResponseDTO.self, from: data)
                
                if let data = decodedData.data {
                    print("accessToken이 업데이트가 됨")
                    keyChain.update(account: "accessToken", data: data.accessToken)
                    
                    print("자동 로그인 값 : \(decodedData)")
                    return .success(decodedData)
                }
            }
            debugPrint("StatusCode : \(dataResponse.response?.statusCode), description: \(dataResponse.response?.description)")
            return .failure(.serverError)
        } catch let error as AFError {
            return .failure(.networkError(error))
        } catch {
            return .failure(.unknown(error))
        }
    }
    
    @discardableResult
    func logout() async -> Bool {
        // 서버 /api/auth/logout 통신
        let urlString = "\(domain ?? "domain")/api/auth/logout"
        guard let url = URL(string: urlString) else { return false }
        
        guard let refreshToken = keyChain.read(account: "refreshToken") else { return false }
        
        let parameters: Parameters = [
            "refreshToken" : refreshToken,
            "allDevices" : false
        ]
        
        let task = AF.request(
            url,
            method: .post,
            parameters: parameters,
            encoding: JSONEncoding.default,
        )
        
        do {
            let responseData = await task.serializingData().response
            if let data = responseData.data {
                let decodeData = try JSONDecoder().decode(LogoutDTO.self, from: data)
                switch decodeData.statusCode {
                case 200:
                    // KeyChain All Remove
                    keyChain.delete(account: "accessToken")
                    keyChain.delete(account: "refreshToken")
                    return true
                default:
                    return false
                }
            }
        } catch {
            print("Logout Error : \(error)")
        }
        return false
    }
    
    /// ** 회원 탈퇴 함수
    @discardableResult
    func WithdrawMembership(reason: String? = nil) async -> Bool {
        let urlString = "\(domain ?? "domain")/api/users/withdrawal"
        
        guard let url = URL(string: urlString) else { return false }
        guard let accessToken = keyChain.read(account: "accessToken") else { return false }
        
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
        
        let response = await task.serializingData().response
        if let statusCode = response.response?.statusCode {
            if (200..<300).contains(statusCode) {
                // ✅ 탈퇴 성공
                keyChain.delete(account: "accessToken")
                keyChain.delete(account: "refreshToken")
                return true
            } else if statusCode == 401 {
                // 👇 accessToken 만료라면
                let refreshResult = await authorizationToken()
                
                switch refreshResult {
                    case .success:
                        // 새 토큰으로 다시 한 번만 재시도
                        return await WithdrawMembership(reason: reason)
                    case .failure:
                        debugPrint("refreshToken 만료 의 경우")
                        return false
                }
            } else {
                debugPrint("회원 탈퇴 error statusCode : \(statusCode)")
                debugPrint("detailPrint : \(response.description)")
            }
        }
        
        return false
    }
}
