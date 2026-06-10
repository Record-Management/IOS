import Foundation

/// 기록(Record)에 대한 표준 CUD 작업을 정의하는 레포지토리 프로토콜입니다.
/// Read의 경우 전체 통합 조회에서 조회한 결과값을 전달합니다.
protocol RecordRepository<RequestType, ResponseType>: Sendable {
    /// 구현체에서 결정할 요청(Request) DTO 타입
    associatedtype RequestType: Encodable
    /// 구현체에서 결정할 응답(Response) DTO 타입
    associatedtype ResponseType: Decodable
    
    /// 새로운 기록을 생성합니다.
    /// - Parameters:
    ///   - form: 생성할 기록의 요청 바디 DTO
    /// - Returns: 생성된 기록 DTO
    func create(form: RequestType) async throws(RecordRepositoryError) -> ResponseType
    
    /// 기존 기록을 수정합니다.
    /// - Parameters:
    ///   - recordId: 수정할 기록의 고유 식별자 (ID)
    ///   - form: 수정할 기록의 요청 바디 DTO
    /// - Returns: 수정된 기록 DTO
    func update(recordId: String, form: RequestType) async throws(RecordRepositoryError) -> ResponseType
    
    /// 특정 기록을 삭제합니다.
    /// - Parameters:
    ///   - recordId: 삭제할 기록의 고유 식별자 (ID)
    /// - Returns: 삭제 완료 정보 DTO
    func delete(recordId: String) async throws(RecordRepositoryError)
}
