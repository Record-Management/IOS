import Foundation

/// 애플 로그인 시 획득하는 사용자 인증 정보 데이터를 담는 구조체입니다.
public struct AuthUserData: Sendable {
    public var token: String
    public var oAuthId: String
    
    public init(token: String = "", oAuthId: String = "") {
        self.token = token
        self.oAuthId = oAuthId
    }
}
