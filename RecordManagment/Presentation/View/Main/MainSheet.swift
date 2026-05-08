import SwiftUI

// MARK: - Draggable Panel View
struct MainSheet: View {
    @ObservedObject var mainVM: MainViewModel
    @ObservedObject var sheetVM: MainSheetViewModel
    @EnvironmentObject var coordinator: Coordinator
    
    // View Properties
    @State private var datePickerSize: CGSize = .zero
    var offset: CGFloat
    var topDetent: CGFloat
    
    init(
        offset: CGFloat,
        topDetent: CGFloat,
        mainVM: MainViewModel,
        sheetVM: MainSheetViewModel
    ) {
        self.offset = offset
        self.topDetent = topDetent
        self.mainVM = mainVM
        self.sheetVM = sheetVM
        
        // scroll Bounce Effect 제거
        UIScrollView.appearance().bounces = false
    }
    
    var body: some View {
        VStack(spacing: 0) {
            Capsule()
                .fill(Color.secondary)
                .frame(width: 40, height: 5)
                .padding(.vertical, 10)

            scrollContent
        }
        .sheet(isPresented: $sheetVM.dateMode) {
            SeedDayDatePickerSheet(
                dateMode: $sheetVM.dateMode,
                selectedMonth: $sheetVM.selectedMonth,
                datePickerSize: $datePickerSize,
                title: $sheetVM.title,
                date: $sheetVM.date
            )
        }
        .background(Color(.systemBackground))
        .frame(height: UIScreen.main.bounds.height)
        .cornerRadius(16, corners: [.topLeft, .topRight])
        .offset(y: sheetVM.sheetState == .medium ? offset : topDetent)
        .animation(.spring(duration: 0.25), value: sheetVM.sheetState)
        .simultaneousGesture(
            sheetVM.dragSheetGesture()
        )
        .overlay {
            ToastMessage(visibleToast: $sheetVM.visibleToast, toastMessage: sheetVM.toastMessage)
        }
        .overlay {
            if let error = sheetVM.error {
                LimitAlertView(error: error) {
                    sheetVM.error = nil
                }
            }
        }
        .contentShape(Rectangle())
        .onTapGesture {
            if sheetVM.isFilterBox {
                withAnimation(.interactiveSpring) {
                    sheetVM.isFilterBox = false
                }
            }
        }
    }
    
    var scrollContent: some View {
        ScrollView {
            VStack(spacing: 0) {
                Color.clear
                    .frame(height: 0)
                    .readingScrollOffset { minY in
                        sheetVM.scrollOffset = -minY
                    }
                CalendarView(
                    sheetVM: sheetVM,
                    datePickerSize: $datePickerSize
                )
                .padding(.top, 9)
                .compositingGroup()
                innerRecords
            }
            .scrollTargetLayout()
            .padding(.bottom, (sheetVM.sheetState == .medium ? offset : topDetent) + 80)
        }
        .scrollIndicators(.hidden)
    }
    
    @ViewBuilder
    var innerRecords: some View {
        Group {
            Divider().foregroundStyle(Color.Gray._200())
            if let currentDate = mainVM.selectedDate, !mainVM.detailRecords.isEmpty {
                Text(Date.dailyRecordDateFormat(currentDate))
                    .typography(.p18SemiBold)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.vertical, 24)
            }
            recordList()
            .onChange(of: sheetVM.visibleToast) {
                if sheetVM.visibleToast {
                    mainVM.refreshSubject.send()
                }
            }
        }
        .onChange(of: mainVM.detailRecords) { _, newValue in
            mainVM.detailRecords = newValue.sorted { lhs, rhs in
                compareRecords(lhs, rhs)
            }
        }
        .onChange(of: mainVM.filterdRecords) { _, newValue in
            mainVM.filterdRecords = newValue.sorted { lhs, rhs in
                compareRecords(lhs, rhs)
            }
        }
        .padding(.horizontal)
    }
    
    @ViewBuilder
    private func recordList() -> some View {
        VStack {
            ForEach(sheetVM.currentRecord == .all ? mainVM.detailRecords : mainVM.filterdRecords, id: \.self) { record in
                switch record {
                case .daily(let dailyInfo):
                    DailyRecordCard(
                        dailyInfo: dailyInfo,
                        isDismiss: $sheetVM.isDismiss,
                        mainVM: mainVM,
                        sheetVM: sheetVM
                    )
                case .exercise(let exerciseInfo):
                    ExerciseRecordCard(
                        info: exerciseInfo,
                        isDismiss: $sheetVM.isDismiss,
                        mainVM: mainVM,
                        sheetVM: sheetVM
                    )
                case .habit(let habitInfo):
                    HabitRecordCard(
                        info: habitInfo,
                        isDismiss: $sheetVM.isDismiss,
                        mainVM: mainVM,
                        sheetVM: sheetVM,
                        completeAction: { id, isCompleted in
                            Task {
                                await sheetVM.updateCompletedHabit(recordId: id, isCompleted: isCompleted)
                                sheetVM.isCompleted = isCompleted
                            }
                        }
                    )
                    .onAppear {
                        sheetVM.isCompleted = habitInfo.isCompleted ?? false
                    }
                }
            }
        }
    }

    func compareRecords(_ lhs: IntergrationRecord, _ rhs: IntergrationRecord) -> Bool {
        if case .habit(let lhsHabit) = lhs, case .habit(let rhsHabit) = rhs {
            if lhsHabit.isMainRecord != rhsHabit.isMainRecord {
                return lhsHabit.isMainRecord
            }
        }

        let userMainType = mainVM.user.data?.mainRecordType
        let lhsPriority = lhs.base.type == userMainType
        let rhsPriority = rhs.base.type == userMainType

        if lhsPriority != rhsPriority {
            return lhsPriority
        }

        let lhsDate = Date.convertDateForIntArray(lhs.base.recordDate) ?? .distantPast
        let rhsDate = Date.convertDateForIntArray(rhs.base.recordDate) ?? .distantPast

        return lhsDate < rhsDate
    }
}
