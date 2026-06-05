import SwiftUI

struct CalendarNetworkManager {
    private let keyChain: KeyChainManager
    private let intergrationManager: IntergrationManager
    
    init(keyChain: KeyChainManager = .shared, intergrationManager: IntergrationManager = .shared) {
        self.keyChain = keyChain
        self.intergrationManager = intergrationManager
    }
    
    func fetchCalenderRecordInfo(for date: Date, type record: DropDownFilter, retryCount: Int = 0) async throws -> CalendarRecord {
        guard
            let year = Calendar.current.dateComponents([.year], from: date).year,
            let month = Calendar.current.dateComponents([.month], from: date).month else { throw URLError(.badURL) }
        let domain = intergrationManager.domain
        guard var components = URLComponents(string: "\(domain)/api/calendar/\(year)/\(month)") else { throw URLError(.badURL) }

        if record != .all {
            components.queryItems = [URLQueryItem(name: "type", value: record.name)]
        }
        guard let accessToken = await keyChain.read(account: "accessToken") else {
            throw LoginError.notToken
        }
        guard let url = components.url else { throw URLError(.badURL) }
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
            
            let decodedRecord = try JSONDecoder().decode(CalendarRecord.self, from: data)
            return decodedRecord

        } catch let error where (error as? URLError)?.code == .userAuthenticationRequired && retryCount < 1 {
            do {
                _ = try await self.intergrationManager.service.authorizationToken()
                return try await self.fetchCalenderRecordInfo(for: date, type: record, retryCount: retryCount + 1)
            } catch {
                debugPrint("토큰 재발급 실패 : \(error)")
                _ = try? await intergrationManager.service.logout()
            }
        } catch {
            debugPrint("Calendar 조회 실패!! : \(error)")
        }
        
        throw URLError(.badServerResponse)
    }
}
