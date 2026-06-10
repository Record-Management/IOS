import Foundation

/// 목표(Goal) 설정 및 조회 네트워크 통신에 사용되는 커스텀 에러 타입입니다.
enum GoalRepositoryError: Error, Sendable {
    /// 유효하지 않은 URL
    case inVaildURL(url: String)
    /// 토큰이 존재하지 않음
    case notToken
    /// 목표 달성 리포트 조회 실패
    case goalReportFetchFailed
    /// 목표 강제 완료/초기화 실패
    case goalResetFailed
    /// 목표 재설정 실패
    case goalReSelectionFailed
    /// 알 수 없는 기타 에러
    case unknown(Error)
}
