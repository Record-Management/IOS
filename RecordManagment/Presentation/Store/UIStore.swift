import SwiftUI

@Observable
final class UIStore {
    struct State {
        var offset: CGFloat = 0
        var topDetent: CGFloat = 0
        var navBarHeight: CGFloat = 0
        var isShow: Bool = false
        var isGoalReset: Bool = false
        var isAppReviewShow: Bool = false
        var isFloatingExtends: Bool = false
        var isAlert: Bool = false
    }
    
    private(set) var state = State()
    private let settingUseCase: SettingUseCase
    
    init(settingUseCase: SettingUseCase) {
        self.settingUseCase = settingUseCase
    }
    
    enum Intent {
        case updateOffset(CGFloat)
        case updateTopDetent(CGFloat)
        case updateNavBarHeight(CGFloat)
        case toggleShow(Bool)
        case toggleGoalReset(Bool)
        case toggleAppReview(Bool)
        case toggleFloatingExtends(Bool)
        case toggleAlert(Bool)
        case resetGoal
    }
    
    func send(_ intent: Intent) {
        switch intent {
        case .updateOffset(let offset):
            state.offset = offset
        case .updateTopDetent(let detent):
            state.topDetent = detent
        case .updateNavBarHeight(let height):
            state.navBarHeight = height
        case .toggleShow(let show):
            state.isShow = show
        case .toggleGoalReset(let reset):
            state.isGoalReset = reset
        case .toggleAppReview(let show):
            state.isAppReviewShow = show
        case .toggleFloatingExtends(let extends):
            state.isFloatingExtends = extends
        case .toggleAlert(let alert):
            state.isAlert = alert
        case .resetGoal:
            Task { await resetGoal() }
        }
    }
    
    private func resetGoal() async {
        do {
            try await settingUseCase.reset()
        } catch {
            debugPrint("목표 초기화 : \(error)")
        }
    }
}
