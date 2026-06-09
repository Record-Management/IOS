import Foundation
import Observation
import SwiftUI

/// 알림  `Store`
@MainActor
@Observable
final class NotificationStore {
    
    let recordStore: RecordStore
    let userStore: UserStore
    
    // 뷰가 관찰할 상태(State)
    struct State {
        var notices: [Notice] = []
        var data: NotificationData? = nil
    }

    private(set) var state = State()

    // 의존성
    private let repository: NotificationRepository

    init(
        recordStore: RecordStore,
        userStore: UserStore,
        repository: NotificationRepository
    ) {
        self.recordStore = recordStore
        self.userStore = userStore
        self.repository = repository
    }
    
    enum Intent {
        case setNotices([Notice])
        case onAppear
        case onDisAppear
    }
    
    func send(_ intent: Intent) {
        switch intent {
        case .onAppear:
            Task { await fetchNotifications() }
        case .onDisAppear:
            Task { await updateCurrentNotices() }
        case .setNotices(let notices):
            state.notices = notices
        }
    }
}

// MARK: - Private Actions

extension NotificationStore {
    private func fetchNotifications() async {
        do {
            let result = try await repository.fetchNotifications()
            state.data = result.data
        } catch {
            Log.error(error.localizedDescription)
        }
    }
    
    private func updateCurrentNotices() async {
        do {
            try await repository.updateNotification()
        } catch {
            Log.error(error.localizedDescription)
        }
    }
}
