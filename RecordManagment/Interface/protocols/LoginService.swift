//
//  LoginService.swift
//  RecordManagment
//
//  Created by 김용해 on 7/29/25.
//

protocol LoginService {
    func login() async -> UserState
    func logout() async
}

protocol KaKaoLoginInterface: LoginService {}

protocol AppleLoginInterface: LoginService {}
