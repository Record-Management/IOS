import Foundation
import SwiftUI

@MainActor
@Observable
final class MainStore {
    // store
    let recordStore: RecordStore
    let userStore: UserStore
    let alertStore: AlertStore
    
    // 상태
    struct State {
        let showLoader: Bool = false
        var isFloatingExtends: Bool = false
        var goalData: GoalData? = nil
    }

    private(set) var state: State = .init()
    
    // 의존성
    private let scheduleRepository: ScheduleRepository
    private let goalRepository: GoalRepository
    
    init(
        recordStore: RecordStore,
        userStore: UserStore,
        alertStore: AlertStore,
        scheduleRepository: ScheduleRepository,
        goalRepository: GoalRepository
    ) {
        self.recordStore = recordStore
        self.userStore = userStore
        self.alertStore = alertStore
        self.scheduleRepository = scheduleRepository
        self.goalRepository = goalRepository
    }
    
    // intent
    enum Intent {
        case onAppear
        case setFloatingExtends(Bool)
        // Action
        case resetGoalButtonTapped
    }
    
    func send(_ intent: Intent) {
        switch intent {
        case .onAppear:
            Task { await fetchRecordLimit() }
            userStore.send(.onAppearCheckGoal)
            Task { await fetchGoalReport() }
        case .setFloatingExtends(let isExtends):
            state.isFloatingExtends = isExtends
        case .resetGoalButtonTapped:
            alertStore.send(.resetGoal(
                cancel: { /* dismiss */ },
                action: { [weak self] in
                    Task { await self?.resetGoal() }
                }
            ))
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
