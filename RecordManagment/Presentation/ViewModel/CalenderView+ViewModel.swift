import SwiftUI
import Combine
import Alamofire

extension CalendarView {
    class ViewModel: ObservableObject {
        @Published var focusedWeek: Week = .current
        @Published var title: String = Calendar.monthAndYear(from: .now)
        @Published var date: Date = .now
        @Published var color: Color = .blue
        @Published var selectedMonth: Date = .now
        @Published var isFilterBox: Bool = false
        @Published var currentRecord: DropDownFilter = .all
        @Published var calendarRecord = CalendarRecord(statusCode: 0, code: "", message: "", data: nil)
        @Published var days: [DayCell] = []
        
        var recordService = RecordService.shared
        private var cancellables = Set<AnyCancellable>()
        let useCase: CalendarUseCase
        
        init(useCase: CalendarUseCase) {
            self.useCase = useCase
            
            dateAndRecordCalenderInfoSubscriber()
            $date
                .sink { [weak self] date in
                    self?.recordService.selectedDate = date
                }
                .store(in: &cancellables)
        }
        
        /// ** MARK: Publisher
        // TODO: date and currentRecord Filter Publisher and Subscriber
        func dateAndRecordCalenderInfoPublisher() -> AnyPublisher<(Date, DropDownFilter), Never> {
            Publishers.CombineLatest($selectedMonth, $currentRecord)
                .debounce(for: .milliseconds(300), scheduler: RunLoop.main)
                .receive(on: RunLoop.main)
                .eraseToAnyPublisher()
        }

        /// ** MARK: Subscriber
        // TODO: date and currentRecord Subscriber
        func dateAndRecordCalenderInfoSubscriber() {
            dateAndRecordCalenderInfoPublisher()
                .sink { [weak self] (date, record) in
                    guard let self = self else { return }
                    Task { @MainActor in
                        do {
                            self.calendarRecord = try await self.useCase.performTotalCalendar(for: date, type: record)
                        } catch {
                            debugPrint("calendarRecord Error: \(error)")
                        }
                    }
                }
                .store(in: &cancellables)
        }
    }
}
