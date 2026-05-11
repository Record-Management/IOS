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
        ZStack(alignment: .top) {
            NavigationBarProxy { _ , navBar, _ in
                DispatchQueue.main.async {
                    mainVM.navBarHeight = navBar.bounds.height
                }
            }
            // 1. Background Image
            Image("Main")
                .resizable()
                .ignoresSafeArea()
                .opacity(sheetVM.sheetState == .medium ? 1 : 0)
                .animation(.easeInOut, value: sheetVM.sheetState)
            
            GeometryReader { geo in
                let size = geo.size
                VStack {
                    Image(mainVM.getStage())
                    Spacer().frame(maxHeight: 28)
                    SeedStepSlider(stage: mainVM.matchingStage(isTutorial: true))
                        .padding(.horizontal, 33)
                }
                .padding(.top, 5)
                .frame(height: size.height * 0.4)
            }
            .animation(.easeInOut, value: sheetVM.sheetState)
            
            MainSheet(
                offset: mainVM.offset,
                topDetent: mainVM.topDetent,
                mainVM: mainVM,
                sheetVM: sheetVM
            )
            .background {
                GeometryReader { geo in
                    let size = geo.size
                    Color.clear
                        .onAppear {
                            if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
                               let window = windowScene.windows.first {
                                let topInset = window.safeAreaInsets.top
                                mainVM.topDetent = topInset
                            }
                            mainVM.offset = (size.height - mainVM.topDetent) * 0.4
                        }
                }
            }
            
            if mainVM.isShow {
                LoaderView(isShow: $mainVM.isShow)
            }
            
            if !isTutorial {
                tutorialPage
            }
        }
        .seedDayFloatingButton(
            condition: isTutorial && !mainVM.isShow
        ) { // floating Action
            guard mainVM.currentRecordCount < 2 else {
                sheetVM.error = .totalLimit
                return
            }
            AnalyticsManager.shared.logRecordStart(name: mainVM.originalRecord.id)
            coordinator.present(.recordSelection)
        }
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
        .seedDayMainToolBar(mainVM: mainVM, sheetVM: sheetVM, condition: isTutorial && !mainVM.isShow)
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
