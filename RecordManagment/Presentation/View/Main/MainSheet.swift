import SwiftUI

// MARK: - Draggable Panel View
struct MainSheet: View {
    @ObservedObject var recordVM: RecordViewModel
    @StateObject var calendarVM: CalendarView.ViewModel
    @EnvironmentObject var coordinator: Coordinator
    @EnvironmentObject var rm: RouterView.ViewModel
    @EnvironmentObject private var selectionVM: RecordSelectionView.ViewModel
    @EnvironmentObject private var vm: MainSheetViewModel
    
    var offset: CGFloat
    var topDetent: CGFloat
    
    init(offset: CGFloat, topDetent: CGFloat, recordVM: RecordViewModel) {
        self.offset = offset
        self.topDetent = topDetent
        self.recordVM = recordVM
        _calendarVM = StateObject(wrappedValue: .init(
            useCase: CalendarUseCase(
                calendarRepository: DefaultCalendarRepository(),
            ),
            recordVM: recordVM
        ))
    }
    
    var body: some View {
        VStack(spacing: 0) {
            Capsule()
                .fill(Color.secondary)
                .frame(width: 40, height: 5)
                .padding(.vertical, 10)

            ScrollView {
                VStack(spacing: 0) {
                    Color.clear
                        .frame(height: 0)
                        .readingScrollOffset { minY in
                            // minY는 스크롤 다운 시 음수로 내려가므로, 양수 오프셋으로 변환
                            vm.scrollOffset = -minY
                        }
                    CalendarView(vm: calendarVM)
                        .environmentObject(vm)
                        .padding(.top, 9)
                    Group {
                        Divider().foregroundStyle(Color.Gray._200())
                        if let currentDate = recordVM.selectedDate, !recordVM.detailRecords.isEmpty {
                            Text(Date.dailyRecordDateFormat(currentDate))
                                .typography(.p18SemiBold)
                                .frame(maxWidth: .infinity, alignment: .leading)
                                .padding(.vertical, 24)
                        }
                        recordList()
                        .onChange(of: vm.visibleToast) {
                            if vm.visibleToast {
                                recordVM.refreshSubject.send()
                            }
                        }
                    }
                    .onChange(of: recordVM.detailRecords) { _, newValue in
                        recordVM.detailRecords = newValue.sorted { lhs, rhs in
                            compareRecords(lhs, rhs)
                        }
                    }
                    .onChange(of: recordVM.filterdRecords) { _, newValue in
                        recordVM.filterdRecords = newValue.sorted { lhs, rhs in
                            compareRecords(lhs, rhs)
                        }
                    }
                    .padding(.horizontal)
                }
                .padding(.bottom, (vm.sheetState == .medium ? offset : topDetent) + 80)
            }
            .scrollIndicators(.hidden)
        }
        .background(Color(.systemBackground))
        .frame(height: UIScreen.main.bounds.height)
        .cornerRadius(16, corners: [.topLeft, .topRight])
        .offset(y: vm.sheetState == .medium ? offset : topDetent)
        .animation(.spring(duration: 0.25), value: vm.sheetState)
        .simultaneousGesture(
            vm.dragSheetGesture()
        )
        .overlay {
            ToastMessage(visibleToast: $vm.visibleToast, toastMessage: vm.toastMessage)
        }
        .overlay {
            if let error = vm.error {
                LimitAlertView(error: error) {
                    vm.error = nil
                }
            }
        }
        .contentShape(Rectangle())
        .onTapGesture {
            if calendarVM.isFilterBox {
                withAnimation(.interactiveSpring) {
                    calendarVM.isFilterBox = false
                }
            }
        }
    }
    
    private func recordList() -> some View {
        VStack {
            ForEach(calendarVM.currentRecord == .all ? recordVM.detailRecords : recordVM.filterdRecords, id: \.self) { record in
                switch record {
                case .daily(let dailyInfo):
                    DailyRecordCard(dailyInfo: dailyInfo, isDismiss: $vm.isDismiss)
                        .environmentObject(recordVM)
                        .environmentObject(vm)
                case .exercise(let exerciseInfo):
                    ExerciseRecordCard(info: exerciseInfo, isDismiss: $vm.isDismiss)
                        .environmentObject(recordVM)
                        .environmentObject(vm)
                case .habit(let habitInfo):
                    HabitRecordCard(
                        info: habitInfo,
                        isDismiss: $vm.isDismiss,
                        completeAction: { id, isCompleted in
                            Task {
                                await vm.updateCompletedHabit(recordId: id, isCompleted: isCompleted)
                                vm.isCompleted = isCompleted
                            }
                        }
                    )
                    .onAppear {
                        vm.isCompleted = habitInfo.isCompleted ?? false
                    }
                    .environmentObject(recordVM)
                    .environmentObject(vm)
                }
            }
        }
    }

    func compareRecords(_ lhs: IntergrationRecord, _ rhs: IntergrationRecord) -> Bool {
        switch (lhs, rhs) {
        case (.habit(let lhsHabit), .habit(let rhsHabit)):
            if selectionVM.user.data?.mainRecordType == "HABIT" {
                if lhsHabit.isMainRecord != rhsHabit.isMainRecord {
                    return lhsHabit.isMainRecord && !rhsHabit.isMainRecord
                }
            }
        default:
            let lhsPriority = lhs.base.type == selectionVM.user.data?.mainRecordType
            let rhsPriority = rhs.base.type == selectionVM.user.data?.mainRecordType

            if lhsPriority != rhsPriority {
                return lhsPriority && !rhsPriority
            }
        }

        let lhsDate = Date.convertDateForIntArray(lhs.base.recordDate) ?? .distantPast
        let rhsDate = Date.convertDateForIntArray(rhs.base.recordDate) ?? .distantPast

        return lhsDate < rhsDate
    }
}

enum SheetState {
    case medium
    case large

    static func up(_ state: inout SheetState) {
        switch state {
            case .large:
                return
            case .medium:
                state = .large
        }
    }

    static func down(_ state: inout SheetState) {
        switch state {
            case .large:
                state = .medium
            case .medium:
                return
        }
    }
}
