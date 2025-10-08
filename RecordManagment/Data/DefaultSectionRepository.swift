import Foundation

final class DefaultSectionRepository: SectionRepository {
    let manager: SectionNetworkManager = .init()
    
    func onBoardingSection(dto: OnBoardingDTO) async -> Result<OnBoardingResponseDTO, LoginError> {
        return await manager.onBoardingComplete(onBoardingDTO: dto)
    }
}
