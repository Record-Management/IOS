import Foundation

struct ExerciseBody: Codable {
    let exerciseType: String
    let caloriesBurned: Int?
    let exerciseTimeMinutes: Int?
    let stepCount: Int?
    let weight: Int?
    let dailyNote: String
    var imageUrls: [String]
    let recordDate: String
    let recordTime: String
}

struct ExerciseDTO: Codable {
    let code: String
    let statusCode: Int
    let message: String
    let data: ExerciseResponse?
}
