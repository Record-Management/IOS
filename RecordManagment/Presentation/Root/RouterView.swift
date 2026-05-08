import SwiftUI

struct RouterView: View {
    @ObservedObject var rm: ViewModel
    @EnvironmentObject var coordinator: Coordinator
    
    var body: some View {
        ZStack {
            switch rm.currentState {
                case .initialize:
                    SplashScreen() // splashScreen
                        .transition(.opacity)
                case .login:
                    coordinator.build(page: .login)
                        .transition(.opacity)
                case .register:
                    coordinator.build(page: .term) // term -> section -> main
                        .transition(.opacity)
                case .main:
                    coordinator.build(page: .main)
                        .transition(.opacity)
            }
        }
        .animation(.easeInOut(duration: 0.2), value: rm.currentState)
        .task {
            let nextState = await rm.autoLogin()
            
            // 메인 진입 전, 찰나의 시간(flicker)을 방지하기 위해 데이터를 미리 가져옵니다.
            if nextState == .main {
                let mainVM = coordinator.appContainer.makeMainViewModel()
                
                // 유저 정보 및 메인 기록 타입 로드
                _ = await mainVM.getCurrentRecordType()
                
                // 오늘자 기록 프리로드
                try? await mainVM.fetchRecords(for: .now)
                
                // 목표 달성 보고서 체크 로직
                if !rm.isGoalChecked, let user = mainVM.user.data {
                    rm.isGoalChecked = true
                    
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
