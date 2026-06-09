import SwiftUI

/// 캘린더, 하루, 운동, 습관 기록들의 `Store`
@MainActor
@Observable
final class RecordStore {
    struct State {
        var detailRecords: [IntergrationRecord] = []
        var filterdRecords: [IntergrationRecord] = []
        var currentRecords: [IntergrationRecord] = []
        var detailSchedules: [ScheduleDetail] = []
        var selectedDate: Date = .now
        var recordFilter: DropDownFilter = .all
        var limit: DailyRecordLimit = .default
        var monthlyRecords: [AllRecord] = []
        var dateMode: Bool = false
        var selectedMonth: Date = .now
        var datePickerTitle: String = Calendar.monthAndYear(from: .now)
    }
    
    private(set) var state = State()
    
    // 의존성
    private let calendarRepository: CalendarRepository
    private let scheduleRepository: ScheduleRepository
    private let habitRepository: any HabitRepository
    private let recordUseCase: RecordUseCase
    
    init(
        calendarRepository: CalendarRepository,
        scheduleRepository: ScheduleRepository,
        habitRepository: any HabitRepository,
        recordUseCase: RecordUseCase
    ) {
        self.calendarRepository = calendarRepository
        self.scheduleRepository = scheduleRepository
        self.habitRepository = habitRepository
        self.recordUseCase = recordUseCase
    }
    
    enum Intent {
        case fetchRecords(Date)
        case selectDate(Date)
        case setLimit(DailyRecordLimit)
        case fetchCalendar(Date, DropDownFilter)
        case updateFilter(DropDownFilter)
        case updateCompletedHabit(recordId: String, isCompleted: Bool)
        case deleteSchedule(id: String)
        case deleteDaily(id: String)
        case deleteExercise(id: String)
        case deleteHabit(id: String)
        case setDateMode(Bool)
        case updateSelectedMonth(Date)
        case confirmMonthSelection(Date)
    }
    
    func send(_ intent: Intent) {
        switch intent {
        case .fetchRecords(let date):
            Task { await fetchRecords(for: date) }
    
        case .selectDate(let date):
            state.selectedDate = date
            Task { await fetchRecords(for: date) }
        
        case .setLimit(let limit):
            state.limit = limit
            
        case .fetchCalendar(let date, let filter):
            Task { await fetchCalendar(for: date, type: filter) }
            
        case .updateFilter(let filter):
            state.recordFilter = filter
            state.filterdRecords = state.detailRecords.filter { $0.name == filter.name }
            Task { await fetchCalendar(for: state.selectedDate, type: filter) }
            
        case .updateCompletedHabit(let recordId, let isCompleted):
            Task {
                do {
                    _ = try await habitRepository.fetchCompletionHabit(isCompleted, recordId: recordId)
                    await fetchRecords(for: state.selectedDate)
                } catch {
                    Log.error("updateCompletedHabit 실패: \(error.localizedDescription)")
                }
            }
            
        case .deleteSchedule(let id):
            Task {
                do {
                    try await scheduleRepository.delete(scheduleId: id)
                    await fetchRecords(for: state.selectedDate)
                    await fetchRecordLimit()
                    NotificationCenter.default.post(name: .toastOnAppear, object: RecordMethod.delete.getMessage())
                } catch {
                    Log.error("deleteSchedule 실패: \(error.localizedDescription)")
                }
            }
            
        case .deleteDaily(let id):
            Task {
                let result = await recordUseCase.dailyDelete(id)
                switch result {
                case .success(_):
                    await fetchRecords(for: state.selectedDate)
                    await fetchRecordLimit()
                    NotificationCenter.default.post(name: .toastOnAppear, object: RecordMethod.delete.getMessage())
                case .failure(let error):
                    Log.error("deleteDaily 실패: \(error.localizedDescription)")
                }
            }
            
        case .deleteExercise(let id):
            Task {
                let result = await recordUseCase.exerciseDelete(id)
                switch result {
                case .success(_):
                    await fetchRecords(for: state.selectedDate)
                    await fetchRecordLimit()
                    NotificationCenter.default.post(name: .toastOnAppear, object: RecordMethod.delete.getMessage())
                case .failure(let error):
                    Log.error("deleteExercise 실패: \(error.localizedDescription)")
                }
            }
            
        case .deleteHabit(let id):
            Task {
                let result = await recordUseCase.habitDelete(id)
                switch result {
                case .success(_):
                    await fetchRecords(for: state.selectedDate)
                    await fetchRecordLimit()
                    NotificationCenter.default.post(name: .toastOnAppear, object: RecordMethod.delete.getMessage())
                case .failure(let error):
                    Log.error("deleteHabit 실패: \(error.localizedDescription)")
                }
            }
            
        case .setDateMode(let mode):
            withAnimation {
                state.dateMode = mode
            }
            if mode {
                state.selectedMonth = state.selectedDate
                state.datePickerTitle = Calendar.monthAndYear(from: state.selectedDate)
            }
            
        case .updateSelectedMonth(let month):
            state.selectedMonth = month
            state.datePickerTitle = Calendar.monthAndYear(from: month)
            
        case .confirmMonthSelection(let month):
            state.selectedMonth = month
            state.selectedDate = month
            state.datePickerTitle = Calendar.monthAndYear(from: month)
            withAnimation {
                state.dateMode = false
            }
            Task {
                await fetchRecords(for: month)
                await fetchCalendar(for: month, type: state.recordFilter)
            }
        }
    }
    
    func fetchScheduleResponse(id scheduleId: String) async -> ScheduleResponse? {
        do {
            return try await scheduleRepository.fetch(scheduleId: scheduleId)
        } catch {
            Log.error("fetchScheduleResponse 실패: \(error.localizedDescription)")
            return nil
        }
    }
}

// MARK: - Private

private extension RecordStore {
    func fetchRecords(for date: Date) async {
        do {
            let (records, schedules) = try await calendarRepository.fetchDateDetailRecords(for: date)
            state.detailRecords = records
            state.detailSchedules = schedules
            state.filterdRecords = records.filter { $0.name == state.recordFilter.name }
            
            if Calendar.current.isDateInToday(date) {
                state.currentRecords = records
            }
        } catch {
            Log.error("detailRecord fetch 실패 : \(error.localizedDescription)")
        }
    }
    
    func fetchCalendar(for date: Date, type: DropDownFilter) async {
        do {
            let record = try await calendarRepository.fetchTotalDays(for: date, type: type)
            state.monthlyRecords = record.data?.monthlyRecords ?? []
        } catch {
            Log.error("fetchCalendar 실패: \(error.localizedDescription)")
        }
    }
    
    func fetchRecordLimit() async {
        do {
            let limit = try await scheduleRepository.fetchRecordLimit()
            state.limit = limit
        } catch {
            Log.error("daily RecordLimit Error : \(error.localizedDescription)")
        }
    }
}
