import Foundation

protocol UserRepository {
    // 현재 내 정보 가져오기
    func fetchMyInfo() async throws -> Result<User, LoginError>
}
