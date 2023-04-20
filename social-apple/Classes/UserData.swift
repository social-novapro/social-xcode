//
//  UserData.swift
//  social-apple
//
//  Created by Daniel Kravec on 2023-04-19.
//

import Foundation

struct UserData: Decodable {
    var _id: String? = nil
    var __v: Int64? = nil
    var creationTimestamp: String? = nil
    var description: String? = nil
    var displayName: String? = nil
    var followerCount: Int64? = nil
    var followingCount: Int64? = nil
    var lastEditDisplayname: Int64? = nil
    var lastEditUsername: Int64? = nil
    var likeCount: Int64? = nil
    var likedCount: Int64? = nil
    var pronouns: String? = nil
    var statusTitle: String? = nil
    var totalPosts: Int64? = nil
    var totalReplies: Int64? = nil
    var username: String? = nil
    
    private enum CodingKeys: String, CodingKey {
        case _id
        case __v
        case creationTimestamp
        case description
        case displayName
        case followerCount
        case followingCount
        case lastEditDisplayname
        case lastEditUsername
        case likeCount
        case likedCount
        case pronouns
        case statusTitle
        case totalPosts
        case totalReplies
        case username
        
    }
    
//    init (
//_id: String,
//__v: String,
//creationTimestamp: String, description: String,  displayName: String,  followerCount: Int64 ,  followingCount: Int64,  lastEditDisplayname: Int64 ,  lastEditUsername: Int64,  likeCount: Int64 ,  likedCount: Int64,  pronouns: String ,  statusTitle: String ,  totalPosts: Int64 ,  totalReplies: Int64,  username: String)
//    {
//    case _id
//    case __v
//    case creationTimestamp
//    case description
//    case displayName
//    case followerCount
//    case followingCount
//    case lastEditDisplayname
//    case lastEditUsername
//    case likeCount
//    case likedCount
//    case pronouns
//    case statusTitle
//    case totalPosts
//    case totalReplies
//    case username
//    }
}


struct User: Decodable {
    let description: String
    // add other properties as needed
    
    private enum CodingKeys: String, CodingKey {
        case description = "description"
        // map other keys as needed
    }
}
