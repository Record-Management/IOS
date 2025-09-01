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
            keyChain.create(account: "accessToken", data: response.data.accessToken)
            keyChain.create(account: "refreshToken", data: response.data.refreshToken)
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
    
    
    // MARK: 자동 로그인 기능
    func autoLogin() async -> UserState {
        let urlString = "\(domain ?? "domain")/api/auth/refresh"
        // refreshToken을 가지고 있는지 확인
        guard let refreshToken = keyChain.read(account: "refreshToken"),
              let url = URL(string: urlString) else {
            return .login
        }
        
        // login 실행
        let result = await login(url: url, refreshToken: refreshToken)
        switch result {
            case .success(let res):
                switch res.statusCode {
                    case 200: // 기존 사용자
                        return .main
                    case 201: // 신규 사용자
                        return .register
                    default:  // 이상한 경로
                        return .login
                }
            case .failure(let err):
                //  로그인으로 보내고 alert 띄워주는거 낫베드
                return .login
        }
    }
    
    // MARK: Social Login 서버 통신 함수
    func login(url: URL, refreshToken: String) async -> Result<SocialLoginResponseDTO, LoginError> {
        
        guard domain != nil else { return .failure(.networkError(.invalidURL(url: "domain 에러입니다")))}
        
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
                    if errorResponse.code == "E40103" {
                        return .failure(.accessTokenExpired)
                    }else if errorResponse.code == "E40107" {
                        return .failure(.refreshTokenExpired)
                    }
                }
            }
            
            let decoded = try JSONDecoder().decode(SocialLoginResponseDTO.self, from: dataResponse.data!)
            keyChain.update(account: "accessToken", data: decoded.data.accessToken)
            return .success(decoded)
        } catch let error as AFError {
            return .failure(.networkError(error))
        } catch {
            return .failure(.unknown(error))
        }
    }
    
    func logout() async {
        // 서버 /api/auth/logout 통신
        
        // KeyChain All Remove
        keyChain.delete(account: "accessToken")
        keyChain.delete(account: "refreshToken")
    }
}
