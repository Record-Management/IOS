import SwiftUI

protocol MainSheetRepository {
    func fetchCompletionHabit(_ isCompleted: Bool ,recordId: String) async -> Result<HabitDTO, LoginError>
}
