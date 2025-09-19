import SwiftUI
import Combine
import Alamofire

extension CalenderView {
    class ViewModel: ObservableObject {
        @Published var date = Date.now
        @Published var color: Color = .blue
        @Published var selectedDay: Date? = .now
        @Published var isFilterBox: Bool = false
        @Published var currentRecord: DropDownFilter = .all
        @Published var calendarRecord = CalenderRecord(statusCode: 0, code: "", message: "", data: nil)
        @Published var days: [DayCell] = []
        
        var recordService = RecordService.shared
        private var cancellables = Set<AnyCancellable>()
        private var keyChain: KeyChainManager = .shared
        private let common: IntergrationManager = .shared
        
        init() {
            recordService.objectWillChange
                .receive(on: RunLoop.main)
                .sink { [weak self] _ in
                    self?.objectWillChange.send()
                }
                .store(in: &cancellables)
            
            dateAndRecordCalenderInfoSubscriber()
            $selectedDay
                .sink { [weak self] date in
                    self?.recordService.selectedDate = date
                }
                .store(in: &cancellables)
        }
        
        /// ** MARK: Publisher
        // TODO: date and currentRecord Filter Publisher and Subscriber
        func dateAndRecordCalenderInfoPublisher() -> AnyPublisher<(Date, DropDownFilter), Never> {
            Publishers.CombineLatest($date, $currentRecord)
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
                    Task {
                        await self.fetchCalenderRecordInfo(for: date, type: record)
                    }
                }
                .store(in: &cancellables)
        }
    
        // TODO: Calender 기록 조회 함수
        @MainActor
        func fetchCalenderRecordInfo(for date: Date, type record: DropDownFilter, retryCount: Int = 0) async {
            guard
                let year = Calendar.current.dateComponents([.year], from: date).year,
                let month = Calendar.current.dateComponents([.month], from: date).month else { return }
            let domain = await common.manager.domain
            guard var components = URLComponents(string: "\(domain ?? "domain")/api/records/calendar/\(year)/\(month)") else { return }
            
            if record != .all {
                components.queryItems = [URLQueryItem(name: "types", value: record.name)]
            }
            guard let accessToken = keyChain.read(account: "accessToken") else { return }
            
            guard let url = components.url else { return }
            var request = URLRequest(url: url)
            request.setValue("Bearer \(accessToken)", forHTTPHeaderField: "Authorization")
            
            do {
                let (data, response) = try await URLSession.shared.data(for: request)
                
                if let res = response as? HTTPURLResponse {
                    if res.statusCode == 403 {
                        throw URLError(.userAuthenticationRequired)
                    } else if !(200..<300).contains(res.statusCode) {
                        throw URLError(.badServerResponse)
                    }
                }
                
                let decodedRecord = try JSONDecoder().decode(CalenderRecord.self, from: data)
                self.calendarRecord = decodedRecord
                print("record : \(decodedRecord)")
                
            } catch let error where (error as? URLError)?.code == .userAuthenticationRequired && retryCount < 1 {
                let refresh = await self.common.manager.authorizationToken()
                switch refresh {
                    case .success(_):
                        await self.fetchCalenderRecordInfo(for: date, type: record, retryCount: retryCount + 1)
                    case .failure(let err):
                        debugPrint("토큰 재발급 실패 : \(err)")
                }
            } catch {
                debugPrint("Calendar 조회 실패!! : \(error)")
            }
        }
        
        
        
        // TODO: 좌우 스크롤 이벤트 함수
        func horizontalScrollGesture() -> _EndedGesture<DragGesture>{
            DragGesture().onEnded { value in
                if value.translation.width < -50 {
                    if let next = Calendar.current.date(byAdding: .month, value: 1, to: self.date) {
                        withAnimation(.smooth) {
                            self.date = next
                        }
                    }
                } else if value.translation.width > 50 {
                    if let prev = Calendar.current.date(byAdding: .month, value: -1, to: self.date) {
                        withAnimation(.smooth) {
                            self.date = prev
                        }
                    }
                }
            }
        }
    }
}
