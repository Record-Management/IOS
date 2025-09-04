import SwiftUI
import Alamofire

enum LoginError: Error, Equatable {
    case accessTokenExpired   // 401
    case refreshTokenExpired   // 401
    case invaildRequest // 400
    case serverError    // 500
    case networkError(AFError) // Alamofire 에러
    case unknown(Error) // 기타
    
    static func == (lhs: LoginError, rhs: LoginError) -> Bool {
        switch (lhs, rhs) {
        case (.accessTokenExpired, .accessTokenExpired),
             (.refreshTokenExpired, .refreshTokenExpired),
             (.invaildRequest, .invaildRequest),
             (.serverError, .serverError):
            return true
        case (.networkError(let lErr), .networkError(let rErr)):
            return lErr.responseCode == rErr.responseCode
        case (.unknown, .unknown):
            return true // 그냥 동일 case면 true
        default:
            return false
        }
    }
}
