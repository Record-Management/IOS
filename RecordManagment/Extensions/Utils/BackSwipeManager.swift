import Foundation

class BackSwipeManager {
    static let shared: BackSwipeManager = .init()
    var isPopGestureActive: Bool = true // default back swipe true
    private init() {}
    
    func updatePopGesture(_ bool: Bool) {
        isPopGestureActive = bool
    }
}
