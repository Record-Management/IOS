import Foundation

final class AppReviewManager {
    static let shared = AppReviewManager()
    
    private let firstLaunchDateKey = "firstLaunchDate"
    private let hasCompletedRecordKey = "hasCompletedRecord"
    private let hasShownReviewAlertKey = "hasShownReviewAlert"
    
    private init() {}
    
    /// 앱 첫 실행 날짜를 기록합니다 (이미 기록되어 있다면 유지).
    func trackFirstLaunch() {
        if UserDefaults.standard.object(forKey: firstLaunchDateKey) == nil {
            UserDefaults.standard.set(Date(), forKey: firstLaunchDateKey)
        }
    }
    
    /// 사용자가 기록을 완료했음을 기록합니다.
    func markRecordCreated() {
        UserDefaults.standard.set(true, forKey: hasCompletedRecordKey)
    }
    
    /// 리뷰 요청 조건이 충족되었는지 확인하고, 충족되었다면 true를 반환합니다.
    /// 외부(UseCase 등)에서 이 값이 true일 때 UI 알림을 띄워 처리할 수 있습니다.
    /// 조건: 설치 후 1일 경과 && 최소 1회 기록 완료 && 한 번도 띄운 적 없음
    func shouldRequestReview() -> Bool {
        // 한 번이라도 알림을 띄우기로 한 적이 있다면 통과
        if UserDefaults.standard.bool(forKey: hasShownReviewAlertKey) {
            return false
        }
        
        guard let firstLaunchDate = UserDefaults.standard.object(forKey: firstLaunchDateKey) as? Date else {
            return false
        }
        
        let hasCompletedRecord = UserDefaults.standard.bool(forKey: hasCompletedRecordKey)
        let oneDayInSeconds: TimeInterval = 24 * 60 * 60
        let timePassed = Date().timeIntervalSince(firstLaunchDate)
        
        // 조건 체크: 1일 경과 및 기록 완료 여부
        if timePassed >= oneDayInSeconds && hasCompletedRecord {
            // 이번 반환 후 알림이 뜰 것이므로, flag 활성화
            UserDefaults.standard.set(true, forKey: hasShownReviewAlertKey)
            return true
        }
        
        return false
    }
    
#if DEBUG
    /// 디버그용: 앱 리뷰 조건을 강제로 만족시키도록 UserDefault를 조작합니다. (사용법: 테스트 버튼이나 onAppear 등에서 호출)
    func forceAppReviewConditionsForTesting() {
        let pastDate = Date().addingTimeInterval(-24 * 60 * 60 * 2) // 2일 전
        UserDefaults.standard.set(pastDate, forKey: firstLaunchDateKey)
        UserDefaults.standard.set(true, forKey: hasCompletedRecordKey)
        UserDefaults.standard.set(false, forKey: hasShownReviewAlertKey)
    }
    
    /// 디버그용: 앱 리뷰 관련 UserDefault 기록을 모두 초기화합니다.
    func resetAppReviewConditionsForTesting() {
        UserDefaults.standard.removeObject(forKey: firstLaunchDateKey)
        UserDefaults.standard.removeObject(forKey: hasCompletedRecordKey)
        UserDefaults.standard.removeObject(forKey: hasShownReviewAlertKey)
    }
#endif
}
