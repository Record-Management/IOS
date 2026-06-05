import SwiftUI
import Alamofire

actor FetchFileManager {
    private let keyChain: KeyChainManager
    private let intergrationManager: IntergrationManager
    
    init(keyChain: KeyChainManager = .shared, intergrationManager: IntergrationManager = .shared) {
        self.keyChain = keyChain
        self.intergrationManager = intergrationManager
    }
    
    // 서버로부터 이미지 가져오는 fetch 함수
    func fetchImage(url: URL) async -> Data {
        do {
            let (data, res) = try await URLSession.shared.data(for: URLRequest(url: url), delegate: nil)
            
            if let response = res as? HTTPURLResponse {
                switch response.statusCode {
                    case 200..<300:
                        return data
                    default:
                        throw URLError(.badServerResponse)
                }
            }
        } catch {
            debugPrint("data fetch Image Error : \(error)")
        }
        
        return Data()
    }
    
    // TODO: File Upload 통신 함수
    func fileUpload(files: [Data?], retryCount: Int = 0) async -> Result<[String], LoginError> {
        let domain = intergrationManager.domain
        guard let url = URL(string: "\(domain)/api/files/upload") else {
            return .failure(.networkError(.invalidURL(url: "\(domain)/api/files/upload")))
        }
        
        guard let accessToken = await keyChain.read(account: "accessToken") else {
            return .failure(.notToken)
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
                        fileName: "\(Int(Date().timeIntervalSince1970))_\(index).jpeg",
                    )
                }
            }
        },to: url, method: .post ,headers: headers)
        
        do {
            let response = try await intergrationManager.withTokenRetry {
                let res = try await request.serializingDecodable(FileResponse.self).value
                debugPrint(res)
                return res
            }
            if let access = response.data {
                return .success(access.fileUrls)
            }
            return .failure(.invaildRequest)
        } catch {
            return .failure(error)
        }
    }
}
