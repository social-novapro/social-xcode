//
//  PostData.swift
//  social-apple
//
//  Created by Daniel Kravec on 2023-04-19.
//

import Foundation

struct PostData: Decodable, Encodable {
    var _id: String
    var userID: String? = nil
    var timePosted: String? = nil
    var content: String? = nil
    var totalLikes: Int64? = nil
    var totalReplies: Int64? = nil
    var totalQuotes: Int64? = nil
    var edited: Bool? = nil
    var editedTimestamp: String? = nil
    var amountEdited: Int64? = nil
    var quoteReplyID: String? = nil
    var replyingPostID: String? = nil
    var quoteReplyPostID: String? = nil
}

struct PostCreateContent: Encodable {
    var userID: String
    var content: String
    var replyingPostID: String? = nil
    var quoteReplyPostID: String? = nil
}

struct AllPosts: Decodable, Identifiable {
    var id = UUID()
    var typeData: TypeData
    var postData: PostData
    var userData: UserData? = nil
    
    private enum CodingKeys: String, CodingKey {
        case typeData = "type"
        case postData
        case userData
    }
}

struct TypeData: Decodable, Encodable{
    let type: String
    let post: String? = nil
    
    private enum CodingKeys: String, CodingKey {
        case type
        case post
    }
}

struct PostInput: Decodable, Encodable {
    var content: String
    var isReply: Bool?
    var replyID: String?
    var isQuote: Bool?
    var quoteID: String?
}
