import SwiftUI

@Observable
final class UserStore {
    struct State {
        var user: UserData? = nil
        var stage: String = "MainStepNone"
        var originalRecord: SeedType = .none
        var currentRecord: SeedType = .daily
        var selectedRecord: SeedType = .none
    }
    
    private(set) var state = State()
    private let userRepository: UserRepository
    
    init(userRepository: UserRepository) {
        self.userRepository = userRepository
    }
    
    enum Intent {
        case fetchUserRecordType
        case setCurrentRecord(SeedType)
        case updateStage(String)
    }
    
    func send(_ intent: Intent) {
        switch intent {
        case .fetchUserRecordType:
            Task { await getCurrentRecordType() }
        case .setCurrentRecord(let type):
            state.currentRecord = type
        case .updateStage(let stage):
            state.stage = stage
        }
    }
    
    private func getCurrentRecordType() async {
        do {
            let res = try await userRepository.fetchMyInfo()
            if let data = res.data {
                state.user = data
                state.stage = data.currentTreeStage ?? "MainStepNone"
                let type = SeedType.matchingMainRecordType(data.mainRecordType ?? "")
                state.currentRecord = type
                state.originalRecord = type
            }
        } catch {
            Log.error("getCurrentRecordType Error : \(error)")
        }
    }
    
    func matchingStage(isTutorial: Bool) -> SeedStep {
        switch state.stage {
        case "STAGE_1": return .stage1
        case "STAGE_2": return .stage2
        case "STAGE_3": return .stage2
        case "STAGE_4": return .stage3
        default:
            guard isTutorial else { return .tutorial }
            return .none
        }
    }
}
