import SwiftUI

enum DropDownFilter: Equatable, Hashable ,CaseIterable {
    case all
    case day
    case exercise
    case habit
    case schedule
    
    func getImage() -> String {
        switch self {
        case .all:
            "Fillter-All"
        case .day:
            "Fillter-Book"
        case .exercise:
            "Fillter-Excercise"
        case .habit:
            "Fillter-Clock"
        case .schedule:
            "Fillter-Schedule"
        }
    }
    
    static func == (lhs: DropDownFilter, rhs: DropDownFilter) -> Bool {
        switch (lhs, rhs) {
        case (.all, .all), (.day, .day), (.exercise, .exercise), (.habit, .habit), (.schedule, .schedule):
            true
        default:
            false
        }
    }
    
    func hash(into hasher: inout Hasher) {
        switch self {
            case .all:
                hasher.combine("all")
            case .day:
                hasher.combine("day")
            case .exercise:
                hasher.combine("exercise")
            case .habit:
                hasher.combine("habit")
            case .schedule:
                hasher.combine("schedule")
        }
    }
}
