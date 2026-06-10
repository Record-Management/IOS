import SwiftUI

struct MainView: View {
    @EnvironmentObject var coordinator: Coordinator
    // View Properties (Persistent state)
    @State private var selectedDetent: PresentationDetent = .fraction(Constant.Main.presentationDetent)
    @State private var safeArea: EdgeInsets = .init()
    @State private var showSheet: Bool = false
    @AppStorage("\(Date.onBoardingFormet(.now))") private var hasOpenReport: Bool = false
    @State private var hasPresentedReport: Bool = false
    
    let store: MainStore
    
    init(store: MainStore) {
        self.store = store
    }
    
    var body: some View {
        ZStack {
            // TODO: - 상단 40%: 씨앗 이미지 + 슬라이더
            VStack {
                Image(getStage())
                Spacer().frame(maxHeight: 28)
                SeedStepSlider(stage: matchingStage())
                    .padding(.horizontal, 33)
                Spacer()
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .modifier(
            SeedDaySheetStyle(
                safeArea: $safeArea,
                showSheet: $showSheet,
                selectedDetent: $selectedDetent
            ) {
                MainSheet(store: store)
            }
        )
        .seedDayMainToolBar(
            isExtends: bindingIsFloatingExtends,
            presentationDetent: $selectedDetent,
            store: store
        )
        .background {
            Image("Main")
                .resizable()
                .ignoresSafeArea()
        }
        .onAppear {
            store.send(.onAppear)
        }
        .onViewDidAppear {
            showSheet = true
            coordinator.setVisibbleFloatTingState(true)
            coordinator.setVisibbleNoGoalPeriodState(true)
            
            #if DEBUG
            // 테스트용: 최초 로드 시 딱 한 번만 목표 달성 리포트 강제 팝업
            if !hasPresentedReport {
                hasPresentedReport = true
                let mockGoal = RecentHistoryData(
                    goalId: "test-id",
                    recordType: "DAILY",
                    goalDays: 30,
                    startDate: [2026, 6, 1],
                    endDate: [2026, 6, 30],
                    completedDays: 28,
                    achievementRate: 93.3,
                    finalTreeStage: "STAGE_4",
                    status: "SUCCESS"
                )
                coordinator.present(.achievementGoal(goal: mockGoal, achiveCount: 5))
            }
            #endif
        }
        .onChange(of: coordinator.path) { oldValue, newValue in
            if !newValue.isEmpty {
                showSheet = false
                coordinator.setVisibbleFloatTingState(false)
                // 알림 화면(.notification)으로 갈 때는 카드 뷰를 유지하고, 그 외에는 숨깁니다.
                let showNoGoal = newValue.last == .notification
                coordinator.setVisibbleNoGoalPeriodState(showNoGoal)
            }
        }
//        .showAppReviewAlert(isShow: $mainVM.isAppReviewShow, cancel: {
//            mainVM.isAppReviewShow = false
//        }, action: {
//            mainVM.isAppReviewShow = false
//            if let url = URL(string: Policy.AppReViewURL) {
//                UIApplication.shared.open(url)
//            }
//        })
//        .onAppear {
//            //#if DEBUG
//            // 테스트용: 리뷰 조건을 강제로 만족시킴
//            AppReviewManager.shared.forceAppReviewConditionsForTesting()
//            //#endif
//            if AppReviewManager.shared.shouldRequestReview() {
//                mainVM.isAppReviewShow = true
//            }
//        }
    }
    
    // MARK: - Binding
    
    private var bindingIsFloatingExtends: Binding<Bool> {
        Binding(
            get: { store.state.isFloatingExtends },
            set: { store.send(.setFloatingExtends($0)) }
        )
    }
    
    private var bindingRecordLimit: Binding<DailyRecordLimit> {
        Binding(
            get: { store.recordStore.state.limit },
            set: { store.recordStore.send(.setLimit($0)) }
        )
    }
}

// MARK: - Helper

extension MainView {
    /// 목표 달성 이미지 반환
    func getStage() -> String {
        switch store.userStore.state.stage {
        case "STAGE_1": "MainStep01"
        case "STAGE_2": "MainStep02"
        case "STAGE_3": "MainStep03"
        case "STAGE_4": "MainStep04"
        default: "MainStepNone"
        }
    }
    
    /// stage 서버 Response -> SeedStep 변환
    func matchingStage(isTutorial: Bool = true) -> SeedStep {
        switch store.userStore.state.stage {
        case "STAGE_1": return .stage1
        case "STAGE_2": return .stage2
        case "STAGE_3": return .stage2
        case "STAGE_4": return .stage3
        default:
            guard isTutorial else { return .tutorial }
            return .none
        }
    }
}

#Preview {
    let appContainer = AppContainer()
    let coordinator = Coordinator(appContainer: appContainer)
    NavigationStack {
        MainView(store: appContainer.makeMainStore())
            .environmentObject(coordinator)
    }
}
