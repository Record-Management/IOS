import Foundation


/// 습관 기록 상위 인터페이스입니다
/// 습관 기록의 isCompleted를 조회하는 함수가 추가적으로 포합됩니다.
protocol HabitRepository: RecordRepository {
    func fetchCompletionHabit(_ isCompleted: Bool ,recordId: String) async throws(RecordRepositoryError) -> HabitDTO
}
