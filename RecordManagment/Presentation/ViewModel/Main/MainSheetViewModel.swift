import SwiftUI
import Combine

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

@MainActor
final class MainSheetViewModel: ObservableObject {
    // MARK: - Navigation & UI State
    @Published var scrollOffset: CGFloat = 0
    @Published var sheetState: SheetState = .medium
    @Published var visibleToast: Bool = false
    @Published var toastMessage: String = "기록 저장이 완료 되었습니다."
    @Published var error: RecordError? = nil
    @Published var isDismiss: Bool = false
    @Published var isCompleted: Bool = false
    
    // MARK: - Calendar State (From CalendarView.ViewModel)
    @Published var focusedWeek: Week = .current
    @Published var title: String = Calendar.monthAndYear(from: .now)
    @Published var date: Date = .now
    @Published var selectedMonth: Date = .now
    @Published var isFilterBox: Bool = false
    @Published var currentRecord: DropDownFilter = .all
    @Published var calendarRecord = CalendarRecord(statusCode: 0, code: "", message: "", data: nil)
    @Published var dateMode: Bool = false
    
    // MARK: - Schedule, daily Limit
    @Published var limit: DailyRecordLimit = .default
    
    // MARK: - Dependencies
    private let useCase: MainSheetUseCase
    private let calendarUseCase: CalendarUseCase
    private let scheduleRepository: ScheduleRepository
    
    @ObservedObject var mainVM: MainViewModel
    
    private var cancellables = Set<AnyCancellable>()
    
    init(
        useCase: MainSheetUseCase,
        calendarUseCase: CalendarUseCase,
        mainVM: MainViewModel,
        scheduleRepository: ScheduleRepository
    ) {
        self.useCase = useCase
        self.calendarUseCase = calendarUseCase
        self.mainVM = mainVM
        self.scheduleRepository = scheduleRepository
        setupSubscribers()
    }
    
    private func setupSubscribers() {
        // 기존 토스트 핸들러
        $visibleToast
            .removeDuplicates()
            .receive(on: RunLoop.main)
            .sink { [weak self] val in
                if val {
                    self?.mainVM.refreshSubject.send()
                    if let current = self?.currentRecord {
                        self?.currentRecord = current
                    }
                    
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.7) {
                        withAnimation {
                            self?.visibleToast = false
                        }
                    }
                }
            }
            .store(in: &cancellables)
        
        // 캘린더 날짜 변경 시 MainViewModel 업데이트
        $date
            .dropFirst()
            .sink { [weak self] date in
                self?.mainVM.selectedDate = date
            }
            .store(in: &cancellables)
        
        // 필터 변경 시 MainViewModel 업데이트
        $currentRecord
            .sink { [weak self] record in
                self?.mainVM.recordFilter = record
            }
            .store(in: &cancellables)
            
        // 캘린더 데이터 로드 자동화 (월 또는 필터 변경 시)
        Publishers.CombineLatest($selectedMonth, $currentRecord)
            .debounce(for: .milliseconds(300), scheduler: RunLoop.main)
            .receive(on: RunLoop.main)
            .sink { [weak self] (date, record) in
                guard let self = self else { return }
                Task {
                    do {
                        self.calendarRecord = try await self.calendarUseCase.performTotalCalendar(for: date, type: record)
                        // 필터링된 레코드 동기화
                        if record == .all {
                            self.mainVM.filterdRecords = self.mainVM.detailRecords
                        } else {
                            self.mainVM.filterdRecords = self.mainVM.detailRecords.filter { $0.name == record.name }
                        }
                    } catch {
                        debugPrint("calendarRecord Error: \(error)")
                    }
                }
            }
            .store(in: &cancellables)
    }
    
    // MARK: - Actions
    func dragSheetGesture() -> _EndedGesture<DragGesture> {
        DragGesture()
            .onEnded { value in
                let move = value.translation.height
                guard self.scrollOffset <= 0 else { return }
                
                if move > 100 {
                    SheetState.down(&self.sheetState)
                } else if move < -100 {
                    SheetState.up(&self.sheetState)
                }
            }
    }
    
    func refreshCalendar() async {
        do {
            self.calendarRecord = try await self.calendarUseCase.performTotalCalendar(for: selectedMonth, type: currentRecord)
        } catch {
            debugPrint("refreshCalendar Error: \(error)")
        }
    }
    
    func updateCompletedHabit(recordId: String, isCompleted: Bool) async {
        do {
            try await self.useCase.fetch(isCompleted, recordId: recordId)
            self.currentRecord = self.currentRecord
        } catch {
            debugPrint("fetch Error : \(error)")
        }
    }
    
    func fetchRecordLimit() {
        Task {
            do {
                self.limit = try await scheduleRepository.fetchRecordLimit()
            } catch {
                debugPrint("daily RecordLimit Error : \(error)")
            }
        }
    }
}
