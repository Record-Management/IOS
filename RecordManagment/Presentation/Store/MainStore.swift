import Foundation
import SwiftUI

@MainActor
@Observable
final class MainStore {
    // store
    let recordStore: RecordStore
    let userStore: UserStore
    
    // 상태
    struct State {
        let showLoader: Bool = false
        var isFloatingExtends: Bool = false
        var checkGoal: Bool = false
        var goalData: GoalData? = nil
    }

    private(set) var state: State = .init()
    
    // 의존성
    private let scheduleRepository: ScheduleRepository
    private let goalRepository: GoalRepository
    
    init(
        recordStore: RecordStore,
        userStore: UserStore,
        scheduleRepository: ScheduleRepository,
        goalRepository: GoalRepository
    ) {
        self.recordStore = recordStore
        self.userStore = userStore
        self.scheduleRepository = scheduleRepository
        self.goalRepository = goalRepository
    }
    
    // intent
    enum Intent {
        case onAppear
        case setFloatingExtends(Bool)
        case setCheckGoal(Bool)
        // Action
        case resetGoalButtonTapped
    }
    
    func send(_ intent: Intent) {
        switch intent {
        case .onAppear:
            Task { await fetchRecordLimit() }
            state.checkGoal = checkCurrentGoal()
            guard state.checkGoal else { return }
            Task { await fetchGoalReport() }
        case .setFloatingExtends(let isExtends):
            state.isFloatingExtends = isExtends
        case .setCheckGoal(let val):
            state.checkGoal = val
        case .resetGoalButtonTapped:
            Task { await resetGoal() }
        }
    }
}

// MARK: - Private

extension MainStore {
    private func fetchRecordLimit() async {
        do {
            let limit = try await scheduleRepository.fetchRecordLimit()
            recordStore.send(.setLimit(limit))
        } catch {
            Log.error(error.localizedDescription)
        }
    }
    
    private func checkCurrentGoal() -> Bool {
        guard let user = userStore.state.user else {
            Log.info("유저 정보가 없습니다")
            return false
        }
        // 메인 기록, goalDay, 현재 나무 상태중 하나라도 nil 이라면 목표가 없음
        return  (user.mainRecordType != nil) ||
                (user.goalDays != nil) ||
                (user.currentTreeStage != nil)
    }
    
    private func fetchGoalReport() async {
        do {
            let result: GoalAchieve = try await goalRepository.fetchReport()
            state.goalData = result.data
        } catch {
            Log.error(error.localizedDescription)
        }
    }
    
    private func resetGoal() async {
        do {
            try await goalRepository.resetGoal()
            userStore.send(.fetchUserRecordType)
        } catch {
            Log.error(error.localizedDescription)
        }
    }
}
