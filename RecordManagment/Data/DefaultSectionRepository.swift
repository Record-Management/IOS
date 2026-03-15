import Foundation

struct DefaultSectionRepository: SectionRepository {
    private let manager: SectionNetworkManager
    
    init(manager: SectionNetworkManager = .init()) {
        self.manager = manager
    }
    
    func onBoardingSection(dto: OnBoardingDTO) async -> Result<OnBoardingResponseDTO, LoginError> {
        return await manager.onBoardingComplete(onBoardingDTO: dto)
    }
    
    func goalReSelection(dto: GoalReSelectionRequestBody) async -> Result<GoalReSelectionDTO, LoginError> {
        return await manager.goalReSelectionOnBoardingComplete(dto: dto)
    }
}
