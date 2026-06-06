import Foundation

/// 온보딩 관련 비즈니스 로직을 처리하는 Repository 인터페이스입니다.
protocol OnBoardingRepository: Sendable {
    /// 온보딩 섹션에서 사용자가 입력한 정보를 서버에 전달하여 온보딩 과정을 진행합니다.
    func onBoardingSection(dto: OnBoardingDTO) async throws(OnBoardingError) -> OnBoardingResponseDTO
}
