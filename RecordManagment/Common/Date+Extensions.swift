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
    static func dailyTimeRecordDateFormat(_ date: [Int]) -> String {
        guard date.count == 2 else { return "" }
        let component = DateComponents(hour: date[0], minute: date[1])
        let calender = Calendar.current
        let dateFormatter = DateFormatter()
        
        dateFormatter.dateFormat = "a hh:mm"
        dateFormatter.locale = Locale(identifier: "ko_KR")
        
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
    
    static func convertArrayForDate(_ date: Date) -> [Int] {
        let calendar = Calendar.current
        let components = calendar.dateComponents([.year, .month, .day], from: date)
        guard let year = components.year, let month = components.month, let day = components.day else { return [] }
        return [year, month, day]
    }
}
