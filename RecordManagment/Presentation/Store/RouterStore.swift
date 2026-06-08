import Foundation

/// 앱 최상위 RouterView의  `Store` 입니다
@MainActor
@Observable
final class RouterStore {
    let authStore: AuthStore
    let recordStore: RecordStore
    let userStore: UserStore

    // 의존성
    private let authUseCase: AuthUseCase
    
    init(
        authStore: AuthStore,
        recordStore: RecordStore,
        userStore: UserStore,
        authUseCase: AuthUseCase
    ) {
        self.authStore = authStore
        self.recordStore = recordStore
        self.userStore = userStore
        self.authUseCase = authUseCase
    }
    
    enum Intent {
        case onAppearPreload
    }
    
    func send(_ intent: Intent) {
        switch intent {
        case .onAppearPreload:
            // 이미 초기 상태(.initialize)가 아니라면 (자동 로그인 검사가 끝난 세션이라면)
            // 중복해서 autoLogin API가 호출되는 것을 방지합니다.
            guard authStore.state == .initialize else { return }
            Task {
                let loginState = await authUseCase.autoLogin()
                await preloadData()
                authStore.send(.updateState(loginState))
            }
        }
    }
}

// MARK: - Private

extension RouterStore {
    private func preloadData() async {
        // 현재 날짜 기록들 가져오기
        recordStore.send(.fetchRecords(.now))
        // 유저 정보 가져오기
        userStore.send(.fetchUserRecordType)
    }
}
