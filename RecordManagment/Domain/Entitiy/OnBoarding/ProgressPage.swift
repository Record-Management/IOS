import Foundation

/// ** Page 진행도를 위한 data 구조
/// - enum: 각 Double값을 줌으로서 순차적인 진행 Page적용
/// - next: 다음 페이지 이동
/// - pop: 전 페이지 이동
enum ProgressPage: Double, CaseIterable {
    case record
    case name
    case birth
    case goal
    case notification
    
    
    static var totalPage: Double {
        Double(allCases.count)
    }
}

func next(_ current: ProgressPage, action: () -> Void, completion: (() -> Void)? = nil) {
    if current == ProgressPage.allCases.last {
        completion?()
    }else {
        action()
    }
}
