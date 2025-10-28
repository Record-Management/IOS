import Foundation
import SwiftUI

///** SocialLogin을 위해 서버에 보내기 위한 Request Body 타입
enum SocialType: String, Codable {
    case kakao
    case apple
    
    var imageName: String {
        rawValue.uppercased() + "Account"
    }
    
    static func matchingType(_ str: String) -> SocialType {
        switch str {
            case "KAKAO":
                .kakao
            case "APPLE":
                .apple
            default:
                .kakao
        }
    }
}

/// ** Login 성공 후 받을 DTO
struct SocialLoginResponseDTO: Codable {
    let statusCode: Int?
    let code: String
    let message: String
    let data: DataResponse?
    
    enum CodingKeys: String, CodingKey {
        case statusCode
        case code
        case message
        case data
    }
}

/// ** user의 id, name을 가진 객체 data
struct DataResponse: Codable {
    let accessToken: String
    let refreshToken: String
    let user: UserResponse?
    let newUser: Bool?
    
    enum CodingKeys: String, CodingKey {
        case accessToken
        case refreshToken
        case user
        case newUser
    }
}

struct UserResponse: Codable {
    let id: String
    let name: String
    let email: String?
    let socialType: String?
    let createdAt: [Int]?
    let onboardingCompleted: Bool
    
    enum CodingKeys: String, CodingKey {
        case id
        case name
        case email
        case socialType
        case createdAt
        case onboardingCompleted
    }
}

/// ** 로그아웃 DTO
struct LogoutDTO: Codable {
    let statusCode: Int
    let code: String
    let message: String
}
