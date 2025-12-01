import Foundation

class KaKaoLoginUseCase {
    private let kakaoRepository: KaKaoLoginRepository
    
    init(kakaoRepository: KaKaoLoginRepository) {
        self.kakaoRepository = kakaoRepository
    }
    
    func kakaoLogin() async -> UserState {
        let token = await kakaoRepository.requestKaKaoToken()
        guard let token else { return .login }
        let result = await kakaoRepository.login(token: token)
        
        switch result {
            case .success(let response):
                debugPrint("kakao login result : \(response)")
                switch response.statusCode {
                    case 200:
                        debugPrint("기존 사용자입니다")
                        if let data = response.data {
                            if let user = data.newUser,
                               let completed = data.user?.onboardingCompleted,
                               user || !completed {
                                debugPrint("기존 사용자인척 하는 신규 사용자입니다.")
                                return .register
                            }
                        }
                    return .main
                    case 201:
                        debugPrint("신규 사용자립니다")
                        return .register
                    default:
                        return .login
                }
            case .failure(let err):
                debugPrint("kakoLogin Error : \(err)")
                return .login
            case .none:
                return .login
        }
    }
    
    func kakaoLogout() async {
        await kakaoRepository.logout()
    }
}
