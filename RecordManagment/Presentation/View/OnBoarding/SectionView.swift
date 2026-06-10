import SwiftUI

struct SectionView: View {
    typealias ProgressPage = RecordManagment.ProgressPage
    
    @EnvironmentObject var coordinator: Coordinator
    let store: OnBoardingStore

    init(store: OnBoardingStore) {
        self.store = store
    }
    
    var isNextDisabled: Bool {
        switch store.state.currentProgress {
        case .record:
            return store.state.currentRecord == .none
        case .name:
            return !store.state.isValidName
        case .birth:
            let isActiveDate = Calendar.current.date(byAdding: .year, value: -4, to: Date())
            return store.state.selectedDate > isActiveDate ?? .now ? true : false
        case .goal:
            return store.state.selectGoal == .none
        case .notification:
            return false
        }
    }
    
    var body: some View {
        VStack {
            CustomProgress(
                value: store.state.currentProgress.rawValue + 1.0,
                total: ProgressPage.totalPage
            )
            VStack {
                switch store.state.currentProgress {
                    case .record:
                        SectionOneView()
                    case .name:
                        SectionTwoView()
                    case .birth:
                        SectionThreeView()
                    case .goal:
                        SectionFourView()
                    case .notification:
                        SectionFiveView()
                }
                
                Button(store.state.currentProgress == .notification ? "완료하기" : "다음") {
                    if store.state.currentProgress == .notification {
                        store.send(.requestPermission)
                    } else {
                        next(store.state.currentProgress)
                    }
                }
                .seedDaysButtonStyle(type: isNextDisabled ? .normal : .success, state: .primary)
                .disabled(isNextDisabled)
            }
            .padding()
            .onChange(of: store.state.isGrant) {
                next(store.state.currentProgress) {
                    if let grant = store.state.isGrant {
                        if grant {
                            coordinator.push(.finalOnBoarding(store: store, message: nil))
                        } else {
                            coordinator.push(.finalOnBoarding(store: store, message: "알림 설정이 거부되었습니다."))
                        }
                    }
                }
            }
            .alert("알림 권한", isPresented: bindingIsGrantAlert, actions: {
                Button("설정으로 이동") {
                    Task {
                        await moveAppSetting()
                    }
                }
                Button("취소", role: .cancel) {
                    store.send(.bindingIsGrant(false))
                }
            }, message: {
                Text("알림 권한을 허용하면 알림을 받을 수 있어요")
                    .typography(.p14Medium)
            })
            .onReceive(NotificationCenter.default.publisher(for: UIApplication.willEnterForegroundNotification)) { _ in
                store.send(.checkPermission)
            }
        }
        .environment(store)
    }
    
    private func moveAppSetting() async {
        await withCheckedContinuation { continuation in
            guard let url = URL(string: UIApplication.openSettingsURLString),
                  UIApplication.shared.canOpenURL(url) else {
                Log.info("설정 화면을 열 수 없습니다.")
                return
            }
            UIApplication.shared.open(url)
            continuation.resume()
        }
    }
    
    private func next(_ current: ProgressPage, completion: (() -> Void)? = nil) {
        if current == ProgressPage.allCases.last {
            completion?()
        } else {
            withAnimation {
                store.send(.bindingCurrentProgress(ProgressPage.allCases[Int(current.rawValue + 1.0)]))
            }
        }
    }
    
    // MARK: - Binding
    private var bindingIsGrantAlert: Binding<Bool> {
        Binding(
            get: { store.state.isGrantAlert },
            set: { store.send(.bindingIsGrantAlert($0)) }
        )
    }
}
