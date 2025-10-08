import SwiftUI

extension RecordSelectionView {
    class ViewModel: ObservableObject {
        @Published var isAlert: Bool = false
        @Published var originalRecord: Record = .none
        @Published var currentRecord: Record = .daily
        @Published var selectedRecord: Record = .none
        let useCase: RecordUseCase
        
        init(useCase: RecordUseCase) {
            self.useCase = useCase
        }
        
        func getCurrentRecordType() async -> Record {
            do {
                let user = try await useCase.getUserData()
                switch user {
                    case .success(let res):
                        if let data = res.data {
                            return Record.matchingMainRecordType(data.mainRecordType)
                        }
                    case .failure(let err):
                        debugPrint("User Error : \(err)")
                }
            } catch {
                debugPrint("getCurrentRecordType catch Error : \(error)")
            }
            return .none
        }
    }
}
