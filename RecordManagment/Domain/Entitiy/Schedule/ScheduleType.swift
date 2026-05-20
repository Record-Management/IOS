import Foundation


enum PickerProgress: Equatable {
    case start          // 시작 날짜
    case end            // 마지막 날짜
    case none           // wheel picker 안보이는 상태
}

struct ScheduleNotification: Hashable {
    var type: NotificationType
    var customHours: Int?
    var customMinute: Int?
    
    enum NotificationType: Hashable, CaseIterable, Identifiable {
        typealias CustomHours = Int?
        typealias CustomMinute = Int?
        
        case none
        case one_day_before                                 // (1일 전 오전 9시)
        case two_days_before                                 // (2일 전 오전 9시)
        case custom(CustomHours, CustomMinute)                // 직접 날짜를 지정함
        
        var id: String {
            switch self {
            case .none:
                return "none"
            case .one_day_before:
                return "one_day_before"
            case .two_days_before:
                return "two_days_before"
            case .custom(_, _):
                return "custom"
            }
        }
        
        var format: String {
            return id.uppercased()
        }
        
        static var allCases: [NotificationType] {
            return [
                .none,
                .one_day_before,
                .two_days_before,
                .custom(nil, nil)
            ]
        }
    }
    
    static let `default`: Self = .init(type: .none)
}

struct ScheduleRepeat: Hashable, Codable {
    var type: RepeatType
    var endsOn: Date?
    
    enum RepeatType: Hashable, CaseIterable, Codable {
        case none, day, week, month, year
    }
    
    var format: String {
        switch type {
        case .none:
            return "NONE"
        case .day:
            return "DAY"
        case .week:
            return "WEEK"
        case .month:
            return "MONTH"
        case .year:
            return "YEAR"
        }
    }
    
    var hasEndsOn: Bool {
        get { endsOn != nil }
        set { endsOn = newValue ? (endsOn ?? .now) : nil }
    }
    
    static let `default`: Self = .init(type: .none, endsOn: nil)
}

enum ScheduleColor: String ,Hashable, CaseIterable, Codable {
    case Red
    case Orange
    case Yellow
    case Green
    case Blue
    case Navy
    case Pink
    case Gray
    
    var format: String {
        switch self {
        case .Navy:
            return "INDIGO"
        default:
            return rawValue.uppercased()
        }
    }
}

/// 저장 또는 X의 상태값을 표현합니다
enum SaveState: Equatable {
    case none
    case exit(ScheduleSheetItem)
}

// 1. 모든 Sheet 타입을 감쌀 수 있는 Enum 정의
enum ScheduleSheetItem: Equatable {
    case notification(ScheduleNotification)
    case `repeat`(ScheduleRepeat) // repeat는 예약어라 백틱(`)으로 감쌉니다
    case color(ScheduleColor)
}
