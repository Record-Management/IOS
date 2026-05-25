import Foundation

struct DailyRecordLimit: Decodable {
    let canCreateRecord: Bool
    let canCreateSchedule: Bool
    
    static var `default`: Self {
        .init(
            canCreateRecord: false,
            canCreateSchedule: false
        )
    }
}
