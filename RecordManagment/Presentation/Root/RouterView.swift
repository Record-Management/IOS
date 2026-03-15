import SwiftUI

struct RouterView: View {
    @EnvironmentObject var coordinator: Coordinator
    @EnvironmentObject var rm: RouterView.ViewModel
    
    var body: some View {
        Group {
            switch rm.currentState {
                case .initialize:
                    SplashScreen() // splashScreen
                case .login:
                    coordinator.build(page: .login)
                case .register:
                    coordinator.build(page: .term) // term -> section -> main
                case .main:
                    coordinator.build(page: .main)
            }
        }
        .task {
            let nextState = await rm.autoLogin()
            
            // 메인 진입 전, 찰나의 시간(flicker)을 방지하기 위해 데이터를 미리 가져옵니다.
            if nextState == .main {
                let recordType = await coordinator.selectionVM.getCurrentRecordType()
                coordinator.selectionVM.currentRecord = recordType
                coordinator.selectionVM.originalRecord = recordType
                
                try? await coordinator.recordVM.fetch(for: .now)
                
                // 목표 달성 보고서 체크 로직
                if let user = coordinator.selectionVM.user.data {
                    let goal = await rm.achieveGoal(userId: user.id)
                    if let data = goal?.data, data.currentPeriod == nil {
                        if let firstHistory = data.recentHistory.first, let history = firstHistory {
                            coordinator.present(.achievementGoal(goal: history, achiveCount: data.cumulativeAchievementCount))
                        }
                    }
                }
            }
            
            // 데이터 준비가 완료되면 상태를 변경하여 화면을 전환합니다.
            rm.currentState = nextState
        }
    }
}
