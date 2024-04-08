//
//  SearchData.swift
//  social-apple
//
//  Created by Daniel Kravec on 2024-04-07.
//

import Foundation

struct SearchLookupData: Encodable {
    var lookupkey: String
}

struct SearchFoundData: Decodable {
    var usersFound: [UserData]?
    var postsFound: [AllPosts]?
}

struct SearchSettingResponse: Decodable {
    var userID: String
    var possibleSearch: [PossibleSearchVersion]
    var currentSearch: SearchUserSetting
}

struct SearchUserSetting: Decodable {
    var _id: String // userID
    var timestamp: Int64
    var preferredSearch: String
}

struct PossibleSearchVersion: Identifiable, Decodable {
    var id = UUID()
    
    var name: String
    var niceName: String
    var description: String
    var version: Int32
    
    private enum CodingKeys: String, CodingKey {
        case name
        case niceName
        case description
        case version
    }
}

struct SearchSettingRequest: Encodable {
    var newSearch: String
}
