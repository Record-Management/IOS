import SwiftUI

protocol SectionOnBoardingUseCase {
    func onBoardingFetchingComplete(dto: OnBoardingDTO) async throws(OnBoardingError) -> Bool
    func reSelectionOnBoarding(dto: GoalReSelectionRequestBody) async throws(GoalRepositoryError) -> GoalResponse
}

struct DefaultSectionOnBoardingUseCase: SectionOnBoardingUseCase {
    private let repository: OnBoardingRepository
    private let goalRepository: GoalRepository
    
    init(
        repository: OnBoardingRepository,
        goalRepository: GoalRepository
    ) {
        self.repository = repository
        self.goalRepository = goalRepository
    }
    
    func onBoardingFetchingComplete(dto: OnBoardingDTO) async throws(OnBoardingError) -> Bool {
        do {
            let result = try await repository.onBoardingSection(dto: dto)
            if let data = result.data {
                return data.onboardingCompleted
            }
            return false
        } catch {
            Log.error(error.localizedDescription)
            return false
        }
    }
    
    func reSelectionOnBoarding(dto: GoalReSelectionRequestBody) async throws(GoalRepositoryError) -> GoalResponse {
        do {
            let result = try await goalRepository.goalReSelection(dto: dto)
            if let data = result.data {
                return data
            }
            throw GoalRepositoryError.goalReSelectionFailed
        } catch {
            Log.error(error.localizedDescription)
            throw .goalReSelectionFailed
        }
    }
}

