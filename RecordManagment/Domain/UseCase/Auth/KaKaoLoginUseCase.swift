import Foundation

protocol KaKaoLoginUseCase {
    func login() async -> UserState
    func logout() async
}

struct DefaultKaKaoLoginUseCase: KaKaoLoginUseCase {
    private let repository: KaKaoLoginRepository
    
    init(repository: KaKaoLoginRepository) {
        self.repository = repository
    }
    
    func login() async -> UserState {
        let token = await repository.requestKaKaoToken()
        guard let token,
              let result = await repository.login(token: token)
        else {
            return .login
        }
        
        switch result {
            case .success(let response):
                debugPrint("kakao login result : \(response)")
                guard let statusCode = response.statusCode else {
                    debugPrint("statusCode 가 존재하지 않습니다.")
                    return .login
                }
                switch statusCode {
                    case 200:
                        debugPrint("기존 사용자입니다")
                        guard let data = response.data else {
                            return .login
                        }
                    
                        // 신규 사용자 또는 온보딩 미완료 체크
                        let isNewUser = data.newUser ?? false
                        let isOnboardingNeeded = !(data.user?.onboardingCompleted ?? true)
                    
                        if isNewUser || isOnboardingNeeded {
                            debugPrint("기존 사용자인척 하는 신규 사용자입니다.")
                            return .register
                        } else {
                            return .main
                        }
                    case 201:
                        debugPrint("신규 사용자입니다")
                        return .register
                    case 400..<500:
                        debugPrint("클라이언트 에러 : \(response.message)")
                        return .login
                    default:
                        return .login
                }
            case .failure(let err):
                debugPrint("kakoLogin Error : \(err)")
                return .login
        }
    }
    
    func logout() async {
        await repository.logout()
    }
}
