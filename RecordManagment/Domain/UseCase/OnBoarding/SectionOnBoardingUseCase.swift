import SwiftUI

protocol SectionOnBoardingUseCase {
    func onBoardingFetchingComplete(dto: OnBoardingDTO) async -> Result<OnBoardingResponseDTO, LoginError>
    func reSelectionOnBoarding(dto: GoalReSelectionRequestBody) async -> Result<GoalReSelectionDTO, LoginError>
}

struct DefaultSectionOnBoardingUseCase: SectionOnBoardingUseCase {
    private let repository: SectionRepository
    
    init(repository: SectionRepository) {
        self.repository = repository
    }
    
    func onBoardingFetchingComplete(dto: OnBoardingDTO) async -> Result<OnBoardingResponseDTO, LoginError> {
        return await repository.onBoardingSection(dto: dto)
    }
    
    func reSelectionOnBoarding(dto: GoalReSelectionRequestBody) async -> Result<GoalReSelectionDTO, LoginError> {
        return await repository.goalReSelection(dto: dto)
    }
}

