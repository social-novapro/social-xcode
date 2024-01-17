//
//  DeveloperData.swift
//  social-apple
//
//  Created by Daniel Kravec on 2024-01-16.
//

import Foundation

struct DeveloperResponseData: Decodable {
    var developer: Bool
    var applications: Bool?
    var allowedApplications: Bool?
    var DeveloperToken: DeveloperTokenData?
    var AppTokens: [AppTokenData]
    var AppAccesses: [AppAccessesData]
}

struct DeveloperTokenData: Decodable {
    var _id: String?
    var userID: String?
    var creationTimestamp: Int64?
    var APIUses: Int64?
    var premium: Bool?
    var apps: [String]?
}

struct AppTokenData: Decodable, Identifiable {
    var id = UUID()
    var _id: String
    var APIUses: Int64? = nil
    var appName: String? = nil
    var creationTimestamp: Int64? = nil
    var devToken: String? = nil
    var userID: String? = nil
    
    private enum CodingKeys: String, CodingKey {
        case _id
        case APIUses
        case appName
        case creationTimestamp
        case devToken
        case userID
    }
}

struct AppAccessesData: Decodable, Identifiable {
    var id = UUID()
    var _id: String? = nil
    var appToken: String? = nil
    var creationTimestamp: Int64? = nil
    var userID: String? = nil
    var userToken: String? = nil
    
    private enum CodingKeys: String, CodingKey {
        case _id
        case appToken
        case creationTimestamp
        case userID
        case userToken
    }
}
