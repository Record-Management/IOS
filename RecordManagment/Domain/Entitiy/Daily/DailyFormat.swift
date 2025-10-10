import Foundation

/// ** DailyRecord Form Data 형식
struct DailyFormat: Encodable {
    let emotion: String
    let content: String
    var imageUrls: [String]
    let recordDate: String
    let recordTime: String
}
