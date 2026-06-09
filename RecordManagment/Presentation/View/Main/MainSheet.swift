import SwiftUI

// MARK: - Draggable Panel View
struct MainSheet: View {
    @EnvironmentObject var coordinator: Coordinator
    @Bindable var store: MainStore
    
    // View Properties (Local UI States)
    @State private var isFilterBox: Bool = false
    @State private var currentRecord: DropDownFilter = .all
    @State private var isDismiss: Bool = false
    @State private var isCompleted: Bool = false
    @State private var datePickerSize: CGSize = .zero
    
    private var recordStore: RecordStore {
        store.recordStore
    }
    
    init(store: MainStore) {
        self.store = store
    }
    
    var body: some View {
        scrollContent
    }
    
    @ViewBuilder
    var scrollContent: some View {
        VStack(spacing: 0) {
            CalendarView(
                dateMode: Binding(
                    get: { recordStore.state.dateMode },
                    set: { recordStore.send(.setDateMode($0)) }
                ).animation(.default),
                isFilterBox: $isFilterBox,
                currentRecord: $currentRecord,
                date: Binding(
                    get: { recordStore.state.selectedDate },
                    set: { recordStore.send(.selectDate($0)) }
                ),
                monthlyRecords: Binding(
                    get: { recordStore.state.monthlyRecords },
                    set: { _ in }
                ),
                selectedMonth: Binding(
                    get: { recordStore.state.selectedMonth },
                    set: { recordStore.send(.updateSelectedMonth($0)) }
                ),
                datePickerSize: $datePickerSize
            )
            .compositingGroup()
            
            innerRecords
        }
        .contentShape(Rectangle())
        .onTapGesture {
            if isFilterBox {
                withAnimation(.interactiveSpring) {
                    isFilterBox = false
                }
            }
        }
        .onAppear {
            recordStore.send(.fetchRecords(recordStore.state.selectedDate))
            recordStore.send(.fetchCalendar(recordStore.state.selectedMonth, currentRecord))
        }
        .onChange(of: currentRecord) { _, newValue in
            recordStore.send(.updateFilter(newValue))
        }
        .onChange(of: recordStore.state.selectedMonth) { _, newValue in
            recordStore.send(.fetchCalendar(newValue, currentRecord))
        }
    }
    
    @ViewBuilder
    var innerSchedules: some View {
        VStack(spacing: 20) {
            ForEach(recordStore.state.detailSchedules, id: \.scheduleId) { (schedule: ScheduleDetail) in
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
                    if let response = await recordStore.fetchScheduleResponse(id: schedule.scheduleId) {
                        coordinator.present(.scheduleRecord(scheduleResponse: response))
                    }
                }
            }
            .contextMenu(menuItems: {
                Button(action: {
                    Task {
                        if let response = await recordStore.fetchScheduleResponse(id: schedule.scheduleId) {
                            coordinator.present(.scheduleRecord(scheduleResponse: response))
                        }
                    }
                }, label: {
                    Text("수정하기")
                })
                Button(action: {
                    recordStore.send(.deleteSchedule(id: schedule.scheduleId))
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
            
            Text(Date.dailyRecordDateFormat(recordStore.state.selectedDate))
                .typography(.p18SemiBold)
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.vertical, 24)
            // schedules
            innerSchedules
            Spacer().frame(height: 20)
            // records
            recordList()
        }
    }
    
    @ViewBuilder
    private func recordList() -> some View {
        VStack {
            let records = (currentRecord == .all ? recordStore.state.detailRecords : recordStore.state.filterdRecords).sorted(by: compareRecords)
            ForEach(records, id: \.self) { record in
                switch record {
                case .daily(let dailyInfo):
                    DailyRecordCard(
                        dailyInfo: dailyInfo,
                        isDismiss: $isDismiss,
                        store: store
                    )
                case .exercise(let exerciseInfo):
                    ExerciseRecordCard(
                        info: exerciseInfo,
                        isDismiss: $isDismiss,
                        store: store
                    )
                case .habit(let habitInfo):
                    HabitRecordCard(
                        info: habitInfo,
                        isDismiss: $isDismiss,
                        store: store,
                        completeAction: { id, isCompleted in
                            recordStore.send(.updateCompletedHabit(recordId: id, isCompleted: isCompleted))
                        }
                    )
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
        
        let userMainType = store.userStore.state.user?.mainRecordType
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
        case .Indigo: return Color(hex: "#004080")
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
                .onPreferenceChange(ScrollOffsetPreferenceKey.self, perform: onChange)
            )
    }
}
