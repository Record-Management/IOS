import SwiftUI

extension RecordSelectionView {
    class ViewModel: ObservableObject {
        @Published var isAlert: Bool = false
        @Published var originalRecord: Record = .none
        @Published var currentRecord: Record = .daily
        @Published var selectedRecord: Record = .none
        @Published var user: User = .init(statusCode: 0, code: "", message: "", data: nil)
        @Published var stage: Int?
        let useCase: UserUseCase
        
        init(useCase: UserUseCase) {
            self.useCase = useCase
        }
        
        @MainActor
        func getCurrentRecordType() async -> Record {
            do {
                let user = try await useCase.getUserData()
                switch user {
                    case .success(let res):
                        if let data = res.data {
                            self.user.data = data
                            self.stage = data.currentTreeStage
                            return Record.matchingMainRecordType(data.mainRecordType ?? "")
                        }
                    case .failure(let err):
                        debugPrint("User Error : \(err)")
                }
            } catch {
                debugPrint("getCurrentRecordType catch Error : \(error)")
            }
            return .none
        }
        
        // TODO: Stage 값 변환
        func getStage(receive: Int?) -> String {
            switch receive {
                case 1:
                    "MainStep01"
                case 2:
                    "MainStep02"
                case 3:
                    "MainStep03"
                case 4:
                    "MainStep04"
                default:
                    "MainStepNone"
            }
        }
    }
}
