
import SwiftUI
import Combine

class RecordService: ObservableObject {
    static let shared = RecordService()
    
    @Published var detailRecords: [DailyResponse] = []
    @Published var selectedDate: Date? = .now

    private var cancellables = Set<AnyCancellable>()
    private var keyChain: KeyChainManager = .shared
    private let common: IntergrationManager = .shared

    private init() {
        $selectedDate
            .prepend(selectedDate)
            .compactMap { $0 }
            .removeDuplicates()
            .sink { [weak self] date in
                Task {
                    await self?.fetchDateForDetailRecords(for: date)
                }
            }
            .store(in: &cancellables)
    }

    @MainActor
    func fetchDateForDetailRecords(for date: Date, retryCount: Int = 0) async {
        let selectedDate = Date.onBoardingFormet(date)
        let domain = await common.manager.domain
        guard let components = URLComponents(string: "\(domain ?? "domain")/api/records/date/\(selectedDate)") else { return }
        
        guard
            let url = components.url,
            let accessToken = keyChain.read(account: "accessToken")
        else { return }
        
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
            
            let decodedData = try JSONDecoder().decode(CalendarDetail.self, from: data)
            
            if let records = decodedData.data?.records {
                self.detailRecords = records
            } else {
                self.detailRecords = []
            }
            
        } catch let error where (error as? URLError)?.code == .userAuthenticationRequired && retryCount < 1 {
            let refresh = await self.common.manager.authorizationToken()
            switch refresh {
                case .success(_):
                    await self.fetchDateForDetailRecords(for: date, retryCount: retryCount + 1)
                case .failure(let err):
                    debugPrint("토큰 재발급 실패 : \(err)")
            }
        } catch {
            debugPrint("Calendar Detail 조회 실패!! : \(error.localizedDescription)")
            self.detailRecords = []
        }
    }
}
