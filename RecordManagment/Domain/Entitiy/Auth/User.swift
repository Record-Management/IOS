import Foundation

struct User: Codable {
    let statusCode: Int
    let code: String
    let message: String
    let data: UserData?
    
    
    struct UserData: Codable {
        let id: String
        let mainRecordType: String
    }
}
