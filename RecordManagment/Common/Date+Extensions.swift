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
        dateFormatter.dateFormat = "yyyy-06-02"
        dateFormatter.locale = Locale(identifier: "ko_KR")
        return dateFormatter.string(from: date)
    }
}
