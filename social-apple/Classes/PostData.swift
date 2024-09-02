//
//  PostData.swift
//  social-apple
//
//  Created by Daniel Kravec on 2023-04-19.
//

import Foundation
import SwiftUI

struct PublishPollData: Decodable, Encodable {
    var pollID: String?
    var sentPoll: Bool
    var pollPossibleFailed: Bool
}

class PostCreation: ObservableObject {
    var client: ApiClient
    @Published var content: String = ""

    private var publishPollData: PublishPollData = PublishPollData(pollID: nil, sentPoll: false, pollPossibleFailed: false)
    @Published var newPost: PostData?
    @Published var newPoll: PollData?
    @Published var sending: Bool = false
    @Published var sent: Bool = false
    @Published var errorMsg: String = "Unknown error."
    @Published var failed: Bool = false
    @Published var pollAdded: Bool = false
    @Published var coposterAdded: Bool = false
    @Published var tempPollCreator: TempPollCreator = TempPollCreator()
    @Published var coposters: [String] = []
    @Published var possibleTags: SearchPossibleTags?
    @Published var feedData: AllPosts?
    
    init(client: ApiClient, feedData: AllPosts? = nil) {
        self.client = client
        self.feedData = feedData
    }
    
    func replaceTag(tag: String) {
        if (tag == "") {
            DispatchQueue.main.async {
                self.possibleTags = nil;
                return
            }
        }
        var words: [String] {
            content.split(separator: " ").map { String($0) }
        }

        var newWords: [String] = words
        newWords.removeLast()

        
// because api doesnt add @ automatically
// undo because i did it on the frontend of the app

//        var addTag = tag
//        if (!tag.starts(with: "#")) {
//            addTag = "@" + tag
//        }
        
        newWords.append("\(tag) ")
        let newContent = newWords.joined(separator: " ")
        DispatchQueue.main.async {
            self.content = newContent
            self.possibleTags = nil;
        }
    }
    
    func typePost(newValue: String) {
        if (newValue == "") {
            DispatchQueue.main.async {
                self.possibleTags = nil;
                return
            }
        }
//        print("--- \(newValue) \(content)")
        
        var words: [String] {
            content.split(separator: " ").map { String($0) }
        }

        if (words.count == 0) {
            return
        }
        let currentWord = words[words.count-1]
        print(words[words.count-1])
        
        // if doesnt meet tag requirements
        if (content.last == " " || !currentWord.starts(with: "@") && !currentWord.starts(with: "#")){
            DispatchQueue.main.async {
                self.possibleTags = nil;
            }

            return;
        }

//        if (currentWord.starts(with: "@"))

        client.search.searchTagSuggestion(searchText: currentWord) { result in
            switch result {
            case .success(let results):
                DispatchQueue.main.async {
                    self.possibleTags = results;
                    print(results)
                }
                break;
            case .failure(let error):
                print("Error: \(error.localizedDescription)")
            }
        }
    }
    
    func publishPoll() async throws -> CreatePollRes {
        print("1- inside poll")
        if self.pollAdded {
            print("2- poll added yes")
            do {
                print("2- setting poll")
                let newPoll = try await self.client.polls.createV2(pollInput: self.tempPollCreator)
                print("4- made poll")
                print(newPoll)
                
                DispatchQueue.main.async {
                    self.newPoll = newPoll.pollData
                    self.publishPollData.pollID = self.newPoll?._id
                    self.publishPollData.sentPoll = true
                    self.client.hapticPress()
                }
                
                return newPoll
            } catch {
                print("5- failed inside")
                DispatchQueue.main.async {
                    self.failed = true
                    self.errorMsg = "Poll failed to be created, check for invalid options"
                    self.publishPollData.pollPossibleFailed = true
                }
                
                print("Error: \(error.localizedDescription)")
                throw ErrorData(code: "Z001", msg: "Uknown", error: true)
            }
        } else {
            throw ErrorData(code: "Z001", msg: "Uknown", error: true)
        }
    }
    
    func sendPost() async throws -> PostData {
        // if previously press send
        if (self.failed == false && self.sending) {
            throw ErrorData(code: "Z001", msg: "Uknown", error: true)
        // if previously tried to send and failed
        } else if (self.failed==true && self.sending) {
            DispatchQueue.main.async {
                self.sending = false
                self.failed = false
                self.publishPollData = PublishPollData(pollID: nil, sentPoll: false, pollPossibleFailed: false)
            }
        }
        
        // haptic press
        self.client.hapticPress()

        // sending
        DispatchQueue.main.async {
            self.sending = true
        }
                
        // set up post content
        var postCreateContent = PostCreateContent(userID: self.client.userTokens.userID, content: self.content)

        // set up reply / quote
        
        if (self.feedData != nil) {
            if (self.feedData?.postLiveData.popoverAction == 1) {
                postCreateContent.replyingPostID = self.feedData?.postData._id
            } else if (self.feedData?.postLiveData.popoverAction == 2) {
                postCreateContent.quoteReplyPostID = self.feedData?.postData._id
            }

        }

        
        // is content empty
        if (self.content == "") {
            self.failed = true
            self.errorMsg = "Please enter post content."
            
            throw ErrorData(code: "Z001", msg: "Uknown", error: true)
        }
        
        // publish poll
        if (self.pollAdded) {
            do {
                let _ = try await self.publishPoll()
            } catch {
                print("failed to do after")
                throw ErrorData(code: "Z001", msg: "Uknown", error: true)
            }
        }
            
        // clear content
        DispatchQueue.main.async {
            self.content = ""
        }
        
        // check for fail in poll agressivly
        print(self.failed)
        print(self.publishPollData)
        print(self.pollAdded)

        if (
            (self.failed == true) ||// failed (self explaintory)
            (self.publishPollData.pollID == nil && self.pollAdded==true) || // no poll ID, when expected
            (self.publishPollData.sentPoll == false && self.pollAdded==true)
        ) {
            print("failed caught before create post, after poll creation")
            print (self.failed)
            print(self.publishPollData)
            print(self.pollAdded)
            throw ErrorData(code: "Z001", msg: "Uknown", error: true)
        } else {
            print("no poll, or post was added")
        }

        // add poll link
        if (self.publishPollData.pollID != nil) {
            postCreateContent.linkedPollID = self.publishPollData.pollID
            print("linked poll to post")
        }
        
        print(self.publishPollData.pollID ?? "")
        print(self.newPoll ?? "")
            
        // publish post
        do {
            let newPost = try await self.client.posts.createPostV2(postCreateContent: postCreateContent)
            print(newPost)
            
            DispatchQueue.main.async {
                self.newPost = newPost
                self.sent = true
                self.client.hapticPress()
                // clears poll data
                self.pollAdded = false
                self.tempPollCreator = TempPollCreator()
                self.failed = false
                self.sending = false
            }
            
            return newPost
        } catch {
            DispatchQueue.main.async {
                self.failed = true
                self.errorMsg = "Post failed to send"
                print("Error: \(error.localizedDescription)")
            }
            
            print("Error: \(error.localizedDescription)")
            throw ErrorData(code: "Z001", msg: "Uknown", error: true)
        }
    }
}


class FeedPosts: ObservableObject {
//    @ObservedObject var client: ApiClient
    var client: ApiClient

    @Published var feed: FeedV2Data = FeedV2Data(amount: 0, posts: [])
    @Published var posts: [AllPosts] = []
    @Published var loadingScroll: Bool = false
    @Published @MainActor var isLoading: Bool = true
    @Published var gotFeed: Bool = false

    init(client: ApiClient) {
        self.client = client
    }

    func newClient(client: ApiClient) {
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
    var tagData: [TagData]? = nil
    var extraData: ExtraData
    var postLiveData: PostExtraData = PostExtraData()
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

struct TagData:Decodable, Encodable {
    var _id: String
    var tagTextOriginal: String
    var wordIndex: Int64
    var timestamp: Int64
    var indexID: String
    var userID: String
    var postID: String
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
    var popoverAction: Int32 = 0
    /*
     * 0 = none
     * 1 = reply
     * 2 = quote
     */
    var showingPopover: Bool = false
    var showPostPage: Bool = false
    var showingEditPopover: Bool = false
    var subAction: Int32 = 0
    
    /*
     * 0 = inactive
     * 1 = edit history
     * 2 = who liked
     * 3 = replies
     * 4 = quotes
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
    var id = UUID()
    var possibility: String
    var tag: String
    
    private enum CodingKeys: String, CodingKey {
        case possibility
        case tag
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
