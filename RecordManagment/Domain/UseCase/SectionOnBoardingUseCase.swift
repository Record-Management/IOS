import SwiftUI

final class SectionOnBoardingUseCase {
    let repository: SectionRepository
    
    init(repository: SectionRepository) {
        self.repository = repository
    }
    
    func onBoardingFetchingComplete(dto: OnBoardingDTO) async -> Result<OnBoardingResponseDTO, LoginError>{
        return await repository.onBoardingSection(dto: dto)
    }
}
