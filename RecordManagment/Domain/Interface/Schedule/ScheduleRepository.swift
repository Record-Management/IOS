import Foundation

/// 일정 기록 관련 CRUD http 통신 프로토콜입니다.
protocol ScheduleRepository {
    /// 일정 기록 생성
    func create(form: ScheduleFormat) async throws(ScheduleRepositoryError) -> ScheduleResponse
    /// 일정 기록 수정
    func update(scheduleId: String, form: ScheduleFormat) async throws(ScheduleRepositoryError) -> ScheduleResponse
    /// 일정 기록 삭제
    func delete(scheduleId: String) async throws(ScheduleRepositoryError)
    /// 일정 기록 단건 조회
    func fetch(scheduleId: String) async throws(ScheduleRepositoryError) -> ScheduleResponse
    /// 일정 기록, record기록 횟수 fetch
    func fetchRecordLimit() async throws(ScheduleRepositoryError) -> DailyRecordLimit
}
