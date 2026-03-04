import SwiftUI

struct MainView: View {
    @StateObject private var recordVM: RecordViewModel = .init(
        useCase: RecordUseCase(
            repository: DefaultRecordRepository()
        ),
        settingUseCase: SettingUseCase(
            repository: DefaultSettingRepository()
        )
    )
    @EnvironmentObject var selectionVM: RecordSelectionView.ViewModel
    @EnvironmentObject var rm: RouterView.ViewModel
    @EnvironmentObject var coordinator: Coordinator
    @EnvironmentObject var sheetVM: MainSheetViewModel
    
    // View Properties
    @AppStorage("\(Date.onBoardingFormet(.now))") private var hasOpenReport: Bool = false
    @AppStorage("isTutorial") private var isTutorial: Bool = false
    @State private var offset: CGFloat = 0
    @State private var topDetent: CGFloat = 0
    @State private var navBarHeight: CGFloat = 0
    @State private var isShow: Bool = false
    @State private var isGoalReset: Bool = false
    
    var body: some View {
        ZStack(alignment: .top) {
            NavigationBarProxy { _ , navBar, _ in
                self.navBarHeight = navBar.bounds.height
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
                    Image(selectionVM.getStage())
                    Spacer().frame(maxHeight: 28)
                    SeedStepSlider(stage: selectionVM.matchingStage(isTutorial: true))
                        .padding(.horizontal, 33)
                }
                .padding(.top, 5)
                .frame(height: size.height * 0.4)
            }
            .animation(.easeInOut, value: sheetVM.sheetState)
            
            MainSheet(
                offset: offset,
                topDetent: topDetent,
                recordVM: recordVM
            )
            .environmentObject(rm)
            .environmentObject(sheetVM)
            .environmentObject(selectionVM)
            .background {
                GeometryReader { geo in
                    let size = geo.size
                    Color.clear
                        .onAppear {
                            if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
                               let window = windowScene.windows.first {
                                let topInset = window.safeAreaInsets.top
                                self.topDetent = topInset
                            }
                            self.offset = (size.height - topDetent) * 0.4
                        }
                }
            }
            
            if isShow {
                LoaderView(isShow: $isShow)
            }
            
            if !isTutorial {
                ZStack {
                    Rectangle()
                        .fill(Color(hex: "#111111").opacity(0.75))
                        .ignoresSafeArea()
                    GeometryReader { geo in
                        let x: CGFloat = geo.size.width - 32
                        Image("ShowCase")
                            .resizable()
                            .padding(.top, navBarHeight - 20)
                            .overlay(alignment: .topTrailing) {
                                Image("Close")
                                    .resizable()
                                    .frame(width: 36, height: 36)
                                    .position(x: x, y: navBarHeight + 20)
                                    .onTapGesture {
                                        isTutorial = true
                                        isShow = true
                                    }
                            }
                    }
                }
                .compositingGroup()
            }
        }
        .overlay(
            Group {
                if isTutorial && !isShow {
                    FloatingButton() {
                        guard recordVM.currentRecordCount < 2 else {
                            sheetVM.error = .totalLimit
                            return
                        }
                        
                        // start logging insert
                        AnalyticsManager.shared.logRecordStart(name: selectionVM.originalRecord.id)
                        
                        coordinator.present(.recordSelection(
                            selectionVM: selectionVM,
                            recordVM: recordVM
                        ))
                    }
                    .frame(width: 52, height: 52)
                    .padding(.trailing, 16)
                    .padding(.bottom, 52 + 16)
                    .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .bottomTrailing)
                    .zIndex(1)
                } else {
                    EmptyView()
                }
            }
        )
        .showResetGoalAlert(
            isGoalReset: $isGoalReset,
            cancel: {
                isGoalReset = false
            }, action: {
                Task {
                    try await recordVM.resetGoal()
                    selectionVM.currentRecord = await selectionVM.getCurrentRecordType()
                    selectionVM.originalRecord = selectionVM.currentRecord // 저장
                    isGoalReset = false
                }
            })
        .noGoalPeriodView(
            mainRecordType: selectionVM.user.data?.mainRecordType,
            goalDays: selectionVM.user.data?.goalDays,
            isTutorial: isTutorial && !isShow
        ) {
            coordinator.push(.goalSelection)
        }
        .toolbar {
            if isTutorial && !isShow {
                switch sheetVM.sheetState {
                    case .medium:
                        if DropDownFilter.matchingType(type: selectionVM.user.data?.mainRecordType ?? "") != .all {
                            ToolbarItem(placement: .topBarLeading) {
                                HStack(spacing: 4) {
                                    Image(DropDownFilter.matchingType(type: selectionVM.user.data?.mainRecordType ?? "").getImage())
                                    if let goalDay = selectionVM.user.data?.goalDays {
                                        Text("D-\(goalDay)")
                                            .typography(.p16SemiBold)
                                    }
                                }
                                .onTapGesture {
                                    isGoalReset = true
                                }
                            }
                        }
                    case .large:
                        ToolbarItem(placement: .topBarLeading) {
                            Image(systemName: "chevron.left")
                                .higBackSize()
                                .onTapGesture {
                                    withAnimation(.interactiveSpring) {
                                        sheetVM.sheetState = .medium
                                    }
                                }
                        }
                        if DropDownFilter.matchingType(type: selectionVM.user.data?.mainRecordType ?? "") != .all {
                            ToolbarItem(placement: .title) {
                                HStack(spacing: 4) {
                                    Image(DropDownFilter.matchingType(type: selectionVM.user.data?.mainRecordType ?? "").getImage())
                                    if let goalDay = selectionVM.user.data?.goalDays {
                                        Text("D-\(goalDay)")
                                            .typography(.p16SemiBold)
                                    }
                                }
                                .onTapGesture {
                                    isGoalReset = true
                                }
                            }
                        }
                }
                
                ToolbarItem(placement: .topBarTrailing) {
                    Image("Notification")
                        .higTouchArea()
                        .onTapGesture {
                            coordinator.push(.notification(selectionVM: selectionVM, recordVM: recordVM))
                        }
                }
                
                ToolbarItem(placement: .topBarTrailing) {
                    Image("Setting")
                        .higTouchArea()
                        .onTapGesture {
                            coordinator.push(.setting(resVM: selectionVM))
                        }
                }
            }
        }
        .task {
            selectionVM.currentRecord = await selectionVM.getCurrentRecordType()
            selectionVM.originalRecord = selectionVM.currentRecord // 저장
            debugPrint("goal : \(selectionVM.originalRecord)")
            debugPrint("data : \(selectionVM.user)")
            guard let user = selectionVM.user.data else { return }
            
            let goal = await rm.achieveGoal(userId: user.id)
            if let data = goal?.data {
                debugPrint("data : \(data)")
                if data.currentPeriod == nil && !hasOpenReport {
                    guard !data.recentHistory.isEmpty else { return }
                    
                    if let recentHistory = data.recentHistory[0] {
                        coordinator.present(.achievementGoal(goal: recentHistory, achiveCount: data.cumulativeAchievementCount))
                    }
                }
            }
        }
        .task {
            try? await recordVM.currentDayFetch(for: .now) // currentRecordCount update
        }
        .onChange(of: sheetVM.visibleToast, initial: false) {
            if sheetVM.visibleToast {
                Task {
                    try? await recordVM.currentDayFetch(for: .now)
                }
            }
        }
        .toolbarBackgroundVisibility(.hidden, for: .navigationBar)
        .navigationBarBackButtonHidden()
        .navigationBarTitleDisplayMode(.inline)
    }
}

#Preview {
    NavigationStack {
        MainView()
            .environmentObject(
                RecordSelectionView.ViewModel(
                    useCase: UserUseCase(repository: DefaultUserRepository())
                )
            )
            .environmentObject(
                RouterView.ViewModel(
                    useCase: RouterUseCase(
                        repository: DefaultRouterRepository()
                    )
                )
            )
            .environmentObject(Coordinator())
            .environmentObject(
                MainSheetViewModel(
                    useCase: MainSheetUseCase(
                        repository: DefaultMainSheetRepository()
                    )
                )
            )
    }
}
