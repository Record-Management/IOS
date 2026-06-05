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
        
        // Goals (목표)
        case achievementReport
        
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
            case .achievementReport:
                return "\(DomainManager.baseURL)/api/goals/achievement/report"
            }
        }
        
        /// Alamofire나 URLSession 통신에 즉시 사용할 수 있도록 URL 객체를 제공합니다.
        var url: URL? {
            URL(string: urlString)
        }
    }
}
