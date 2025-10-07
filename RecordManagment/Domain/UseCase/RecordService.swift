
import SwiftUI
import Combine

class RecordService: ObservableObject {
    static let shared = RecordService()
    
    @Published var detailRecords: [IntergrationRecord] = []
    @Published var selectedDate: Date? = .now

    private var cancellables = Set<AnyCancellable>()
    let refreshSubject = PassthroughSubject<Void, Never>() // records update를 위한 Publisher
    private var keyChain: KeyChainManager = .shared
    private let common: IntergrationManager = .shared
    let imageService: FetchImageUseCases = .init()

    private init() {
        let dateChangePublisher = $selectedDate
            .compactMap { $0 }
            .removeDuplicates()

        let refreshPublisher = refreshSubject
            .compactMap { [weak self] in
                return self?.selectedDate
            }

        Publishers.Merge(dateChangePublisher, refreshPublisher)
            .prepend(selectedDate ?? .now)
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
                print("특정 날짜 없데이트!! : \(date)")
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
            debugPrint("Calendar Detail 조회 실패!! : \(error)")
            self.detailRecords = []
        }
    }
    
    
    // TODO: 기록 저장 비지니스 공통 함수
    func submitRecord<T, V>(
        isEditing: Bool,
        selectedImages: [PhotoTransfer],
        makeForm: (_ imageUrls: [String]) -> T,
        create: (T) async -> Result<V, LoginError>,
        update: (T) async -> Result<V, LoginError>
    ) async -> Result<V, LoginError> {
        typealias RequestBody = T
        typealias Response = V
        
        var imageUrls: [String] = []
        let hasFile = !selectedImages.isEmpty
        
        if hasFile {
            let imageData: [Data?] = selectedImages.map{
                $0.image.jpegData(compressionQuality: 0.8)
            }
            
            let result = await imageService.fileUpload(files: imageData)
            
            switch result {
                case .success(let urls):
                    imageUrls = urls
                case .failure(let failure):
                    return .failure(failure)
            }
        }
        let form = makeForm(imageUrls)
        print(form)
        let data: Result<Response, LoginError> = isEditing ? await update(form) : await create(form)
        
        return data
    }
}
