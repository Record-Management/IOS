import SwiftUI

struct GoalReSelectionRequestBody: Encodable {
    let recordType: String
    let goalDays: Int
}

struct GoalReSelectionDTO: Decodable {
    let statusCode: Int
    let code: String
    let message: String
    let data: GoalResponse?
}

struct GoalResponse: Decodable {
    let goalId: String
    let recordType: String
    let goalDays: Int
    let startDate: String
    let endDate: String
    let message: String
}
