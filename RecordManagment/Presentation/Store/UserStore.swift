import SwiftUI

@Observable
final class UserStore {
    struct State {
        var user: UserData? = nil
        var stage: String = "MainStepNone"
        var originalRecord: SeedType = .none
        var currentRecord: SeedType = .daily
        var selectedRecord: SeedType = .none
        var checkGoal: Bool = false
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
        case setCheckGoal(Bool)
        case onAppearCheckGoal
    }
    
    func send(_ intent: Intent) {
        switch intent {
        case .fetchUserRecordType:
            Task { await getCurrentRecordType() }
        case .setCurrentRecord(let type):
            state.currentRecord = type
        case .updateStage(let stage):
            state.stage = stage
        case .setCheckGoal(let val):
            state.checkGoal = val
        case .onAppearCheckGoal:
            state.checkGoal = checkCurrentGoal()
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
                state.checkGoal = checkCurrentGoal()
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
    
    private func checkCurrentGoal() -> Bool {
        guard let user = state.user else {
            Log.info("유저 정보가 없습니다")
            return false
        }
        let check = (user.mainRecordType != nil) &&
                    (user.goalDays != nil) &&
                    (user.currentTreeStage != nil)
        Log.info("checkGoal : \(check)")
        // 메인 기록, goalDay, 현재 나무 상태가 모두 존재할 때 목표가 있음
        return check
    }
}
