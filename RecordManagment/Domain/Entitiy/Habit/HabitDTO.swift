import Foundation

struct HabitDTO: Decodable {
    let statusCode: Int
    let code: String
    let message: String
    let data: HabitResponse?
}
