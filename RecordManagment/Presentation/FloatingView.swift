import SwiftUI

struct FloatingView: View {
    @EnvironmentObject var coordinator: Coordinator
    @Bindable var store: MainStore
    @State private var lastCover: FullScreenCover?
    @State private var lastPage: Page?
    
    init(store: MainStore) {
        self.store = store
    }
    
    var body: some View {
        ZStack {
            // Empty view to layout full screen.
            // It has no background, so touch events will pass through to the MainWindow.
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .allowsTightening(false)
        .seedDayFloatingButton(
            condition: coordinator.isFloatingButtonVisible,
            bottomPadding: 0,
            mainSeedType: store.userStore.state.originalRecord,
            isExtends: bindingIsExtends,
            limit: bindingLimit,
            scheduleAction: {
                coordinator.present(.scheduleRecord(scheduleResponse: nil))
            },
            recordAction: {
                coordinator.present(.recordSelection)
            }
        )
        .noGoalPeriodView(
            condition: coordinator.isNoGoalPeriodVisible,
            checkGoal: store.userStore.state.checkGoal
        ) {
            coordinator.push(.goalSelection)
        }
        .onChange(of: coordinator.fullScreenCover) { _, newValue in
            if let newValue {
                lastCover = newValue
            }
        }
        .onChange(of: coordinator.path) { oldValue, newValue in
            if let last = newValue.last {
                lastPage = last
            }
            if newValue.isEmpty && !oldValue.isEmpty {
                if let poppedPage = lastPage {
                    switch poppedPage {
                    case .dailyRecordEdit, .exerciseRecordEdit, .habitRecordEdit, .scheduleRecordEdit:
                        store.send(.disAppearRefreshView)
                    default:
                        break
                    }
                }
            }
        }
        .fullScreenCover(item: $coordinator.fullScreenCover) {
            if let dismissedCover = lastCover {
                switch dismissedCover {
                case .dailyRecord, .exerciseRecord, .habitRecord, .scheduleRecord:
                    Log.info("요청을 했는가?")
                    // 기록 관련 모달이 닫힌 경우에만 재요청 진행
                    store.send(.disAppearRefreshView)
                default:
                    break
                }
            }
        } content: { cover in
            coordinator.build(fullScreenCover: cover)
        }
    }
    
    private var bindingIsExtends: Binding<Bool> {
        Binding(
            get: { store.state.isFloatingExtends },
            set: { store.send(.setFloatingExtends($0)) }
        )
    }
    
    private var bindingLimit: Binding<DailyRecordLimit> {
        Binding(
            get: { store.recordStore.state.limit },
            set: { store.recordStore.send(.setLimit($0)) }
        )
    }
}
