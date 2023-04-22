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
}
