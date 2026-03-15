import Foundation

protocol SectionRepository {
    func onBoardingSection(dto: OnBoardingDTO) async -> Result<OnBoardingResponseDTO, LoginError>
    func goalReSelection(dto: GoalReSelectionRequestBody) async -> Result<GoalReSelectionDTO, LoginError>
}
