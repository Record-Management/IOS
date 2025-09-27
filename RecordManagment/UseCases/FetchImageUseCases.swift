import SwiftUI

actor FetchImageUseCases {
    
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
}
