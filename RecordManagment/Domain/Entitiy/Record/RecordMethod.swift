import Foundation

enum RecordMethod {
    case create
    case update
    case delete
    
    func getMessage() -> String {
        switch self {
        case .create:
            "기록이 작성 되었습니다."
        case .update:
            "기록이 수정 되었습니다."
        case .delete:
            "기록이 삭제 되었습니다."
        }
    }
}
