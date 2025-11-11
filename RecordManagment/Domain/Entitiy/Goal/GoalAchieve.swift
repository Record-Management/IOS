import Foundation

struct GoalAchieve: Decodable {
    let data: GoalData?
    let achieveCount: Int?
    
    enum CodingKeys: String, CodingKey {
        case data = "currentPeriod"
        case achieveCount = "cumulativeAchievementCount"
    }
}

struct GoalData: Decodable {
    let goalId: String
    let recordType: String
    let goalDays: Int
    let startDate: String
    let endDate: String
    let completedDays: Int
    let achievementRate: Int
    let treeStage: String
    let isInProgress: Bool
}
