import Foundation


enum PickerProgress: Equatable {
    case start          // 시작 날짜
    case end            // 마지막 날짜
    case none           // wheel picker 안보이는 상태
}

struct ScheduleNotification: Equatable {
    var type: NotificationType
    var customDays: Date?
    var customHours: Date?
    
    enum NotificationType: Equatable, CaseIterable, Hashable {
        typealias CustomDays = Date?
        typealias CustomHours = Date?
        
        case none
        case one_day_before                                 // (1일 전 오전 9시)
        case two_day_before                                 // (2일 전 오전 9시)
        case custom(CustomDays, CustomHours)                // 직접 날짜를 지정함
        
        static var allCases: [NotificationType] {
            return [
                .none,
                .one_day_before,
                .two_day_before,
                .custom(nil, nil)
            ]
        }
    }
    
    static let `default`: Self = .init(type: .none)
}

struct ScheduleRepeat: Equatable {
    var type: RepeatType
    var endsOn: Date?
    
    enum RepeatType: Equatable, CaseIterable {
        case none, day, week, month, year
    }
    
    var hasEndsOn: Bool {
        get { endsOn != nil }
        set { endsOn = newValue ? (endsOn ?? .now) : nil }
    }
    
    static let `default`: Self = .init(type: .none, endsOn: nil)
}

enum ScheduleColor: String ,Equatable, CaseIterable {
    case Red
    case Orange
    case Yellow
    case Green
    case Blue
    case Navy
    case Pink
    case Gray
}
