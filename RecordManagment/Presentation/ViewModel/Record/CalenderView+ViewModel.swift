import SwiftUI
import Combine
import Alamofire

extension CalendarView {
    @MainActor
    final class ViewModel: ObservableObject {
        @Published var focusedWeek: Week = .current
        @Published var title: String = Calendar.monthAndYear(from: .now)
        @Published var date: Date = .now
        @Published var color: Color = .blue
        @Published var selectedMonth: Date = .now
        @Published var isFilterBox: Bool = false
        @Published var currentRecord: DropDownFilter = .all
        @Published var calendarRecord = CalendarRecord(statusCode: 0, code: "", message: "", data: nil)
        @Published var days: [DayCell] = []
        @Published var dateMode: Bool = false
        @ObservedObject var mainVM: MainViewModel
        
        private var cancellables = Set<AnyCancellable>()
        let useCase: CalendarUseCase
        
        init(useCase: CalendarUseCase, mainVM: MainViewModel) {
            self.useCase = useCase
            self.mainVM = mainVM
            dateAndRecordCalenderInfoSubscriber()
            $date
                .dropFirst()
                .sink { [weak self] date in
                    Task { @MainActor in
                        self?.mainVM.selectedDate = date
                    }
                }
                .store(in: &cancellables)
            $currentRecord
                .sink { [weak self] record in
                    Task {
                        self?.mainVM.recordFilter = record
                    }
                }
                .store(in: &cancellables)
        }
        
        /// ** MARK: Publisher
        func dateAndRecordCalenderInfoPublisher() -> AnyPublisher<(Date, DropDownFilter), Never> {
            Publishers.CombineLatest($selectedMonth, $currentRecord)
                .debounce(for: .milliseconds(300), scheduler: RunLoop.main)
                .receive(on: RunLoop.main)
                .eraseToAnyPublisher()
        }

        /// ** MARK: Subscriber
        func dateAndRecordCalenderInfoSubscriber() {
            dateAndRecordCalenderInfoPublisher()
                .sink { [weak self] (date, record) in
                    guard let self = self else { return }
                    Task { @MainActor in
                        do {
                            self.calendarRecord = try await self.useCase.performTotalCalendar(for: date, type: record)
                            self.mainVM.filterdRecords = self.mainVM.detailRecords.filter { $0.name == record.name }
                        } catch {
                            debugPrint("calendarRecord Error: \(error)")
                        }
                    }
                }
                .store(in: &cancellables)
        }
    }
}
