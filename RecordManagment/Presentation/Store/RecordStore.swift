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
    private let dailyRepository: any RecordRepository
    private let exerciseRepository: any RecordRepository
    private let habitRepository: any HabitRepository
    private let scheduleRepository: ScheduleRepository
    
    init(
        calendarRepository: CalendarRepository,
        scheduleRepository: ScheduleRepository,
        habitRepository: any HabitRepository,
        dailyRepository: any RecordRepository,
        exerciseRepository: any RecordRepository
    ) {
        self.calendarRepository = calendarRepository
        self.scheduleRepository = scheduleRepository
        self.habitRepository = habitRepository
        self.dailyRepository = dailyRepository
        self.exerciseRepository = exerciseRepository
    }
    
    enum Intent {
        case fetchRecords(Date)
        case selectDate(Date)
        case setLimit(DailyRecordLimit)
        case fetchCalendar(Date, DropDownFilter)
        case updateFilter(DropDownFilter)
        case setDateMode(Bool)
        case updateSelectedMonth(Date)
        case confirmMonthSelection(Date)
        case deleteSchedule(scheduleId: String)
        // Actions
        case completeHabitButtonTapped(recordId: String, isCompleted: Bool)
        case deleteRecord(type: SeedType ,recordId: String)
    }
    
    func send(_ intent: Intent) {
        switch intent {
        case .fetchRecords(let date):
            Task { await fetchRecords(for: date) }
    
        case .selectDate(let date):
            guard state.selectedDate != date else { return }
            state.selectedDate = date
            Task { await fetchRecords(for: date) }
        
        case .setLimit(let limit):
            state.limit = limit
            
        case .fetchCalendar(let date, let filter):
            Task { await fetchCalendar(for: date, type: filter) }
            
        case .updateFilter(let filter):
            state.recordFilter = filter
            state.filterdRecords = state.detailRecords.filter { $0.name == filter.name }
            Task { await fetchCalendar(for: state.selectedMonth, type: filter) }
            
        case .setDateMode(let mode):
            withAnimation {
                state.dateMode = mode
            }
            
        case .updateSelectedMonth(let month):
            state.selectedMonth = month
            state.datePickerTitle = Calendar.monthAndYear(from: month)
            Task {
                await fetchCalendar(for: state.selectedMonth, type: state.recordFilter)
            }

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
            
        case .deleteSchedule(let scheduleId):
            Task {
                do {
                    try await scheduleRepository.delete(scheduleId: scheduleId)
                } catch {
                    Log.error("일정 삭제 실패: \(error.localizedDescription)")
                }
            }
        case .deleteRecord(let recordType, let recordId):
            Task {
                do {
                    switch recordType {
                    case .daily:
                        _ = try await dailyRepository.delete(recordId: recordId)
                    case .exercise:
                        _ = try await exerciseRepository.delete(recordId: recordId)
                    case .habit:
                        _ = try await habitRepository.delete(recordId: recordId)
                    default:
                        // 일정 제외
                        break
                    }
                } catch {
                    Log.error("기록 삭제 실패 : \(error.localizedDescription)")
                }
            }
        case .completeHabitButtonTapped(let recordId, let isCompleted):
            Task {
                do {
                    _ = try await habitRepository.fetchCompletionHabit(isCompleted, recordId: recordId)
                } catch {
                    Log.error("습관 기록 Complete 실패 : \(error.localizedDescription)")
                }
            }
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
            Log.info("detailsRecords fetch 성공: \(records.count)개의 기록, \(schedules.count)개의 일정을 정상 로드했습니다.")
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
