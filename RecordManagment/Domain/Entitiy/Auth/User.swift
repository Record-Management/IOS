import Foundation

struct User: Codable, Sendable {
    let statusCode: Int
    let code: String
    let message: String
    var data: UserData?
}

struct UserData: Codable, Equatable, Sendable {
    let id: String
    let name: String
    let nickname: String
    let email: String?
    let socialType: String
    let mainRecordType: String?
    let birthDate: [Int]?
    let goalDays: Int?
    let currentTreeStage: String?
    let onboardingCompleted: Bool
}
