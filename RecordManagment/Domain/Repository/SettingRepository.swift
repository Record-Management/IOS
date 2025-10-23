import Foundation

protocol SettingRepository {
    func updateProfile(form: [String : Any]) async throws -> Result<User, LoginError>
}
