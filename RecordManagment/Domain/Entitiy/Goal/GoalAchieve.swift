import Foundation

struct GoalAchieve: Decodable {
    let statusCode: Int
    let code: String
    let message: String
    let data: GoalData?
}

struct GoalData: Decodable {
    let currentPeriod: CurrentPeriodData?
    let cumulativeAchievementCount: Int
    let recentHistory: [RecentHistoryData?]
}

struct CurrentPeriodData: Decodable {
    let goalId: String
    let recordType: String
    let goalDays: Int
    let startDate: [Int]
    let endDate: [Int]
    let completedDays: Int
    let achievementRate: Int
    let treeStage: String
    let isInProgress: Bool?
}

struct RecentHistoryData: Decodable {
    let goalId: String
    let recordType: String
    let goalDays: Int
    let startDate: [Int]
    let endDate: [Int]
    let completedDays: Int
    let achievementRate: Int
    let finalTreeStage: String
    let status: String
}
