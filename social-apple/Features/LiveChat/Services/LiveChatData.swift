//
//  LiveChat.swift
//  social-apple
//
//  Created by Daniel Kravec on 2023-11-08.
//

import Foundation

struct LiveChatSendData: Decodable, Encodable {
    var type: Int8? = nil
    var mesType: Int8? = nil
    var apiVersion: String? = nil
    var userID: String? = nil
    var message: LiveChatMessageSendData? = nil
    var tokens: TokenData
    var typing: Bool?
}

struct LiveChatMessageSendData: Decodable, Encodable {
    var userID: String? = nil
    var content: String? = nil
    var replyTo: String? = nil
}

struct LiveChatTypers: Decodable, Encodable, Identifiable {
    var id = UUID()
    var username: String

    private enum CodingKeys: String, CodingKey {
        case username
    }
}

func createLiveSendData(
    type: Int8,
    mesType: Int8,
    content: String,
    replyTo: String?,
    userTokenData: UserTokenData?
) -> LiveChatSendData {
    let message = LiveChatMessageSendData(
        userID: userTokenData?.userID,
        content: content,
        replyTo: replyTo
    )
    let api_values = API_Data()
    
    return LiveChatSendData(
        type: type,
        mesType: mesType,
        apiVersion: "1.0",
        userID: userTokenData?.userID,
        message: message,
        tokens: genTokenData(appToken: api_values.getAppToken(), devToken: api_values.getDevToken(), userTokenData: userTokenData ?? nil)
    )
}

struct LiveChatData: Decodable, Encodable, Identifiable {
    var id = UUID()
    var _id: String? = nil
    var type: Int8? = nil
    var mesType: Int8? = nil
    var user: SimpleUserData? = nil
    var apiVersions: String? = nil
    var pings: LiveChatPingsData? = nil
    var message: LiveChatMessageData? = nil
    var userJoin: LiveChatUserJoinData? = nil
    var userLeave: LiveChatUserLeaveData? = nil
    var userTyping: Bool? = nil
    
    private enum CodingKeys: String, CodingKey {
        case _id
        case type
        case mesType
        case user
        case apiVersions
        case pings
        case userJoin
        case message
        case userLeave
        case userTyping
    }
}

struct SimpleUserData: Decodable, Encodable {
    var _id: String
    var username: String
    var displayName: String
}

struct LiveChatPingsData: Decodable, Encodable {
    var alive: Bool
}

struct LiveChatMessageData: Decodable, Encodable {
    var userID: String?
    var user: String?
//    var currentUsers: Int32?
    var content: String?
    var timeStamp: Int64?
    var replyTo: String?
    var edited: Bool?
//    var editedTimeStamp: String?
}

struct LiveChatUserJoinData: Decodable, Encodable {
    var userID: String?
    var user: String?
//    var currentUsers: Int32?
    var content: String?
//    var timeStamp: String?
}

struct LiveChatUserLeaveData: Decodable, Encodable {
    var userID: String?
    var user: String?
//    var currentUsers: Int32?
    var content: String?
//    var timeStamp: String?
}
