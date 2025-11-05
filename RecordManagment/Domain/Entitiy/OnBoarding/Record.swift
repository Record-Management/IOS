import SwiftUI

enum Record: String {
    case none
    case daily
    case exercise
//    case schedule
    case habit
    
    var id: String {
        self.rawValue
    }
    
    static var records: [Record] {
        [.daily, .exercise, .habit /*.schedule*/]
    }
    
    // TODO: 온보딩 Request Body값 변환을 위한 함수
    func localizedString() -> String {
        switch self {
        case .daily:
            return "DAILY"
        case .exercise:
            return "EXERCISE"
        case .habit:
            return "HABIT"
//        case .schedule:
//            return "SCHEDULE"
        default:
            return ""
        }
    }
    
    // TODO: Icon Matching Method
    var imageName: String {
        switch self {
            case .none:
                ""
            case .daily:
                "Fillter-Book"
            case .exercise:
                "Fillter-Excercise"
            case .habit:
                "Fillter-Clock"
        }
    }
    
    // TODO: 각 case에 맞는 Titlte을 제공하는 함수
    func getTitle() -> String {
        switch self {
        case .daily:
            return "하루 기록"
        case .exercise:
            return "운동 기록"
//        case .schedule:
//            return "일정 기록"
        case .habit:
            return "습관 기록"
        default:
            return ""
        }
    }
    
    // TODO: 각 Case에 맞는 Color 제공
    func getColor() -> Color {
        switch self {
        case .daily:
            return Color(hex: "#EDF8FF")
        case .exercise:
            return Color(hex: "#EAF1F8")
        case .habit:
            return Color(hex: "#EEF9F0")
//        case .schedule:
//            return Color(hex: "#FFF5EB")
        default:
            return Color.gray
        }
    }
    
    // TODO: 각 Case에 맞는 Size 제공
    func getSize() -> CGSize {
        switch self {
            case .daily:
                return CGSize(width: 48, height: 48)
            case .exercise:
                return CGSize(width: 43, height: 24)
            case .habit:
                return CGSize(width: 23, height: 34)
//            case .schedule:
//                return CGSize(width: 28, height: 30)
            default:
                return .zero
        }
    }
    
    // TODO: 현재 선택된 기록 방식을 제외한 배열을 만드는 함수
    static func getRecords(current record: Record) -> [Record] {
        records.filter { $0.id != record.id }
    }
    
    // TODO: 서버에서 받아온 String값을 Enum 값과 매칭
    static func matchingMainRecordType(_ record: String) -> Record {
        switch record {
            case "DAILY":
                return .daily
            case "EXERCISE":
                return .exercise
            case "HABIT":
                return .habit
//            case "SCHEDULE":
//                return .schedule
            default:
                return .none
        }
    }
}
