import Foundation

/// 목표(Goal) 설정 및 달성 현황 리포트와 관련된 비즈니스 로직을 처리하는 레포지토리 인터페이스입니다.
protocol GoalRepository: Sendable {
    
    /// 특정 사용자의 목표 달성 리포트 정보를 조회합니다.
    /// - Parameter id: 사용자 또는 목표 식별자 (ID)
    /// - Returns: 목표 달성 현황 데이터 (`GoalAchieve`)
    func fetchReport(id: String) async throws(GoalRepositoryError) -> GoalAchieve
    
    /// 현재 진행 중인 목표를 강제로 완료하고 초기화합니다.
    func resetGoal() async throws(GoalRepositoryError)
}
