//
//  UserData.swift
//  social-apple
//
//  Created by Daniel Kravec on 2023-04-19.
//

import Foundation

struct UserData: Decodable {
    let _id: String
    let __v: Int64
    let creationTimestamp: String
    let description: String
    let displayName: String
    let followerCount: Int64
    let followingCount: Int64
    let lastEditDisplayname: Int64
    let lastEditUsername: Int64
    let likeCount: Int64
    let likedCount: Int64
    let pronouns: String
    let statusTitle: String
    let totalPosts: Int64
    let totalReplies: Int64
    let username: String
    
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
