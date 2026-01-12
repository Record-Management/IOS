import FirebaseAnalytics

final class AnalyticsManager {
    static var shared: AnalyticsManager = .init()
    
    private init() {}
    
    func logEvent(_ name: String, params: [String : Any]? = nil) {
        Analytics.logEvent(name, parameters: params)
    }
    
    func setUserId(_ userId: String?) {
        Analytics.setUserID(userId)
    }
    
    func setUserProperty(_ value: String?, forName: String) {
        Analytics.setUserProperty(value, forName: forName)
    }
}

// MARK: Auth Logging Extension (로그인, 회원가입, 로그아웃, 탈퇴)
extension AnalyticsManager {
    func logLogin(method: String, userId: String?) {
        Analytics.logEvent(
            AnalyticsEventLogin,
            parameters: [
                AnalyticsParameterMethod : method
            ]
        )
        
        if let userId {
            self.setUserId(userId)
        }
    }
    
    func logSignUp(method: String, userId: String?) {
        Analytics.logEvent(
            AnalyticsEventSignUp,
            parameters: [
                AnalyticsParameterMethod : method
            ]
        )
        
        if let userId {
            self.setUserId(userId)
        }
    }
    
    func logLogout() {
        AnalyticsManager.shared.logEvent("logout", params: nil)
        AnalyticsManager.shared.setUserId(nil)
    }
    
    func logWithdraw() {
        AnalyticsManager.shared.logEvent("withdraw", params: nil)
        AnalyticsManager.shared.setUserId(nil)
    }
}

// MARK: OnBoarding, Goal Reset Logging Extension ( 온보딩 , 목표 재설정 )
extension AnalyticsManager {
    func logOnBoardingComplete(info: OnBoardingDTO?) {
        self.logEvent(
            "complete-onBoarding",
            params: [
                "info" : info
            ]
        )
    }
    
    func logGoalResetComplete(_ type: String, goalDays: Int) {
        self.logEvent(
            "goal_reset",
            params: [
                "type" : type,
                "goalDays" : goalDays
            ]
        )
    }
}

// MARK: Record Logging Extension ( 하루, 운동, 습관 )
extension AnalyticsManager {
    func logDailyCancel() {
        self.logEvent("write_daily_record_cancel")
    }
    
    func logExerciseCancel() {
        self.logEvent("write_exercise_record_cancel")
    }
    
    func logHabitCancel() {
        self.logEvent("write_habit_record_cancel")
    }
    
    // TODO: 작성 시작 관련 함수
    func logRecordStart(name: String) {
        self.logEvent("write_\(name)_record_start")
    }
    
    // TODO: 작성 완료 관련 함수
    func logRecordComplete(name: String) {
        self.logEvent("write_\(name)_record_complete")
    }
}
