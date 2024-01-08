//
//  PostData.swift
//  social-apple
//
//  Created by Daniel Kravec on 2023-04-19.
//

import Foundation

struct PostData: Decodable, Encodable {
    var _id: String
    var coposters: [String]? = nil
    var userID: String? = nil
    var timePosted: String? = nil
    var timestamp: Int64? = nil
    var content: String? = nil
    var totalLikes: Int64? = nil
    var totalReplies: Int64? = nil
    var totalQuotes: Int64? = nil
    var edited: Bool? = nil
    var editedTimestamp: String? = nil
    var amountEdited: Int64? = nil
    var isReply: Bool? = nil
    var isQuote: Bool? = nil
    var hasPoll: Bool? = nil
    
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


struct FeedV2Data: Decodable {
//    var _id: String
    var nextIndexID: String? = nil
    var prevIndexID: String? = nil
    var amount: Int64
    var feedVersion: Int64? = nil
    var posts: [AllPosts]
}

struct AllPosts: Decodable, Identifiable, Equatable {
    static func == (lhs: AllPosts, rhs: AllPosts) -> Bool {
        return (lhs.postData._id == rhs.postData._id)
    }
    
    var id = UUID()
    var typeData: TypeData
    var postData: PostData
    var userData: UserData? = nil
    var quoteData: QuoteData? = nil
    var replyData: ReplyData? = nil
    var pollData: PollData? = nil
    var voteData: VoteData? = nil
    var coposterData: [UserData]? = nil
    var extraData: ExtraData
    
    
    private enum CodingKeys: String, CodingKey {
        case typeData = "type"
        case postData
        case userData
        case quoteData
        case replyData
        case pollData
        case voteData
        case coposterData
        case extraData
    }
}

struct QuoteData: Decodable, Encodable {
    var quotePost: PostData? = nil
    var quoteUser: UserData? = nil
}

struct ReplyData: Decodable, Encodable {
    var replyPost: PostData? = nil
    var replyUser: UserData? = nil
}

struct PollOptions: Decodable, Encodable, Identifiable {
    var id = UUID()
    var _id: String
    var optionTitle: String?
    var timestamp: Int64?
    var currentIndexID: String?
//    var amountVoted: Int32?
    
    private enum CodingKeys: String, CodingKey {
        case _id
        case optionTitle
        case timestamp
        case currentIndexID
//        case amountVoted
    }
    /*
     _id: nonreqString, // pollOptionID
     optionTitle: nonreqString,
     timestamp: nonreqNum, // time added option (maybe can add option later)
     currentIndexID: nonreqString, // pollVoteIndexID (changes)
     amountVoted: nonreqNum // amount of votes
     */
}

struct PollData: Decodable, Encodable {
    var _id: String
    var timestamp: Int64?
    var userID: String?
    var postID: String?
    var timestampEnding: Int64?
    var lastEdited: Int64?
    var pollName: String?
    var pollOptions: [PollOptions]?
}

struct VoteData: Decodable, Encodable {
    var _id: String
    var _version: Int16?
    var pollID: String?
    var userID: String?
    var lastEdited: Int64?
    var timestamp: Int64?
    var pollIndexID: String?
    var pollOptionID: String?
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
