//
//  UserLoginData.swift
//  social-apple
//
//  Created by Daniel Kravec on 2023-04-19.
//

import Foundation

struct UserLoginData: Decodable, Encodable {
    let username: String
    let password: String
}

struct UserLoginResponse: Decodable {
    let login: Bool
    let publicData: UserData
    let accessToken: String
    let userToken: String
    let userID: String
    
    private enum CodingKeys: String, CodingKey {
        case login
        case publicData
        case accessToken
        case userToken
        case userID
    }
}

struct UserTokenData: Decodable, Encodable {
    let accessToken: String
    let userToken: String
    let userID: String
    
    init (accessToken: String, userToken: String, userID: String) {
        self.accessToken = accessToken
        self.userToken = userToken
        self.userID = userID
    }
}

struct DevModeData: Decodable, Encodable {
    let isEnabled: Bool
}
