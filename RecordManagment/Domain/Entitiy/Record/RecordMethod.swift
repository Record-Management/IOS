import Foundation

enum RecordMethod {
    case create
    case update
    case delete
    
    // TODO: Method Response 성공 Method
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
    
    // TODO: Dismiss Alert Title Content
    func getTitle() -> String {
        switch self{
            case .create:
                "기록을 남기지 않고 나가시겠습니까?"
            case .update:
                "수정하지 않고 나가시겠습니까?"
            case .delete:
                "기록을 삭제하시겠습니까?"
        }
    }
    
    // TODO: Dismiss Alert SubTitle Content
    func getSubTitle() -> String {
        switch self{
            case .create:
                "작성 중인 기록은 저장되지 않아요."
            case .update:
                "변경한 내용은 저장되지 않아요."
            case .delete:
                "삭제된 기록은 복구가 불가해요."
        }
    }
}

extension RecordMethod {
    func alertButtonText() -> (left: String, right: String){
        switch self {
        case .create:
            (left: "나가기", right: "작성하기")
        case .update:
            (left: "나가기", right: "작성하기")
        case .delete:
            (left: "유지하기", right: "삭제하기")
        }
    }
}
