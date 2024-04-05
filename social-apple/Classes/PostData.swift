//
//  PostData.swift
//  social-apple
//
//  Created by Daniel Kravec on 2023-04-19.
//

import Foundation
import SwiftUI

class FeedPosts: ObservableObject {
//    @ObservedObject var client: ApiClient
    let client: ApiClient

    @Published var feed: FeedV2Data = FeedV2Data(amount: 0, posts: [])
    @Published var posts: [AllPosts] = []
    @Published var loadingScroll: Bool = false
    @Published @MainActor var isLoading: Bool = true
    @Published var gotFeed: Bool = false

    init(client: ApiClient) {
        self.client = client
    }

    func getFeed() {
        DispatchQueue.main.async {
            if (self.gotFeed==true) {
                return
            }
            self.client.posts.getUserFeed(userTokens: self.client.userTokens) { result in
                print("allpost request")
                
                switch result {
                case .success(let feed):
                    DispatchQueue.main.async {
                        self.feed = feed
                        self.addPosts(newPosts: self.feed.posts, toClear: true)
                        print("Done")
                        self.isLoading = false
                        self.gotFeed = true
                    }

                    print("Feed refreshed successfully.")

                case .failure(let error):
                    print("Error: \(error.localizedDescription)")
                }
            }
        }
    }
    
    func addPosts(newPosts: [AllPosts], toClear:Bool=false) -> Void {
        DispatchQueue.main.async {
            // due to new posts showing at bottom
            // could change that and fix it needing to be clear
            if (toClear==true) {
                self.posts = []
            }
            
            for var newPost in newPosts {
                if newPost.postData.userID == self.client.userTokens.userID {
                    newPost.postLiveData.isOwner = true
                }
                
                if let existingIndex = self.posts.firstIndex(where: { $0.postData._id == newPost.postData._id }) {
                    print("existing")
                    self.posts[existingIndex] = newPost
                } else {
                    self.posts.append(newPost)
                }
            }
        }
    }
    
    func refreshFeed() -> Void {
        DispatchQueue.main.async {
            self.client.posts.getUserFeed(userTokens: self.client.userTokens) { result in
                self.client.hapticPress()
                
                switch result {
                case .success(let feedData):
                    DispatchQueue.main.async {
                        self.feed = feedData
                        self.addPosts(newPosts: self.feed.posts, toClear: true)
                    }
                case .failure(let error):
                    print("Error: \(error.localizedDescription)")
                }
            }
        }
    }
    
    func nextIndex() -> Void {
        DispatchQueue.main.async {
            self.client.posts.getUserFeedIndex(userTokens: self.client.userTokens, index: self.feed.prevIndexID ?? "") { result in
                self.client.hapticPress()
                
                switch result {
                case .success(let feed):
                    DispatchQueue.main.async {
                        self.feed = feed
                        self.addPosts(newPosts: self.feed.posts, toClear: false)
                        self.loadingScroll = false
                    }
                case .failure(let error):
                    print("Error: \(error.localizedDescription)")
                }
            }
        }
    }
}

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
    var extraData: ExtraData
    var postLiveData: PostExtraData = PostExtraData()
    
    
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

struct PostQuoteRes: Decodable {
    var post: PostData
    var quoteIndex: PostSubIndexesSchema
    var quotes: [PostData]
}

struct PostReplyRes: Decodable {
    var post: PostData
    var replyIndex: PostSubIndexesSchema
    var replies: [PostData]
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
    
    var showingPopover: Bool = false
    var showPostPage: Bool = false
    var subAction: Int32 = 0
    /*
     * 0 = inactive
     * 1 = edit history
     * 2 = who liked
     * 3 = replies
     * 4 = quotes
     */
}
