//
//  OnBoardingDTO.swift
//  RecordManagment
//
//  Created by 김용해 on 9/4/25.
//

import Foundation

/// ** 최종 OnBoarding DTO
struct OnBoardingDTO: Codable {
    let nickName: String
    let mainRecordType: String
    let birthDate: String
    let goalDays: Int
    let notificationEnabled: Bool
    
    enum CodingKeys: String, CodingKey {
        case nickName = "nickname"
        case mainRecordType = "mainRecordType"
        case birthDate = "birthDate"
        case goalDays = "goalDays"
        case notificationEnabled = "notificationEnabled"
    }
}


struct OnBoardingResponseDTO: Codable {
    let statusCode: Int?
    let code: String
    let message: String
    let data: OnBoardingUserData?
}

struct OnBoardingUserData: Codable {
    let id: String
    let name: String
    let nickname: String
    let email: String?
    let socialType: String
    let mainRecordType: String
    let birthDate: [Int]
    let goalDays: Int
    let notificationEnabled: Bool
    let onboardingCompleted: Bool
    let createdAt: [Int]
}
