import Foundation

/// 앱 전체의 백엔드 서버 도메인 주소 및 모든 API 엔드포인트 경로를 한곳에서 안전하게 관리하는 열거형입니다.
enum DomainManager {
    
    /// Xcode Configuration(.xcconfig)에 맞춰 가져오는 Base URL (최초 호출 시 1회만 파싱 및 캐싱)
    static let baseURL: String = {
        #if DEBUG
        let urlKey = "SERVER_QA_URL"
        #else
        let urlKey = "SERVER_DEV_URL"
        #endif
        
        guard let urlString = Bundle.main.infoDictionary?[urlKey] as? String else {
            fatalError("🚨 Xcode Config에서 \(urlKey) 설정을 찾을 수 없습니다.")
        }
        return urlString
    }()
    
    /// 모든 API 엔드포인트의 경로를 정의하는 열거형
    enum Path {
        // Auth
        case socialLogin
        case refresh
        case logout
        case withdrawal
        // Calendar (Year: Int, Month: Int)
        case totalCalendar(year: Int, month: Int)
        // Calendar (date: "2025-01-07")
        case detailCalendar(date: String)
        // 하루 기록 ( C R U D )
        case dailyCreate
        case dailyUpdate(recordId: String)
        case dailyDelete(recordId: String)
        // 운동 기록 ( C R U D )
        case exerciseCreate
        case exerciseUpdate(recordId: String)
        case exerciseDelete(recordId: String)
        // 습관 기록 ( C R U D )
        case habitCreate
        case habitUpdate(recordId: String)
        case habitDelete(recordId: String)
        case habitCompletion(recordId: String)
        // 일정 기록 ( C R U D )
        case scheduleCreate
        case scheduleDetail(scheduleId: String)
        case dailyRecordLimit
        // Onboarding
        case onboardingComplete
        // Goals (목표)
        case goalReSelection
        case currentGoal
        case achievementReport
        case forceCompleteGoal
        // User
        case usersMe
        case usersProfile
        // Notification
        case notificationsHistory
        case readNotificationHistory
        case notificationsSettings
        // Files
        case fileUpload
        
        // 만약 동적으로 URL 경로가 바뀌는 케이스가 있다면 연관값(Associated Value)도 활용 가능합니다.
        /// 최종 도메인 주소와 엔드포인트 경로가 결합된 Full URL String을 반환합니다.
        var urlString: String {
            switch self {
            case .socialLogin:
                return "\(DomainManager.baseURL)/api/auth/social-login"
            case .refresh:
                return "\(DomainManager.baseURL)/api/auth/refresh"
            case .logout:
                return "\(DomainManager.baseURL)/api/auth/logout"
            case .withdrawal:
                return "\(DomainManager.baseURL)/api/users/withdrawal"
            case .totalCalendar(let year, let month):
                return "\(DomainManager.baseURL)/api/calendar/\(year)/\(month)"
            case .detailCalendar(let date):
                return "\(DomainManager.baseURL)/api/calendar/\(date)"
            case .dailyCreate:
                return "\(DomainManager.baseURL)/api/daily-records"
            case .dailyUpdate(let recordId):
                return "\(DomainManager.baseURL)/api/daily-records/\(recordId)"
            case .dailyDelete(let recordId):
                return "\(DomainManager.baseURL)/api/daily-records/\(recordId)"
            case .exerciseCreate:
                return "\(DomainManager.baseURL)/api/exercise-records"
            case .exerciseUpdate(let recordId):
                return "\(DomainManager.baseURL)/api/exercise-records/\(recordId)"
            case .exerciseDelete(let recordId):
                return "\(DomainManager.baseURL)/api/exercise-records/\(recordId)"
            case .habitCreate:
                return "\(DomainManager.baseURL)/api/habit-records"
            case .habitUpdate(let recordId):
                return "\(DomainManager.baseURL)/api/habit-records/\(recordId)"
            case .habitDelete(let recordId):
                return "\(DomainManager.baseURL)/api/habit-records/\(recordId)"
            case .habitCompletion(let recordId):
                return "\(DomainManager.baseURL)/api/habit-records/\(recordId)/completion"
            case .scheduleCreate:
                return "\(DomainManager.baseURL)/api/schedule-records"
            case .scheduleDetail(let scheduleId):
                return "\(DomainManager.baseURL)/api/schedule-records/\(scheduleId)"
            case .dailyRecordLimit:
                return "\(DomainManager.baseURL)/api/daily-records/creation-limits"
            case .onboardingComplete:
                return "\(DomainManager.baseURL)/api/users/onboarding/complete"
            case .goalReSelection:
                return "\(DomainManager.baseURL)/api/goals/new"
            case .currentGoal:
                return "\(DomainManager.baseURL)/api/goals/current"
            case .achievementReport:
                return "\(DomainManager.baseURL)/api/goals/achievement/report"
            case .forceCompleteGoal:
                return "\(DomainManager.baseURL)/api/goals/current/force-complete"
            case .usersMe:
                return "\(DomainManager.baseURL)/api/users/me"
            case .usersProfile:
                return "\(DomainManager.baseURL)/api/users/profile"
            case .readNotificationHistory:
                return "\(DomainManager.baseURL)/api/notifications/mark-all-read"
            case .notificationsHistory:
                return "\(DomainManager.baseURL)/api/notifications/history"
            case .notificationsSettings:
                return "\(DomainManager.baseURL)/api/notifications/settings"
            case .fileUpload:
                return "\(DomainManager.baseURL)/api/files/upload"
            }
        }
        
        /// Alamofire나 URLSession 통신에 즉시 사용할 수 있도록 URL 객체를 제공합니다.
        var url: URL? {
            URL(string: urlString)
        }
    }
}
