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
    var liked:Bool? = nil
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
    var quoteData: QuoteData? = nil
    var pollData: PollData? = nil
    var voteData: VoteData? = nil
    var extraData: ExtraData
    
    private enum CodingKeys: String, CodingKey {
        case typeData = "type"
        case postData
        case userData
        case quoteData
        case pollData
        case voteData
        case extraData
    }
}


struct QuoteData: Decodable, Encodable {
    var quotePost: PostData? = nil
    var quoteUser: UserData? = nil
}

struct PollData: Decodable, Encodable {
    var _id: String
}

struct VoteData: Decodable, Encodable {
    var _id: String
}

struct ExtraData: Decodable, Encodable {
    var liked:Bool? = false
    var pinned:Bool? = false
    var saved:Bool? = false

    private enum CodingKeys: String, CodingKey {
        case liked
        case pinned
        case saved
    }
}

struct TypeData: Decodable, Encodable{
    let type: String
    let post: String? = nil
    let quote: String? = nil
    let user: String? = nil
    let poll: String? = nil
    let vote: String? = nil
    let extra: String? = nil
    
    private enum CodingKeys: String, CodingKey {
        case type
        case post
        case quote
        case user
        case poll
        case vote
        case extra
    }
}

struct PostInput: Decodable, Encodable {
    var content: String
    var isReply: Bool?
    var replyID: String?
    var isQuote: Bool?
    var quoteID: String?
}
