import Foundation
import Observation
import SwiftUI

@MainActor
@Observable
final class AuthStore {
    // 뷰가 관찰할 상태(State)
    var userState: UserState = .initialize
    
    // 의존성
    private let kakaoUseCase: KaKaoAuthUseCase
    private let appleUseCase: AppleAuthUseCase
    private let appleSignInHelper = AppleSignInHelper()
    
    init(
        kakaoUseCase: KaKaoAuthUseCase,
        appleUseCase: AppleAuthUseCase
    ) {
        self.kakaoUseCase = kakaoUseCase
        self.appleUseCase = appleUseCase
    }
                                                                                                                                  
    // MARK: - Actions
                                                                                                                                  
    func loginWithKakao() async {
        self.userState = await kakaoUseCase.login()
    }
                                                                                                                                  
    func loginWithApple() async {
        // Apple ID 인증 요청 후 사용자 자격 증명 정보를 가져옵니다.
        guard let authUserData = await appleSignInHelper.requestAppleSignIn() else {
            // 사용자가 로그인을 취소했거나 에러가 발생한 경우 중단
            return
        }
        
        // UseCase를 통해 서버 로그인을 진행합니다.
        self.userState = await appleUseCase.login(authUserData: authUserData)
    }
}
