import Foundation

/// 사용자 정보 및 프로필 관리를 담당하는 레포지토리 인터페이스입니다.
protocol UserRepository: Sendable {
    /// 현재 로그인한 내 정보를 가져옵니다.
    func fetchMyInfo() async throws(UserRepositoryError) -> User
    
    /// 내 프로필 정보(닉네임, 생년월일 등)를 업데이트합니다.
    func updateProfile(form: [String : Any]) async throws(UserRepositoryError) -> User
}
