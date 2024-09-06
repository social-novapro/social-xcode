//
//  NotificationData.swift
//  social-apple
//
//  Created by Daniel Kravec on 2023-12-18.
//

import Foundation

struct PushNotificationSend: Decodable, Encodable {
    let deviceToken: String
    let deviceType: String
    let userID: String
}

struct DePushNotificationSend: Encodable {
    let deviceToken: String
    let userID: String
}

struct PushNotificationRes: Decodable, Encodable {
    let msg: String
}

struct NotificationDataDeviceTokenSend: Encodable {
    let deviceToken: String
}

struct NotificationDeviceSetting: Decodable, Encodable, Identifiable {
    var id = UUID()
    let name: String
    let value: Bool
    let displayName: String
    let description: String

    private enum CodingKeys: String, CodingKey {
        case name
        case value
        case displayName
        case description
    }
}

struct NotificationPossibleOptions: Decodable, Encodable, Identifiable {
    var id = UUID()
    let name: String
    let displayName: String
    let description: String
    let type: String
    let defaultValue: Bool
    
    private enum CodingKeys: String, CodingKey {
        case name
        case displayName
        case description
        case type
        case defaultValue
    }
}

struct SubmitPushNotificationNewSetting: Encodable {
    let value: Bool
    let name: String
}

struct SubmitPushNotificationSendSetting: Encodable {
    let newSettings: [SubmitPushNotificationNewSetting]
    let deviceToken: String
}
