//
//  PostModelsData.swift
//  social-apple
//
//  Created by Daniel Kravec on 2026-03-24.
//

import Foundation
import SwiftUI

struct PostData: Decodable, Encodable, Identifiable {
    var id = UUID()
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
    var indexID: String? = nil
    var attachments: [AttachmentData]? = nil;

    var quoteReplyID: String? = nil
    var replyingPostID: String? = nil
    var quoteReplyPostID: String? = nil

    private enum CodingKeys: String, CodingKey {
        case _id
        case coposters
        case userID
        case timePosted
        case timestamp
        case content
        case totalLikes
        case totalReplies
        case totalQuotes
        case edited
        case editedTimestamp
        case amountEdited
        case isReply
        case isQuote
        case hasPoll
        case indexID
        case attachments

        case quoteReplyID
        case replyingPostID
        case quoteReplyPostID
    }
}

struct PostCreateContent: Encodable {
    var userID: String
    var content: String
    var replyingPostID: String? = nil
    var quoteReplyPostID: String? = nil
    var linkedPollID: String? = nil
    var coposters: [String]? = nil
}

struct FeedV2Data: Decodable {
    var nextIndexID: String? = nil
    var prevIndexID: String? = nil
    var amount: Int64
    var feedVersion: Int64? = nil
    var posts: [AllPosts]
}

struct AllPosts: Observable, Decodable, Identifiable, Equatable {
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
    var tagData: [TagData]? = nil
    var extraData: ExtraData
    var postLiveData: PostExtraData = PostExtraData()
//    var postActiveData: PostActiveData
    var contentArgs: [String] = []

    private enum CodingKeys: String, CodingKey {
        case typeData = "type"
        case postData
        case userData
        case quoteData
        case replyData
        case pollData
        case voteData
        case coposterData
        case tagData
        case extraData
    }
}

struct AttachmentData: Decodable, Encodable, Identifiable {
    var id = UUID()
    var _id: String
    var index: String
    var type: String
    var host: String?
    var url: String
    var vuid: String?

    private enum CodingKeys: String, CodingKey {
        case _id
        case index
        case type
        case host
        case url
        case vuid
    }
}

struct TagData:Decodable, Encodable {
    var _id: String
    var tagTextOriginal: String
    var wordIndex: Int64
    var timestamp: Int64
    var indexID: String
    var userID: String
    var postID: String
}

struct CoposterStorageItem: Identifiable {
    var id = UUID()
    var username: String
    var userID: String

    private enum CodingKeys: String, CodingKey {
        case username
        case userID
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
    var amountVoted: Int64? = 0

    private enum CodingKeys: String, CodingKey {
        case _id
        case optionTitle
        case timestamp
        case currentIndexID
        case amountVoted
    }
}

struct ExtraData: Decodable, Encodable {
    var liked:Bool? = false
    var pinned:Bool? = false
    var saved:Bool? = false
    var followed:Bool? = false

    private enum CodingKeys: String, CodingKey {
        case liked
        case pinned
        case saved
        case followed
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

struct PostDeleteRes: Decodable {
    var deleted: Bool
    var post: PostData
}

struct PostLikesRes: Decodable {
    var postID: String
    var peopleLiked: [PostPeopleLikedRes]
}

struct PostPeopleLikedRes: Decodable, Identifiable {
    var id = UUID()
    var userID: String
    var username: String

    private enum CodingKeys: String, CodingKey {
        case userID
        case username
    }
}

struct PostQuoteResV2: Decodable {
    var post: PostData?
    var quoteIndex: PostSubIndexesSchema?
    var quotes: [AllPosts]? = []
}

struct PostReplyResV2: Decodable {
    var post: PostData?
    var replyIndex: PostSubIndexesSchema?
    var replies: [AllPosts]? = []
}

struct PostSubIndexesSchema: Decodable {
    var _id: String
    var postID: String
    var amount: Int64
    var previousIndex: String?
    var nextIndex: String?
    var postIDs: [String]
    var indexStartTime: Int64?
    var indexEndTime: Int64?
}

struct PostEditContent: Decodable, Identifiable {
    var id = UUID()
    var publicTimestamp: Int64?
    var removedTimestamp: Int64?
    var content: String

    private enum CodingKeys: String, CodingKey {
        case publicTimestamp
        case removedTimestamp
        case content
    }
}

struct PostEditSchema: Decodable {
    var _id: String
    var userID: String?
    var edits: [PostEditContent]
}

struct PostUnbookmarkRes: Decodable {
    var success: Bool
    var bookmark: PostBookmarksPostsSchema
}

struct PostBookmarkReq: Encodable {
    var postID: String
    var listname: String?
}

struct PostBookmarkRes: Decodable {
    var Bookmarks: PostBookmarksSchema
}

struct PostBookmarksSchema: Decodable {
    var _id: String
    var saves: [PostBookmarksPostsSchema]
    var lists: [PostBookmarksListsSchema]
}

struct PostBookmarksListsSchema: Decodable {
    var name: String
    var timestamp: Int64
}

struct PostBookmarksPostsSchema: Decodable {
    var _id:String
    var bookmarkList: String?
    var timestamp: Int64?
}

struct PostExtraData: Observable {
    var showData: Bool = true
    var isActive: Bool = false
    var isOwner: Bool = false
    var deleted: Bool = false
    var actionExpanded: Bool = false
    var isSpecificPageActive: Bool = false
    var activeAction: Int32 = 0
    /*
     * 0 = none
     * 1 = reply
     * 2 = quote
     * 3 = showing reply parent
     * 4 = delete post
     * 5 = edit post
     */
    var popoverAction: Int32 = 0
    /*
     * 0 = none
     * 1 = reply
     * 2 = quote
     */
    var showingPopover: Bool = false
    var showPostPage: Bool = false
    var showingEditPopover: Bool = false
    var showingSummary: Bool = false
    var subAction: Int32 = 0

    /*
     * 0 = inactive
     * 1 = edit history
     * 2 = who liked
     * 3 = replies
     * 4 = quotes
     * 5 = ai summary
     */
}

struct PostEditRes : Decodable {
    var before : PostData
    var new : PostData
}

struct PostEditReq : Encodable {
    var postID: String
    var content: String
}

struct TagPotentialData : Identifiable, Decodable {
    var id: String { displayText }
    var possibility: String
    var tag: String?
    var tagText: String?

    var displayText: String {
        tag ?? tagText ?? ""
    }

    private enum CodingKeys: String, CodingKey {
        case possibility
        case tag
        case tagText
    }
}

struct TagFoundData : Identifiable, Decodable {
    var id = UUID()
    var tag: String
    var posts: [AllPosts]? = []

    private enum CodingKeys: String, CodingKey {
        case tag
        case posts
    }
}

//interactPostCoSchema = mongoose.Schema({
//    _id: reqString, // uuid
//    userID: reqString,
//    postID: reqString,
//    timestamp: reqNum,
//    deletedPost: reqBool, // if post is deleted
//    declined: reqBool, // if user declined
//    approved: reqBool, // if user approved
//    approvedTimestamp: nonreqNum, // timestamp user approved
//
struct CopostRequestData: Identifiable, Encodable, Decodable {
    var id = UUID()
    var _id: String
    var userID: String
    var postID: String
    var timestamp: Int64
    var deletedPost: Bool
    var declined: Bool
    var approved: Bool
    var approvedTimestamp: Int64?

    private enum CodingKeys: String, CodingKey {
        case _id
        case userID
        case postID
        case timestamp
        case deletedPost
        case declined
        case approved
        case approvedTimestamp
    }
}

/*
 request: copost,
 post: foundPost,
 user: foundUser ? foundUser : null
 */

struct CopostRequestsData: Identifiable, Encodable, Decodable {
    var id = UUID()
    var request: CopostRequestData
    var post: PostData
    var user: UserData?
    var dismissed: Bool = false

    private enum CodingKeys: String, CodingKey {
        case request
        case post
        case user
    }
}

struct SummerizeResponseData: Encodable, Decodable {
    var foundUsername: String
    var generationType: String
    var modelName: String
    var ollamaTime: Int64
    var response: String
    var responseLength: Int64
    var totalChars: Int64
    var totalPosts: Int64
//    var versionNumber: String

//    private enum CodingKeys: String, CodingKey {
//        case foundUsername
//        case generationType
//        case modelName
//        case ollamaTime
//        case repsonse
//        case responseLength
//        case totalChars
//        case totalPosts
//    }
}
