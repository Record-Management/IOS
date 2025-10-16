import Foundation

protocol HabitRecordRepository {
    func createHabitRecord(form: HabitRequestBody) async -> Result<HabitDTO, LoginError>
}
