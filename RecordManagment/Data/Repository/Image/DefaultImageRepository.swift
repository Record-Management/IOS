import Foundation
import Alamofire

/// 이미지 업로드 및 다운로드 작업을 처리하는 레포지토리 구현체입니다.
struct DefaultImageRepository: ImageRepository {
    private let manager: IntergrationManager
    private let keyChain: KeyChainManager = .shared
    
    init(manager: IntergrationManager = .shared) {
        self.manager = manager
    }
    
    /// 서버로부터 이미지를 다운로드합니다.
    func fetch(_ url: URL) async throws(ImageRepositoryError) -> Data {
        do {
            let (data, res) = try await URLSession.shared.data(for: URLRequest(url: url), delegate: nil)
            
            if let response = res as? HTTPURLResponse {
                switch response.statusCode {
                case 200..<300:
                    return data
                default:
                    Log.error("fetchFailed Image, statusCode : \(response.statusCode)")
                    throw ImageRepositoryError.fetchFailed
                }
            }
            throw ImageRepositoryError.fetchFailed
        } catch {
            Log.error("Image Fetch Error: \(error.localizedDescription)")
            throw .fetchFailed
        }
    }
    
    /// 이미지를 멀티파트 폼 데이터 형식으로 업로드합니다.
    func upload(files: [Data?]) async throws(ImageRepositoryError) -> [String] {
        let url = DomainManager.Path.fileUpload.url
        guard let url = url else {
            throw .inVaildURL(url: DomainManager.Path.fileUpload.urlString)
        }
        
        guard let accessToken = await keyChain.read(account: "accessToken") else {
            throw .notToken
        }
        
        let headers: HTTPHeaders = [
            "Authorization": "Bearer \(accessToken)"
        ]
        
        let request = AF.upload(multipartFormData: { formData in
            files.enumerated().forEach { (index, fileData) in
                if let data = fileData {
                    formData.append(
                        data,
                        withName: "files",
                        fileName: "\(Int(Date().timeIntervalSince1970))_\(index).jpeg"
                    )
                }
            }
        }, to: url, method: .post, headers: headers)
        
        do {
            let fileUrls = try await manager.withTokenRetry {
                let response = try await request.serializingDecodable(FileResponse.self).value
                guard let urls = response.data?.fileUrls else {
                    throw LoginError.invaildRequest
                }
                return urls
            }
            return fileUrls
        } catch {
            Log.error("Image Upload Error: \(error.localizedDescription)")
            throw .uploadFailed
        }
    }
}
