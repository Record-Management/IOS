import SwiftUI

enum NotificationFilter: String ,Equatable, Hashable ,CaseIterable {
    case dailyReMinder
    case exerciseReMinder
    case habitReMinder
    case scheduleReMinder
    case goalReMinder
    case systemReMinder
    case detailHabitReminder
    
    func getImage() -> String {
        switch self {
            case .dailyReMinder:
                "Fillter-Book"
            case .exerciseReMinder:
                "Fillter-Excercise"
            case .habitReMinder:
                "Fillter-Clock"
            case .scheduleReMinder:
                "Fillter-Schedule"
            case .goalReMinder:
                "Filter-Goal"
            case .detailHabitReminder:
                "Fillter-Clock"
            case .systemReMinder:
                "AppIcon"
        }
    }
    
    static func matchingNotificationFilterType(_ str: String) -> NotificationFilter {
        switch str {
            case "DAILY_RECORD_REMINDER":
                .dailyReMinder
            case "EXERCISE_REMINDER":
                .exerciseReMinder
            case "HABIT_REMINDER":
                .habitReMinder
            case "SCHEDULE_REMINDER":
                .scheduleReMinder
            case "GOAL_SETTING_REMINDER":
                .goalReMinder
            case "HABIT_TIME_BASED_REMINDER":
                .detailHabitReminder
            default:
                .systemReMinder
        }
    }
}


//DAILY_RECORD_REMINDER - 메인 기록 미등록 알림
//EXERCISE_REMINDER - 운동 기록 미등록 알림
//HABIT_REMINDER - 습관 기록 미등록 알림
//SCHEDULE_REMINDER - 일정 기록 미등록 알림
//GOAL_SETTING_REMINDER - 목표 미설정 알림
//HABIT_TIME_BASED_REMINDER - 특정 습관 알림
//SYSTEM_ANNOUNCEMENT - 시스템 공지사항
//TEST - 테스트 알림
