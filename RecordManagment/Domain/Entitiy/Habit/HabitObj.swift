import SwiftUI

enum HabitObj: String, CaseIterable {
    case drinking
    case walking
    case reading
    case saving
    case medicine
    case earlyRising
    case stretching
    case exercise
    case noDrinking
    case noSmoking
    
    var id: String {
        self.rawValue
    }
    
    func getName() -> String {
        switch self {
            case .drinking:
                "물 마시기"
            case .walking:
                "산책"
            case .reading:
                "독서"
            case .saving:
                "저축"
            case .medicine:
                "약 챙겨먹기"
            case .earlyRising:
                "일찍 일어나기"
            case .stretching:
                "스트레칭"
            case .exercise:
                "운동"
            case .noDrinking:
                "금주"
            case .noSmoking:
                "금연"
        }
    }
    
    var imageName: String {
        switch self {
            case .drinking:
                "WATER_DRINKING"
            case .walking:
                "WALKING"
            case .reading:
                "READING"
            case .saving:
                "SAVING"
            case .medicine:
                "TAKE_MEDICINE"
            case .earlyRising:
                "EARLY_RISING"
            case .stretching:
                "STRETCHING"
            case .exercise:
                "EXERCISE"
            case .noDrinking:
                "NO_DRINKING"
            case .noSmoking:
                "NO_SMOKING"
        }
    }
    
    static func machingHabitObj(_ str: String) -> HabitObj {
        switch str {
            case "WATER_DRINKING":
                .drinking
            case "WALKING":
                .walking
            case "READING":
                .reading
            case "SAVING":
                .saving
            case "TAKE_MEDICINE":
                .medicine
            case "EARLY_RISING":
                .earlyRising
            case "STRETCHING":
                .stretching
            case "EXERCISE":
                .exercise
            case "NO_DRINKING":
                .noDrinking
            case "NO_SMOKING":
                .noSmoking
            default:
                .drinking // default Vaue
        }
    }
}
