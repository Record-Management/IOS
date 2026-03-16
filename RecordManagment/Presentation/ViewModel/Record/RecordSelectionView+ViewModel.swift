import SwiftUI

extension RecordSelectionView {
    @MainActor
    final class ViewModel: ObservableObject {
        @Published var isAlert: Bool = false
        @Published var originalRecord: Record = .none
        @Published var currentRecord: Record = .daily
        @Published var selectedRecord: Record = .none
        @Published var user: User = .init(statusCode: 0, code: "", message: "", data: nil)
        @Published var stage: String?
        let useCase: UserUseCase
        
        init(useCase: UserUseCase) {
            self.useCase = useCase
        }
        
        func getCurrentRecordType() async -> Record {
            do {
                let user = try await useCase.getUserData()
                switch user {
                    case .success(let res):
                        if let data = res.data {
                            self.user.data = data
                            self.stage = data.currentTreeStage
                            let type = Record.matchingMainRecordType(data.mainRecordType ?? "")
                            self.currentRecord = type
                            self.originalRecord = type
                            return type
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

// MARK: Stage 변수 관련 확장
extension RecordSelectionView.ViewModel {
    // TODO: Stage 값 변환
    func getStage() -> String {
        switch stage {
            case "STAGE_1":
                "MainStep01"
            case "STAGE_2":
                "MainStep02"
            case "STAGE_3":
                "MainStep03"
            case "STAGE_4":
                "MainStep04"
            default:
                "MainStepNone"
        }
    }
    
    // TODO: Stage 값 Matching for Server
    func matchingStage(isTutorial: Bool) -> SeedStep {
        switch stage {
            case "STAGE_1":
                return .stage1
            case "STAGE_2":
                return .stage2
            case "STAGE_3":
                return .stage2
            case "STAGE_4":
                return .stage3
            default:
                guard isTutorial else { return .tutorial }
                return .none
        }
    }
}
