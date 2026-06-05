import Foundation
import OSLog

extension Logger {
    /// 사용 중인 앱의 번들 식별자를 서브시스템으로 설정합니다.
    private static var subsystem = Bundle.main.bundleIdentifier ?? "com.yongms.RecordManagment"

    // MARK: - 카테고리별 로거 정의
    
    /// 개발 중 임시 디버그 메시지용 로거
    public static let debug = Logger(subsystem: subsystem, category: "💬 Debug")
    
    /// 네트워크 요청 및 응답 관련 로거
    public static let network = Logger(subsystem: subsystem, category: "🌐 Network")
    
    /// UI 렌더링, 제스처, 화면 전환 등 인터페이스 로거
    public static let ui = Logger(subsystem: subsystem, category: "📱 UI")
    
    /// 로컬 데이터베이스(CoreData, SwiftData, Realm 등) 및 파일 I/O 로거
    public static let database = Logger(subsystem: subsystem, category: "💾 Database")
    
    /// 핵심 비즈니스 로직 및 상태 변화 로거
    public static let info = Logger(subsystem: subsystem, category: "ℹ️ Info")
    
    /// 에러 상황 기록용 로거
    public static let error = Logger(subsystem: subsystem, category: "⚠️ Error")
}

// MARK: - 편의를 위한 전역 로깅 함수 (선택 사항)
/// 보다 직관적으로 사용하기 위한 전역 Log 구조체입니다.
public enum Log {
    /// 디버그 로그 출력 (개발용)
    /// - Parameter message: 출력할 메시지
    public static func debug(_ message: String) {
        Logger.debug.debug("\(message)")
    }
    
    /// 네트워크 관련 로그 출력
    /// - Parameter message: 출력할 메시지
    /// - Parameter isError: 에러 상황 여부 (true일 경우 Error 등급으로 출력)
    public static func network(_ message: String, isError: Bool = false) {
        if isError {
            Logger.network.error("\(message)")
        } else {
            Logger.network.info("\(message)")
        }
    }
    
    /// UI 관련 로그 출력
    public static func ui(_ message: String) {
        Logger.ui.debug("\(message)")
    }
    
    /// 데이터베이스 관련 로그 출력
    public static func database(_ message: String, isError: Bool = false) {
        if isError {
            Logger.database.error("\(message)")
        } else {
            Logger.database.info("\(message)")
        }
    }
    
    /// 일반 정보성 로그 출력
    public static func info(_ message: String) {
        Logger.info.info("\(message)")
    }
    
    /// 에러 로그 출력
    /// - Parameters:
    ///   - message: 에러 메시지
    ///   - error: 함께 출력할 Error 객체 (선택)
    public static func error(_ message: String, error: Error? = nil) {
        if let error = error {
            Logger.error.fault("\(message) | Error: \(error.localizedDescription)")
        } else {
            Logger.error.error("\(message)")
        }
    }
}
