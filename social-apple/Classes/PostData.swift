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
    var client: Client
    @Published var content: String = ""

    private var publishPollData: PublishPollData = PublishPollData(pollID: nil, sentPoll: false, pollPossibleFailed: false)
    let maxCharacters: Int = 512

    @Published var newPost: PostData?
    @Published var newPoll: PollData?
    @Published var sending: Bool = false
    @Published var sent: Bool = false
    @Published var errorMsg: String = "Unknown error."
    @Published var failed: Bool = false
    @Published var pollAdded: Bool = false
    @Published var coposterAdded: Bool = false
    @Published var mediaAdded: Bool = false
    @Published var tempPollCreator: TempPollCreator = TempPollCreator()
    @Published var coposters: [CoposterStorageItem] = []
    @Published var possibleTags: SearchPossibleTags?
    @Published var foundFiles: [URL] = [];
//    @published
    @Published var possibleCoposters: SearchPossibleTags?
    @Published var feedData: AllPosts?
    @Published var remainingCharacters: Int = 0;
    @Published var remainingCharactersCG: CGFloat = 0;
    @Published var coposterSearch: String = ""

    private var backupContent: String = "";

    init(client: Client, feedData: AllPosts? = nil) {
        self.client = client
        self.feedData = feedData
        self.remainingCharacters = maxCharacters;
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

        newWords.append("\(tag) ")
        let newContent = newWords.joined(separator: " ")
        
        DispatchQueue.main.async {
            self.content = newContent
            self.possibleTags = nil;
        }
    }
    
    func calcRemainingCharacters() {
        DispatchQueue.main.async {
            self.remainingCharacters = self.maxCharacters - self.content.count
            self.remainingCharactersCG = CGFloat(self.maxCharacters - self.remainingCharacters) / CGFloat(self.maxCharacters)
            print(self.remainingCharacters)
        }
    }
    
    func addCoposter(username: String, userID: String) {
        DispatchQueue.main.async {
            self.coposterSearch = "";
            self.coposters.append(CoposterStorageItem(username: username, userID: userID));
            self.possibleCoposters?.users = [];
            self.possibleCoposters?.hashtags = [];
        }
    }
    
    func removeCoposter(coposterRemove: CoposterStorageItem) {
        for (index, value) in coposters.enumerated() {
            if (value.id == coposterRemove.id) {
                self.coposters.remove(at: index);
            }
        }
    }
    
    func typeCopost(text: String) {
        if (text == "") {
            DispatchQueue.main.async {
                self.coposterSearch = "";
            }
        }
        
        var searchTerm = text;
        if (searchTerm.starts(with: "@")) {
            searchTerm = text.replacingOccurrences(of: "@", with: "0");
        } else {
            searchTerm = "0"+text;
        }
        
        client.api.search.searchTagSuggestion(searchText: searchTerm) { result in
            switch result {
            case .success(let results):
                DispatchQueue.main.async {
                    self.possibleCoposters = results;
                    print(results)
                }
                break;
            case .failure(let error):
                print(error)
                print("Error: \(error.localizedDescription)")
            }
        }

    }
    
    func addToPostContent(text: String) {
        if (text == "") {
            return;
        }
        DispatchQueue.main.async {
            self.content += text+" ";
        }
    }
    
    func typePost(newValue: String) {
        if (newValue == "") {
            DispatchQueue.main.async {
                self.possibleTags = nil;
               // self.calcRemainingCharacters();
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

        client.api.search.searchTagSuggestion(searchText: currentWord) { result in
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
                let newPoll = try await self.client.api.polls.createV2(pollInput: self.tempPollCreator)
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
    
    func recoverPostFromFail() {
        DispatchQueue.main.async {
            self.content = self.backupContent;
        }
    }
    
    func sendPost() async throws -> PostData {
        DispatchQueue.main.async {
            self.backupContent = self.content
        }
        
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
            DispatchQueue.main.async {
                self.failed = true
                self.errorMsg = "Please enter post content."
                
            }
            throw ErrorData(code: "Z001", msg: "Uknown", error: true)
        }
        // make sure not to long
        calcRemainingCharacters();

        if (self.remainingCharacters < 0) {
            DispatchQueue.main.async {
                self.failed = true
                self.errorMsg = "Message is to long."
            }
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
        
        var coposterArr:[String] = []
        var foundCoposterAdded: Bool = false
        if (self.coposterAdded) {
            for coposter in self.coposters {
                coposterArr.append(coposter.userID)
                foundCoposterAdded = true;
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
        
        if (foundCoposterAdded) {
            postCreateContent.coposters = coposterArr
        }
        
        print(self.publishPollData.pollID ?? "")
        print(self.newPoll ?? "")
            
        // publish post
        do {
            let newPost = try await self.client.api.posts.createPostV2(postCreateContent: postCreateContent)
            print(newPost)
            
            DispatchQueue.main.async {
                self.newPost = newPost
                self.sent = true
                self.client.hapticPress()
                // clears poll data
                self.pollAdded = false
                self.coposterAdded = false;
                self.coposters = []
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
    var client: Client

//    var api
    @Published var feed: FeedV2Data = FeedV2Data(amount: 0, posts: [])
    @Published var posts: [AllPosts] = []
    @Published var loadingScroll: Bool = false
    @Published @MainActor var isLoading: Bool = true
    @Published var gotFeed: Bool = false
    
    @Published var copostRequests: [CopostRequestsData] = []
    @Published var copostsFound: Bool = false

    init(client: Client) {
        self.client = client
    }

    func newClient(client: Client) {
        self.client = client
    }
    
    func getFeed() {
        DispatchQueue.main.async {
            if (self.gotFeed==true) {
                return
            }
            self.client.api.posts.getUserFeed(userTokens: self.client.userTokens) { result in
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
            self.getCopostRequests();
        }
    }
    
    func getCopostRequests() {
        DispatchQueue.main.async {
            Task {
                do {
                    self.copostRequests = try await self.client.api.posts.copostsRequests()
                    self.copostsFound = true
                } catch let error as ErrorData {
                    print("ErrorData: \(error.code), \(error.msg)")
                    self.copostsFound = false
                } catch {
                    print("Unexpected error: \(error)")
                    self.copostsFound = false
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
            self.client.api.posts.getUserFeed(userTokens: self.client.userTokens) { result in
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
            self.client.api.posts.getUserFeedIndex(userTokens: self.client.userTokens, index: self.feed.prevIndexID ?? "") { result in
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

class PostActiveData: ObservableObject {
    var client: Client

    @Published var post: AllPosts
    @Published var replies: PostReplyResV2 = PostReplyResV2()
    @Published var quotes: PostQuoteResV2 = PostQuoteResV2()
    @Published var summary: SummerizeResponseData?
    
    @Published var doneSummary = false
    @Published var loadingSummary = false
    @Published var failedSummary = false
    
    @Published var doneReplies = false
    @Published var loadingReplies = false
    @Published var failedReplies = false
    
    @Published var doneQuotes = false
    @Published var loadingQuotes = false
    @Published var failedQuotes = false
    
    init(client: Client, postData: AllPosts) {
        self.client = client
        self.post = postData
    }
    
    func getSummary() {
        DispatchQueue.main.async {
            if (self.post.postLiveData.showingSummary == false) {
                DispatchQueue.main.async {
                    
                    Task {
                        self.summary = try await self.client.api.posts.summerizePosts(postID: self.post.postData._id)
                        
//                        self.summary = summerization;
                        self.post.postLiveData.subAction = 5
                        self.post.postLiveData.showingSummary = true
                        self.post.postLiveData.actionExpanded = true
                    }
                    self.client.hapticPress()
                }
            } else {
                self.post.postLiveData.subAction = 0
                self.post.postLiveData.showingSummary = false
                self.post.postLiveData.actionExpanded = false
                self.client.hapticPress()
            }
        }
    }
    
    func getReplies() {
        DispatchQueue.main.async {
            self.client.hapticPress()
            if (self.loadingReplies || self.doneReplies) { print("already loading replies"); return }
            
            self.loadingReplies = true

            if (self.post.postData.totalReplies ?? 0 == 0) { self.failedReplies=true; print("no replies"); return }
            if (self.replies.replies!.count == self.post.postData.totalReplies ?? 0) { self.failedReplies=false; print("equal count replies"); return }
            print("got past")
            
            self.loadingReplies = true
            
            Task{
                do {
                    self.replies = try await self.client.api.posts.getReplies(postID: self.post.postData._id)
                    self.failedReplies = false
                    self.loadingReplies = false
                    self.doneReplies = true
                    self.client.hapticPress()
                    print("done loading")
                } catch {
                    print("Failed: \(error.localizedDescription)")
                    self.failedReplies = true
                    return;
                }
            }
        }
    }
    
    func getQuotes() {
        DispatchQueue.main.async {
            self.client.hapticPress()
            if (self.doneQuotes || self.loadingQuotes) { print("already loading quotes"); return }
            self.loadingQuotes = true

            if (self.post.postData.totalQuotes ?? 0 == 0) { self.failedQuotes=true; print("no quotes"); return }
            if (self.quotes.quotes!.count == self.post.postData.totalQuotes ?? 0) { self.failedQuotes=false; print("equal count quotes"); return }

            self.loadingQuotes = true
            
            Task{
                do {
                    self.quotes = try await self.client.api.posts.getQuotes(postID: self.post.postData._id)
                    self.failedQuotes = false
                    self.loadingQuotes = false
                    self.doneQuotes = true
                    self.client.hapticPress()
                } catch {
                    print("Failed: \(error.localizedDescription)")
                    self.failedQuotes = true
                    return;
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
