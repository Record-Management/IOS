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
                // 특정 ScrollView만 바운스를 끄기 위한 Helper
                ScrollBounceModifier(bounces: false)
                    .frame(width: 0, height: 0)

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
    var innerSchedules: some View {
        VStack(spacing: 20) {
            ForEach(mainVM.detailSchedules, id: \.scheduleId) { (schedule: ScheduleDetail) in
                groupSchedules(schedule: schedule)
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }
    
    @ViewBuilder
    private func groupSchedules(schedule: ScheduleDetail) -> some View {
        if let startDate = Date.convertDateForIntArray(schedule.startDate),
           let endDate = Date.convertDateForIntArray(schedule.endDate) {
            let start: String = Date.dailyRecordDateFormat(startDate)
            let end: String = Date.dailyRecordDateFormat(endDate)
            let color: ScheduleColor = ScheduleColor.matchingColor(schedule.color)
            HStack(spacing: 10) {
                RoundedRectangle(cornerRadius: 100)
                    .fill(colorBackground(color: color))
                    .frame(width: 4)
                VStack(alignment: .leading, spacing: 0) {
                    Text(schedule.title)
                        .typography(.p16SemiBold)
                        .foregroundStyle(Color.Gray._900())
                    Spacer().frame(height: 6)
                    Text("\(start) - \(end)")
                        .typography(.p12Regular)
                        .foregroundStyle(Color.Gray._500())
                    Spacer().frame(height: 4)
                    if let memo = schedule.memo {
                        Text(memo)
                            .typography(.p12Regular)
                            .foregroundStyle(Color.Gray._500())
                            .lineLimit(1)
                    } else {
                        Text("-")
                            .typography(.p12Regular)
                            .foregroundStyle(Color.Gray._500())
                            .lineLimit(1)
                    }
                }
            }
            .contentShape(Rectangle())
            .onTapGesture {
                Task {
                    let response = await sheetVM.fetchScheduleResponse(id: schedule.scheduleId)
                    coordinator.present(.scheduleRecord(scheduleResponse: response))
                }
            }
            .contextMenu(menuItems: {
                Button(action: {
                    Task {
                        let response = await sheetVM.fetchScheduleResponse(id: schedule.scheduleId)
                        coordinator.present(.scheduleRecord(scheduleResponse: response))
                    }
                }, label: {
                    Text("수정하기")
                })
                Button(action: {
                    Task {
                        let success = await sheetVM.deleteSchedule(id: schedule.scheduleId)
                        sheetVM.fetchRecordLimit()
                        sheetVM.visibleToast = success
                        sheetVM.toastMessage = RecordMethod.delete.getMessage()
                    }
                }, label: {
                    Text("삭제하기")
                })
            })
        }
    }
    
    @ViewBuilder
    var innerRecords: some View {
        Group {
            Divider().foregroundStyle(Color.Gray._200())
            
            if let currentDate = mainVM.selectedDate {
                Text(Date.dailyRecordDateFormat(currentDate))
                    .typography(.p18SemiBold)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.vertical, 24)
            }
            // schedules
            innerSchedules
            Spacer().frame(height: 20)
            // records
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

    private func compareRecords(_ lhs: IntergrationRecord, _ rhs: IntergrationRecord) -> Bool {
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
    
    private func colorBackground(color: ScheduleColor) -> Color {
        switch color {
        case .Red:    return Color(hex: "#FF5B52")
        case .Orange: return Color.Primary.main()
        case .Yellow: return Color(hex: "#FFCC00")
        case .Green:  return Color(hex: "#34C759")
        case .Blue:   return Color(hex: "#007AFF")
        case .Indigo:   return Color(hex: "#004080")
        case .Pink:   return Color(hex: "#FF2D55")
        case .Gray:   return Color.Gray._400()
        }
    }
}


// MARK: - Scroll PreferenceKey

struct ScrollOffsetPreferenceKey: PreferenceKey {
    static var defaultValue: CGFloat = 0
    static func reduce(value: inout CGFloat, nextValue: () -> CGFloat) {
        value = nextValue()
    }
}

extension View {
    func readingScrollOffset(onChange: @escaping(CGFloat) -> Void) -> some View {
        self
            .background(
                GeometryReader { geo in
                    Color.clear
                        .preference(
                            key: ScrollOffsetPreferenceKey.self,
                            value: geo.frame(in: .named("scrollOffset")).minY
                        )
                        
                }
                .onPreferenceChange(ScrollOffsetPreferenceKey.self,perform: onChange)
            )
    }
}
