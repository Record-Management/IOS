import Foundation

protocol SectionRepository {
    func onBoardingSection(dto: OnBoardingDTO) async -> Result<OnBoardingResponseDTO, LoginError>
}
