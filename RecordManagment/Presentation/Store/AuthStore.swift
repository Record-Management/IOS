import Foundation
import Observation
import SwiftUI

/// 소셜 인증  `Store`
@MainActor
@Observable
final class AuthStore {
    // 뷰가 관찰할 상태(State)
    private(set) var state: AuthState = .initialize
    
    // 의존성
    private let authUseCase: AuthUseCase

    init(authUseCase: AuthUseCase) {
        self.authUseCase = authUseCase
    }
    
    enum Intent {
        case kakaoButtonTapped          // 카카오 로그인 버튼 동작
        case appleButtonTapped          // 애플 로그인 버튼 동작
        case logout
        case withdraw
        case updateState(AuthState)
    }
    
    func send(_ intent: Intent) {
        switch intent {
        case .kakaoButtonTapped:
            Task { await login(socialType: .kakao) }
        case .appleButtonTapped:
            Task { await login(socialType: .apple) }
        case .logout:
            Task {
                self.state = await authUseCase.logout()
            }
        case .withdraw:
            Task {
                self.state = await authUseCase.withdraw()
            }
        case .updateState(let newState):
            self.state = newState
        }
    }
}

// MARK: - Private Actions

extension AuthStore {
    private func login(socialType: SocialType) async {
        self.state = await authUseCase.login(socialType: socialType)
    }
}
