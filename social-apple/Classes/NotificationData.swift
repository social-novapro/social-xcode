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


struct PushNotificationRes: Decodable, Encodable {
    let msg: String
}

