import SwiftUI

struct MainView: View {
    @EnvironmentObject var coordinator: Coordinator
    @ObservedObject var mainVM: MainViewModel
    @ObservedObject var sheetVM: MainSheetViewModel
    
    // View Properties (Persistent state)
    @AppStorage("\(Date.onBoardingFormet(.now))") private var hasOpenReport: Bool = false
    @AppStorage("isTutorial") private var isTutorial: Bool = false
    
    init(mainVM: MainViewModel, sheetVM: MainSheetViewModel) {
        self.mainVM = mainVM
        self.sheetVM = sheetVM
    }
    
    var body: some View {
        GeometryReader { geo in
            let totalHeight = geo.size.height
            
            ZStack(alignment: .top) {
                // MARK: - 상단 40%: 씨앗 이미지 + 슬라이더
                VStack {
                    Image(mainVM.getStage())
                    Spacer().frame(maxHeight: 28)
                    SeedStepSlider(stage: mainVM.matchingStage(isTutorial: true))
                        .padding(.horizontal, 33)
                }
                .padding(.top, 5)
                .frame(height: totalHeight * 0.4)
                .frame(maxWidth: .infinity)
                .opacity(sheetVM.sheetState == .medium ? 1 : 0)
                .animation(.easeInOut, value: sheetVM.sheetState)
                
                // MARK: - 하단 60%: MainSheet
                MainSheet(
                    offset: totalHeight * 0.4,
                    topDetent: mainVM.topDetent,
                    mainVM: mainVM,
                    sheetVM: sheetVM
                )
                
                if mainVM.isShow {
                    LoaderView(isShow: $mainVM.isShow)
                }
                
                if !isTutorial {
                    tutorialPage
                }
            }
            .frame(width: geo.size.width, height: totalHeight)
            .onAppear {
                if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
                   let window = windowScene.windows.first {
                    mainVM.topDetent = window.safeAreaInsets.top
                }
                mainVM.offset = totalHeight * 0.4
            }
        }
        .background {
            Image("Main")
                .resizable()
                .ignoresSafeArea()
                .opacity(sheetVM.sheetState == .medium ? 1 : 0)
                .animation(.easeInOut, value: sheetVM.sheetState)
        }
        .seedDayFloatingButton(
            condition: isTutorial && !mainVM.isShow,
            bottomPadding: 0,
            mainSeedType: mainVM.originalRecord,
            isExtends: $mainVM.isFloatingExtends,
            limit: $sheetVM.limit,
            scheduleAction: {
                coordinator.present(.scheduleRecord(scheduleResponse: nil))
            },
            recordAction: {
                AnalyticsManager.shared.logRecordStart(name: mainVM.originalRecord.id)
                coordinator.present(.recordSelection)
            }
        )
        .showResetGoalAlert(
            isGoalReset: $mainVM.isGoalReset,
            cancel: {
                mainVM.isGoalReset = false
            }, action: {
                Task {
                    try await mainVM.resetGoal()
                    mainVM.currentRecord = await mainVM.getCurrentRecordType()
                    mainVM.originalRecord = mainVM.currentRecord // 저장
                    mainVM.isGoalReset = false
                }
            })
        .noGoalPeriodView(
            mainRecordType: mainVM.user.data?.mainRecordType,
            goalDays: mainVM.user.data?.goalDays,
            isDataLoaded: mainVM.user.data != nil,
            isTutorial: isTutorial && !mainVM.isShow
        ) {
         coordinator.push(.goalSelection)
        }
        .showAppReviewAlert(isShow: $mainVM.isAppReviewShow, cancel: {
            mainVM.isAppReviewShow = false
        }, action: {
            mainVM.isAppReviewShow = false
            if let url = URL(string: Policy.AppReViewURL) {
                UIApplication.shared.open(url)
            }
        })
        .seedDayMainToolBar(
            mainVM: mainVM,
            sheetVM: sheetVM,
            condition: isTutorial && !mainVM.isShow,
            isExtends: $mainVM.isFloatingExtends
        )
        .onChange(of: sheetVM.visibleToast, initial: false) {
            if sheetVM.visibleToast {
                Task {
                    try? await mainVM.currentDayFetch(for: .now)
                }
            }
        }
        .toolbarBackgroundVisibility(.hidden, for: .navigationBar)
        .navigationBarBackButtonHidden()
        .navigationBarTitleDisplayMode(.inline)
        .onAppear {
//#if DEBUG
//            // 테스트용: 리뷰 조건을 강제로 만족시킴
//            AppReviewManager.shared.forceAppReviewConditionsForTesting()
//#endif
            if AppReviewManager.shared.shouldRequestReview() {
                mainVM.isAppReviewShow = true
            }
        }
    }
    /// 튜토리얼 Some View
    @ViewBuilder
    private var tutorialPage: some View {
        ZStack {
            Rectangle()
                .fill(Color(hex: "#111111").opacity(0.75))
                .ignoresSafeArea()
            GeometryReader { geo in
                let x: CGFloat = geo.size.width - 32
                Image("ShowCase")
                    .resizable()
                    .padding(.top, mainVM.navBarHeight - 20)
                    .overlay(alignment: .topTrailing) {
                        Image("Close")
                            .resizable()
                            .frame(width: 36, height: 36)
                            .position(x: x, y: mainVM.navBarHeight + 20)
                            .onTapGesture {
                                isTutorial = true
                                mainVM.isShow = true
                            }
                    }
            }
        }
        .compositingGroup()
    }
}

#Preview {
    let appContainer = AppContainer()
    var mainVM = appContainer.makeMainViewModel()
    NavigationStack {
        MainView(
            mainVM: mainVM,
            sheetVM: appContainer.makeMainSheetViewModel()
        )
    }
}
