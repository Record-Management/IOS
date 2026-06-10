import SwiftUI

struct FloatingView: View {
    @EnvironmentObject var coordinator: Coordinator
    @Bindable var store: MainStore
    
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
        .fullScreenCover(item: $coordinator.fullScreenCover) { cover in
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
