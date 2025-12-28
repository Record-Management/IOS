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

// MARK: OnBoarding Logging Extension ( 온보딩 )
extension AnalyticsManager {
    func logOnBoardingComplete(info: OnBoardingDTO?) {
        self.logEvent(
            "complete-onBoarding",
            params: [
                "info" : info
            ]
        )
    }
}
