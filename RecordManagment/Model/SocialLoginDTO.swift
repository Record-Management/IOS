//
//  AuthDTO.swift
//  RecordManagment
//
//  Created by 김용해 on 8/31/25.
//

import Foundation
import SwiftUI

// SocialLogin을 위해 서버에 보내기 위한 Request Body 타입
enum SocialType: String, Codable {
    case kakao
    case apple
}

// Login 성공 후 받을 DTO
struct SocialLoginResponseDTO: Codable {
    let statusCode: Int
    let code: String
    let message: String
    let data: DataResponse
}

// user의 id, name을 가진 객체 data
struct DataResponse: Codable {
    let accessToken: String
    let refreshToken: String
    let user: UserResponse
    let isNewUser: Bool
}

struct UserResponse: Codable {
    let id: String
    let name: String
    let email: String
}
