import Foundation

/// 일정 기록 관련 CRUD http 통신 프로토콜입니다.
protocol ScheduleRepository {
    func create(form: ScheduleFormat) async throws(ScheduleRepositoryError)
}
