import Foundation
import Alamofire

struct DefaultRouterRepository: RouterRepository {
    private let intergrationManager: IntergrationManager
    
    init(intergrationManager: IntergrationManager = .shared) {
        self.intergrationManager = intergrationManager
    }
    
    func refreshLogin(completion: () -> Void) async -> UserState {
        do {
            let res = try await intergrationManager.service.authorizationToken()
            debugPrint("자동 로그인 성공 : \(res.statusCode ?? -1)")
            switch res.statusCode {
            case 200: // 기존 사용자
                if let user = res.data?.user {
                    if user.onboardingCompleted {
                        debugPrint("자동 로그인 : 온보딩을 완료한 자!")
                        return .main
                    } else {
                        debugPrint("자동 로그인 : 온보딩 해야지!")
                        return .register
                    }
                }
                return .login
            default:  // 이상한 경로
                return .login
            }
        } catch {
            switch error {
            case .refreshTokenExpired:
                debugPrint("refresh 만료되었으므로 로그인으로 이동!!!")
                completion() // message alert 주는 Closer
            default:
                debugPrint("자동 로그인 err : \(error)")
            }
            return .login
        }
    }
    
    func logout() async -> Bool {
        do {
            return try await intergrationManager.service.logout()
        } catch {
            debugPrint("Logout Error : \(error)")
            return false
        }
    }
    
    func withdraw() async -> Bool {
        do {
            return try await intergrationManager.service.WithdrawMembership(reason: nil)
        } catch {
            debugPrint("Withdrawal Error : \(error)")
            return false
        }
    }
}

extension DefaultRouterRepository {
    func fetchReport(id: String) async -> Result<GoalAchieve, LoginError> {
        let domain = intergrationManager.domain
        guard let url = URL(string: "\(domain)/api/goals/achievement/report") else {
            return .failure(.networkError(.invalidURL(url: "/api/goals/achievement/report")))
        }

        do {
            let result = try await intergrationManager.withTokenRetry {
                guard let accessToken = await intergrationManager.keyChain.read(account: "accessToken") else {
                    throw LoginError.notToken
                }
                
                let headers: HTTPHeaders = [
                    "Authorization": "Bearer \(accessToken)",
                    "userId" : id
                ]
                
                return try await AF.request(
                    url,
                    method: .get,
                    headers: headers
                )
                .serializingDecodable(GoalAchieve.self)
                .value
            }
            return .success(result)
        } catch {
            return .failure(error)
        }
    }
}
