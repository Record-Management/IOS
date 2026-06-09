import Foundation
import SwiftUI

/// 통합 Alert 관리를 위한 스토어
@MainActor
@Observable
final class AlertStore {
    struct State {
        var isPresented: Bool = false
        var title: String = ""
        var subTitle: String = ""
        var cancelTitle: String = "닫기"
        var confirmTitle: String = "확인"
        var isConfirmDestructive: Bool = false // 탈퇴 등 에러 버튼 스타일(레드) 구분용
        
        var onCancel: (() -> Void)? = nil
        var onConfirm: (() -> Void)? = nil
    }
    
    private(set) var state = State()
    
    enum Intent {
        case logout(cancel: () -> Void, action: () -> Void)
        case withdraw(cancel: () -> Void, action: () -> Void)
        case resetGoal(cancel: () -> Void, action: () -> Void)
        case changeMainHabitRecord(cancel: () -> Void, action: () -> Void)
        case dismissRecord(method: RecordMethod, cancel: () -> Void, action: () -> Void)
        case dismiss
    }
    
    func send(_ intent: Intent) {
        switch intent {
        case let .logout(cancel, action):
            state.title = "로그아웃 하시겠습니까?"
            state.subTitle = "로그아웃 후에는 다시 로그인해야만\n서비스 이용이 가능해요."
            state.cancelTitle = "닫기"
            state.confirmTitle = "로그아웃"
            state.isConfirmDestructive = false
            state.onCancel = cancel
            state.onConfirm = action
            state.isPresented = true
            postVisibility(true)
            
        case let .withdraw(cancel, action):
            state.title = "탈퇴를 진행 하시겠습니까?"
            state.subTitle = "탈퇴 시 모든 정보가 삭제되며, 복구가 불가합니다."
            state.cancelTitle = "닫기"
            state.confirmTitle = "탈퇴하기"
            state.isConfirmDestructive = true
            state.onCancel = cancel
            state.onConfirm = action
            state.isPresented = true
            postVisibility(true)
            
        case let .resetGoal(cancel, action):
            state.title = "설정된 목표를 초기화 하시겠습니까?"
            state.subTitle = "기존 설정된 목표를 초기화합니다.\n초기화 후에는 새로운 목표를 설정해주세요."
            state.cancelTitle = "닫기"
            state.confirmTitle = "초기화"
            state.isConfirmDestructive = false
            state.onCancel = cancel
            state.onConfirm = action
            state.isPresented = true
            postVisibility(true)
            
        case let .changeMainHabitRecord(cancel, action):
            state.title = "메인 습관 기록을 변경할까요?"
            state.subTitle = "연속 달성 기록은 유지된채\n메인 습관의 종류가 변경됩니다."
            state.cancelTitle = "닫기"
            state.confirmTitle = "변경하기"
            state.isConfirmDestructive = false
            state.onCancel = cancel
            state.onConfirm = action
            state.isPresented = true
            postVisibility(true)
            
        case let .dismissRecord(method, cancel, action):
            state.title = method.getTitle()
            state.subTitle = method.getSubTitle()
            let buttonTexts = method.alertButtonText()
            state.cancelTitle = buttonTexts.left
            state.confirmTitle = buttonTexts.right
            state.isConfirmDestructive = (method == .delete)
            state.onCancel = cancel
            state.onConfirm = action
            state.isPresented = true
            postVisibility(true)
            
        case .dismiss:
            state.isPresented = false
            postVisibility(false)
            // 액션 블록 초기화
            state.onCancel = nil
            state.onConfirm = nil
        }
    }
    
    private func postVisibility(_ visible: Bool) {
        NotificationCenter.default.post(name: .alertVisibilityChanged, object: visible)
    }
}
