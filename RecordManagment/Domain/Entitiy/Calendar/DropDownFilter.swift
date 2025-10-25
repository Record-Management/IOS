import SwiftUI

enum DropDownFilter: String ,Equatable, Hashable ,CaseIterable {
    case all
    case daily
    case exercise
    case habit
//    case schedule
    
    func getImage() -> String {
        switch self {
        case .all:
            "Fillter-All"
        case .daily:
            "Fillter-Book"
        case .exercise:
            "Fillter-Excercise"
        case .habit:
            "Fillter-Clock"
//        case .schedule:
//            "Fillter-Schedule"
        }
    }
    
    func getTitle() -> String {
        switch self {
            case .daily:
                "하루 기록"
            case .exercise:
                "운동 기록"
            case .habit:
                "습관 기록"
            default:
                ""
        }
    }
    
    var name: String {
        self.rawValue.uppercased()
    }
    
    static func == (lhs: DropDownFilter, rhs: DropDownFilter) -> Bool {
        switch (lhs, rhs) {
        case (.all, .all), (.daily, .daily), (.exercise, .exercise), (.habit, .habit) /*(.schedule, .schedule)*/:
            true
        default:
            false
        }
    }
    
    func hash(into hasher: inout Hasher) {
        switch self {
            case .all:
                hasher.combine("all")
            case .daily:
                hasher.combine("daily")
            case .exercise:
                hasher.combine("exercise")
            case .habit:
                hasher.combine("habit")
//            case .schedule:
//                hasher.combine("schedule")
        }
    }
    
    // ** 서버 타입 매칭을 위한 함수
    static func matchingType(type: String) -> DropDownFilter {
        switch type {
        case "DAILY":
            return .daily
        case "EXERCISE":
            return .exercise
//        case "SCHEDULE":
//            return .schedule
        case "HABIT":
            return .habit
        default:
            return .all
        }
    }
}
