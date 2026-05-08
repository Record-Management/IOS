import Foundation

enum Field: Hashable {
    case kcal
    case time
    case step
    case weight
    case content
    
    func getName() -> String {
        switch self {
        case .kcal: return "kcal"
        case .time: return "분"
        case .step: return "걸음"
        case .weight: return "Kg"
        case .content: return ""
        }
    }
}
