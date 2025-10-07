import SwiftUI

extension RecordSelectionView {
    class ViewModel: ObservableObject {
        @Published var isAlert: Bool = false
        @Published var currentRecord: Record = .daily
        @Published var selectedRecord: Record = .none
        
        let common: IntergrationManager = .shared
        
        func getCurrentRecordType() async -> Record {
            let domain = await common.manager.domain
            guard let url = URL(string: "\(domain ?? "domain")/api/users/me") else { return .none }
            var request = URLRequest(url: url)
            guard let accessToken = await common.manager.keyChain.read(account: "accessToken") else { return .none }
            request.setValue("Bearer \(accessToken)", forHTTPHeaderField: "Authorization")
            
            let user = await common.withTokenRetry {
                let (data, _) = try await URLSession.shared.data(for: request, delegate: nil)
                let decode = try JSONDecoder().decode(User.self, from: data)
                
                return decode
            }
            
            switch user {
                case .success(let res):
                    if let data = res.data {
                        return Record.matchingMainRecordType(data.mainRecordType)
                    }
                case .failure(let err):
                    debugPrint("User Error : \(err)")
            }
            
            return .none
        }
    }
}
