import SwiftUI

struct MainView: View {
    @StateObject private var recordVM: RecordViewModel = .init(
        useCase: RecordUseCase(
            repository: DefaultRecordRepository()
        )
    )
    @EnvironmentObject var selectionVM: RecordSelectionView.ViewModel
    @EnvironmentObject var rm: RouterView.ViewModel
    @EnvironmentObject var coordinator: Coordinator
    @EnvironmentObject var sheetVM: MainSheetViewModel
    @State private var offset: CGFloat = 0
    @State private var topDetent: CGFloat = 0
    
    var body: some View {
        ZStack(alignment: .top) {
            // 1. Background Image
            Image("Main")
                .resizable()
                .ignoresSafeArea()
                .opacity(sheetVM.sheetState == .medium ? 1 : 0)
                .animation(.easeInOut, value: sheetVM.sheetState)
            GeometryReader { geo in
                let size = geo.size
                
                HStack {
                    Spacer()
                    Image(selectionVM.getStage(receive: selectionVM.stage))
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(width: size.width ,height: size.height * 0.35)
                    Spacer()
                }
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
                    Color.clear
                        .onAppear {
                            if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
                               let window = windowScene.windows.first {
                                let topInset = window.safeAreaInsets.top
                                self.topDetent = topInset + 44
                            }
                            self.offset = (geo.size.height - topDetent) * 0.4
                        }
                }
            }
        }
        .overlay(
            FloatingButton() {
                guard recordVM.detailRecords.count < 2 else {
                    sheetVM.error = .totalLimit
                    return
                }
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
        )
        .noGoalPeriodView(
            mainRecordType: selectionVM.user.data?.mainRecordType,
            goalDays: selectionVM.user.data?.goalDays
        ) {
            coordinator.push(.goalSelection)
        }
        .ignoresSafeArea(edges: [.top])
        .toolbar {
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
        .task {
            guard let user = selectionVM.user.data else { return }
            print("user : \(user)")
            let goal = await rm.achieveGoal(userId: user.id)
            
            if let goal = goal {
                print("goal : \(goal)")
                guard let _ = goal.data else { return }
                coordinator.present(.achievementGoal(goal: goal))
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
