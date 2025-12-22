import Foundation

extension Date {
    
    // OnBoarding Convert func for Reqeust Body
    static func onBoardingFormet(_ date: Date) -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"
        dateFormatter.locale = Locale(identifier: "ko_KR")
        return dateFormatter.string(from: date)
    }
    
    // Daily Record Format ex) 2025.09.15 (월)
    static func dailyRecordDateFormat(_ date: Date) -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy.MM.dd (E)"
        dateFormatter.locale = Locale(identifier: "ko_KR")
        return dateFormatter.string(from: date)
    }
    
    // Daily Time Record Format ex) 오전 02:32
    static func dailyTimeRecordDateFormat(_ date: Date) -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "a hh:mm"
        dateFormatter.locale = Locale(identifier: "ko_KR")
        return dateFormatter.string(from: date)
    }
    
    // Daily Time Record Format ex) 오전 02:32
    static func dailyTimeRecordDateFormat(_ date: [Int],_ isLocaleKo: Bool = true) -> String {
        guard date.count == 2 else { return "" }
        let component = DateComponents(hour: date[0], minute: date[1])
        let calender = Calendar.current
        let dateFormatter = DateFormatter()
        
        dateFormatter.dateFormat = "a hh:mm"
        if isLocaleKo {
            dateFormatter.locale = Locale(identifier: "ko_KR")
        }
        
        let componentDate = calender.date(from: component)
        return dateFormatter.string(from: componentDate ?? .now)
    }
    
    // dateformat만 바꿔서 사용가능한 DateFormat 함수
    static func intergrationDateFormat(_ date: Date, format: String) -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = format
        dateFormatter.locale = Locale(identifier: "ko_KR")
        return dateFormatter.string(from: date)
    }
    
    static func convertDateForIntArray(_ arr: [Int]) -> Date? {
        guard arr.count == 3 else { return nil }
        let component = DateComponents(year: arr[0], month: arr[1], day: arr[2])
        
        return Calendar.current.date(from: component)
    }
    
    static func convertNotificationForIntArray(_ arr: [Int]) -> Date? {
        guard arr.count == 6 else { return nil}
        let component = DateComponents(year: arr[0], month: arr[1], day: arr[2], hour: arr[3], minute: arr[4], second: arr[5])
        return Calendar.current.date(from: component)
    }
    
    static func convertTimeForIntArray(_ arr: [Int]) -> Date? {
        guard arr.count == 2 else { return nil }
        let component = DateComponents(hour: arr[0], minute: arr[1])
        
        return Calendar.current.date(from: component)
    }
    
    static func convertArrayForDate(_ date: Date) -> [Int] {
        let calendar = Calendar.current
        let components = calendar.dateComponents([.year, .month, .day], from: date)
        guard let year = components.year, let month = components.month, let day = components.day else { return [] }
        return [year, month, day]
    }
    
    // Setting 생년월일 형식
    static func settingBirthDate(_ arr: [Int]?) -> String? {
        guard let input = arr, input.count == 3 else { return nil }
        let component = DateComponents(year: input[0], month: input[1], day: input[2])
        let date = Calendar.current.date(from: component) ?? .now
        let dateformatter = DateFormatter()
        
        dateformatter.dateFormat = "yyyy/MM/dd"
        return dateformatter.string(from: date)
    }
    
    static func calcurateNotificationTime(_ date: Date) -> String {
        let now = Date()
        let calendar = Calendar.current
        let components = calendar.dateComponents([.day, .hour], from: date, to: now)
        
        if let day = components.day, day >= 1 {
            return "\(day)일 전"
        } else if let hour = components.hour, hour >= 1 {
            return "\(hour)시간 전"
        } else {
            return "방금 전"
        }
    }
}
