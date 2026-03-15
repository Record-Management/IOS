import Foundation

protocol HabitRecordRepository {
    func createHabitRecord(form: HabitRequestBody) async -> Result<HabitDTO, LoginError>
    func updateHabitRecord(form: HabitRequestBody, recordId: String) async -> Result<HabitDTO, LoginError>
    func deleteHabitRecord(recordId: String) async -> Result<HabitDTO, LoginError>
}
