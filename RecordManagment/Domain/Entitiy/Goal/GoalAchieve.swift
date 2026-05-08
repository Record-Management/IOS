import Foundation

struct GoalAchieve: Decodable {
    let statusCode: Int
    let code: String
    let message: String
    let data: GoalData?
}

struct GoalData: Decodable, Hashable, Equatable {
    let currentPeriod: CurrentPeriodData?
    let cumulativeAchievementCount: Int
    let recentHistory: [RecentHistoryData?]
}

struct CurrentPeriodData: Decodable, Hashable, Equatable {
    let goalId: String
    let recordType: String
    let goalDays: Int
    let startDate: [Int]
    let endDate: [Int]
    let completedDays: Int
    let achievementRate: Double
    let treeStage: String
    let isInProgress: Bool?
}

struct RecentHistoryData: Decodable, Hashable, Equatable {
    let goalId: String
    let recordType: String
    let goalDays: Int
    let startDate: [Int]
    let endDate: [Int]
    let completedDays: Int
    let achievementRate: Double
    let finalTreeStage: String
    let status: String
}
