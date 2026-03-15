import Foundation
import Alamofire

struct RecordNetworkManager {
    private let keyChain: KeyChainManager
    private let intergrationManager: IntergrationManager
    private let imageService: FetchFileManager
    
    init(
        keyChain: KeyChainManager = .shared,
        intergrationManager: IntergrationManager = .shared,
        imageService: FetchFileManager = FetchFileManager()
    ) {
        self.keyChain = keyChain
        self.intergrationManager = intergrationManager
        self.imageService = imageService
    }
    
    // TODO: 기록 저장 비지니스 공통 함수
    func submitRecord<T, V>(
        method: RecordMethod,
        selectedImages: [PhotoTransfer],
        makeForm:@MainActor (_ imageUrls: [String]) -> T,
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
        let form = await makeForm(imageUrls)
        let data: Result<Response, LoginError> = method == .update ? await update(form) : await create(form)
        
        return data
    }
    
    // TODO: 기록 삭제 공통 함수
    func deleteRecord<T: Decodable>(recordId: String, type: String) async -> Result<T, LoginError> {
        guard let domain = await intergrationManager.manager.domain, let url = URL(string: "\(domain)/api/\(type)-records/\(recordId)") else {
            return .failure(.networkError(.invalidURL(url: "/api/\(type)-records")))
        }
        
        let result = await intergrationManager.withTokenRetry {
            guard let accessToken = keyChain.read(account: "accessToken") else {
                throw LoginError.notToken
            }
            
            let headers: HTTPHeaders = [
                "Authorization": "Bearer \(accessToken)",
                "Content-Type": "application/json"
            ]
            
            return try await AF.request(
                url,
                method: .delete,
                headers: headers
            )
            .serializingDecodable(T.self)
            .value
        }
        
        switch result {
            case .success(let data):
                return .success(data)
            case .failure(let error):
                return .failure(error)
        }
    }
    
    // TODO: 특정 날짜에 대한 records가져오기
    func fetchDateForDetailRecords(for date: Date, retryCount: Int = 0) async throws -> [IntergrationRecord] {
        let selectedDate = Date.onBoardingFormet(date)
        let domain = await intergrationManager.manager.domain
        guard let components = URLComponents(string: "\(domain ?? "domain")/api/records/date/\(selectedDate)") else { throw URLError(.badURL) }
        
        guard
            let url = components.url,
            let accessToken = keyChain.read(account: "accessToken")
        else { throw LoginError.notToken }
        
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
                debugPrint("특정 날짜 없데이트!! : \(date)")
                return records
            } else {
                return []
            }
            
        } catch let error where (error as? URLError)?.code == .userAuthenticationRequired && retryCount < 1 {
            let refresh = await self.intergrationManager.manager.authorizationToken()
            switch refresh {
                case .success(_):
                    do {
                        return try await fetchDateForDetailRecords(for: date, retryCount: retryCount + 1)
                    } catch {
                        debugPrint("Token 만료")
                        throw LoginError.refreshTokenExpired
                    }
                case .failure(let err):
                    debugPrint("토큰 재발급 실패 : \(err)")
            }
        } catch {
            debugPrint("Calendar Detail 조회 실패!! : \(error)")
            return []
        }
        
        throw URLError(.badServerResponse)
    }
}
