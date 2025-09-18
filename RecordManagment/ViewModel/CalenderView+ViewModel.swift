import SwiftUI
import Combine

extension CalenderView {
    class ViewModel: ObservableObject {
        @Published var date = Date.now
        @Published var color: Color = .blue
        @Published var selectedDay: Date? = .now
        @Published var isFilterBox: Bool = false
        @Published var currentRecord: DropDownFilter = .all
        @Published var calendarRecord = CalenderRecord(statusCode: 0, code: "", message: "", data: nil)
        @Published var days: [DayCell] = []
        
        private var cancellables = Set<AnyCancellable>()
        private let manager: LoginNetworkManager = .init()
        
        init() {
            dateAndRecordCalenderInfoSubscriber()
        }
        
        /// ** MARK: Publisher
        // TODO: date and currentRecord Filter Publisher and Subscriber
        func dateAndRecordCalenderInfoPublisher() -> AnyPublisher<(Date, DropDownFilter), Never> {
            Publishers.CombineLatest($date, $currentRecord)
                .debounce(for: .milliseconds(300), scheduler: RunLoop.main)
                .receive(on: RunLoop.main)
                .eraseToAnyPublisher()
        }
        
        // TODO: selectedDay Publisher and Subscriber
        
        
        /// ** MARK: Subscriber
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
        func fetchCalenderRecordInfo(for date: Date, type record: DropDownFilter, retryCount: Int = 0) async {
            print("date : \(date), record : \(record)")
            
            guard
                let year = Calendar.current.dateComponents([.year], from: date).year,
                let month = Calendar.current.dateComponents([.month], from: date).month else { return }
            let domain = await manager.domain
            guard var components = URLComponents(string: "\(domain ?? "domain")/api/records/calendar/\(year)/\(month)") else { return }
            
            if record != .all {
                components.queryItems = [URLQueryItem(name: "types", value: record.name)]
            }
            guard let accessToken = await manager.keyChain.read(account: "accessToken") else { return }
            
            guard let url = components.url else { return }
            var request = URLRequest(url: url)
            request.setValue("Bearer \(accessToken)", forHTTPHeaderField: "Authorization")
            
            URLSession.shared.dataTaskPublisher(for: request)
                .tryMap { output in
                    if let res = output.response as? HTTPURLResponse {
                        if res.statusCode == 403 {
                            throw URLError(.userAuthenticationRequired)
                        }else if !(200..<300).contains(res.statusCode) {
                            throw URLError(.badServerResponse)
                        }
                    }
                    return output.data
                }
                .decode(type: CalenderRecord.self, decoder: JSONDecoder())
                .receive(on: RunLoop.main)
                .sink(receiveCompletion: { completion in
                    switch completion {
                    case .finished:
                        break
                    case .failure(let error):
                        if (error as? URLError)?.code == .userAuthenticationRequired, retryCount < 1 {
                            Task {
                                let refresh = await self.manager.authorizationToken()
                                switch refresh {
                                    case .success(_):
                                        // 함수를 다시 호출한다.
                                        await self.fetchCalenderRecordInfo(for: date, type: record, retryCount: retryCount + 1)
                                    case .failure(let err):
                                        debugPrint("토큰 재발급 실패 : \(err)")
                                }
                            }
                        } else {
                            debugPrint("Calendar 조회 실패!! : \(error)")
                        }
                    }
                }, receiveValue: { [weak self] record in
                    self?.calendarRecord = record
                    print("calendarRecord : \(self?.calendarRecord)")
                })
                .store(in: &cancellables)
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
