import Foundation
import Alamofire

/// 목표(Goal) 설정 및 달성 현황 리포트와 관련된 비동기 네트워크 작업을 처리하는 레포지토리 구현체입니다.
struct DefaultGoalRepository: GoalRepository {
    private let manager: IntergrationManager
    private let keyChain: KeyChainManager = .shared
    
    init(manager: IntergrationManager) {
        self.manager = manager
    }
    
    /// 특정 사용자의 목표 달성 리포트 정보를 조회합니다.
    func fetchReport(id: String) async throws(GoalRepositoryError) -> GoalAchieve {
        let url = DomainManager.Path.achievementReport.url
        guard let url = url else {
            throw .inVaildURL(url: DomainManager.Path.achievementReport.urlString)
        }
        
        guard let accessToken = await keyChain.read(account: "accessToken") else {
            throw .notToken
        }

        let headers: HTTPHeaders = [
            "Authorization": "Bearer \(accessToken)",
            "userId": id
        ]
        
        let task = AF.request(
            url,
            method: .get,
            headers: headers
        )
        
        do {
            let result = try await manager.withTokenRetry {
                let response = try await task.serializingDecodable(GoalAchieve.self).value
                return response
            }
            return result
        } catch {
            Log.error(error.localizedDescription)
            throw .goalReportFetchFailed
        }
    }
    
    /// 현재 진행 중인 목표를 강제로 완료하고 초기화합니다.
    func resetGoal() async throws(GoalRepositoryError) {
        let url = DomainManager.Path.forceCompleteGoal.url
        guard let url = url else {
            throw .inVaildURL(url: DomainManager.Path.forceCompleteGoal.urlString)
        }
        
        guard let accessToken = await keyChain.read(account: "accessToken") else {
            throw .notToken
        }

        let headers: HTTPHeaders = [
            "Authorization": "Bearer \(accessToken)"
        ]
        
        let task = AF.request(
            url,
            method: .patch,
            headers: headers
        )
        
        do {
            _ = try await manager.withTokenRetry {
                _ = try await task.serializingData().value
                return true
            }
        } catch {
            Log.error(error.localizedDescription)
            throw .goalResetFailed
        }
    }
}
