import SwiftUI

struct PresentDatePickerView: View {
    @Bindable var store: RecordStore
    
    init(store: RecordStore) {
        self.store = store
    }
    
    var body: some View {
        ZStack {
            // dateMode가 false일 때는 Color.clear가 되어 터치를 통과시키고, true일 때는 터치를 캡처합니다.
            (store.state.dateMode ? Color.black.opacity(0.001) : Color.clear)
                .ignoresSafeArea()
                .contentShape(Rectangle())
                .sheet(isPresented: Binding(
                    get: { store.state.dateMode },
                    set: { store.send(.setDateMode($0)) }
                ).animation(.default)) {
                    SeedDayDatePickerSheet(
                        dateMode: Binding(
                            get: { store.state.dateMode },
                            set: { store.send(.setDateMode($0)) }
                        ),
                        selectedMonth: Binding(
                            get: { store.state.selectedMonth },
                            set: { store.send(.updateSelectedMonth($0)) }
                        ),
                        datePickerSize: .constant(CGSize(width: 300, height: 300)),
                        title: Binding(
                            get: { store.state.datePickerTitle },
                            set: { _ in }
                        ),
                        date: Binding(
                            get: { store.state.selectedDate },
                            set: { store.send(.confirmMonthSelection($0)) }
                        )
                    )
                }
        }
    }
}
