import Foundation

protocol OnBoardingRepository {
    func onBoardingSection(dto: OnBoardingDTO) async -> Result<OnBoardingResponseDTO, LoginError>
    func goalReSelection(dto: GoalReSelectionRequestBody) async -> Result<GoalReSelectionDTO, LoginError>
}
