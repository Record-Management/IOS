//
//  Date+Extensions.swift
//  RecordManagment
//
//  Created by 김용해 on 9/4/25.
//

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
}
