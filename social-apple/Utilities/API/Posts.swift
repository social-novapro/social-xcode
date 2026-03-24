//
//  Posts.swift
//  social-apple
//
//  Created by Daniel Kravec on 2023-11-19.
//

import Foundation

class PostsApi: API_Base {
    private enum Route {
        static let userFeedV2 = "/feeds/userFeed/v2"
        static func userFeedV2Index(_ index: String) -> String { "/feeds/userFeed/v2/" + index }
        static let userFeed = "/feeds/userFeed"
        static let create = "/posts/create"
        static func like(_ postID: String) -> String { "/posts/like/\(postID)" }
        static func unlike(_ postID: String) -> String { "/posts/unlike/\(postID)" }
        static func likes(_ postID: String) -> String { "/posts/likes/\(postID)" }
        static func replies(_ postID: String) -> String { "/posts/replies/full/\(postID)" }
        static func quotes(_ postID: String) -> String { "/posts/quotes/full/\(postID)" }
        static func edits(_ postID: String) -> String { "/posts/edits/\(postID)" }
        static let edit = "/posts/edit/"
        static func remove(_ postID: String) -> String { "/posts/remove/\(postID)" }
        static let save = "/posts/save/"
        static let unsave = "/posts/unsave/"
        static func copostApprove(_ requestID: String) -> String { "/posts/coposts/approve/\(requestID)" }
        static func copostDecline(_ requestID: String) -> String { "/posts/coposts/decline/\(requestID)" }
        static let copostRequests = "/posts/coposts/requests/"
        static let aiSummary = "/ai/summary/"
    }

    func getUserFeed(userTokens: UserTokenData, completion: @escaping (Result<FeedV2Data, Error>) -> Void) {
        print("Getting all posts")
        let APIUrl = baseAPIurl + Route.userFeedV2
        self.apiHelper.requestData(urlString: APIUrl) { (result: Result<FeedV2Data, Error>) in
            switch result {
            case .success(var allPosts):
                let reversed:[AllPosts] = allPosts.posts.reversed()
                allPosts.posts = reversed
                completion(.success(allPosts))
            case .failure(let error):
                print("Error: \(error)")
            }
        }
    }
    
    func getUserFeedIndex(userTokens: UserTokenData, index: String, completion: @escaping (Result<FeedV2Data, Error>) -> Void) {
        print("Getting all posts")
        let APIUrl = baseAPIurl + Route.userFeedV2Index(index)
        self.apiHelper.requestData(urlString: APIUrl) { (result: Result<FeedV2Data, Error>) in
            switch result {
            case .success(var allPosts):
                let reversed:[AllPosts] = allPosts.posts.reversed()
                allPosts.posts = reversed
                completion(.success(allPosts))
            case .failure(let error):
                print("Error: \(error)")
            }
        }
    }
    
    func getAllPosts(userTokens: UserTokenData, completion: @escaping (Result<[AllPosts], Error>) -> Void) {
        print("Getting all posts")
        let APIUrl = baseAPIurl + Route.userFeed
        self.apiHelper.requestData(urlString: APIUrl) { (result: Result<[AllPosts], Error>) in
            switch result {
            case .success(let allPosts):
                completion(.success(allPosts.reversed()))
            case .failure(let error):
                print("Error: \(error)")
            }
        }
    }
    
    func createPostV2(postCreateContent: PostCreateContent) async throws -> PostData {
        print("Creating post")
        let APIUrl = baseAPIurl + Route.create

        do {
            let data:PostData = try await apiHelper.asyncRequestDataBody(urlString: APIUrl, httpMethod: "POST", httpBody: postCreateContent);
            print("Created Post")

            return data;
        } catch {
            print("Error: \(error)")
            throw ErrorData(code: "Z001", msg: "Uknown", error: true)
        }
    }
    
    func createPost(postCreateContent: PostCreateContent, completion: @escaping (Result<PostData, Error>) -> Void) {
        print("Creating post")
        let APIUrl = baseAPIurl + Route.create
        self.apiHelper.requestDataWithBody(urlString: APIUrl, httpMethod: "POST", httpBody: postCreateContent) { (result: Result<PostData, Error>) in
            switch result {
            case .success(let postData):
                print("Created Post")
                completion(.success(postData))
            case .failure(let error):
                print("Error: \(error)")
            }
        }
    }
    
    // like post
    func likePost(postID: String, completion: @escaping (Result<PostData, Error>) -> Void) {
        print("liking post")

        let APIUrl = baseAPIurl + Route.like(postID)
        self.apiHelper.requestData(urlString: APIUrl, httpMethod: "PUT") { (result: Result<PostData, Error>) in
            switch result {
            case .success(let postData):
                print("Liked Post")
                completion(.success(postData))
            case .failure(let error):
                print("Error: \(error)")
            }
        }
    }
    
    // unlike post
    func unlikePost(postID: String, completion: @escaping (Result<PostData, Error>) -> Void) {
        print("unliking post")
        let APIUrl = baseAPIurl + Route.unlike(postID)
        self.apiHelper.requestData(urlString: APIUrl, httpMethod: "DELETE") { (result: Result<PostData, Error>) in
            switch result {
            case .success(let postData):
                print("Unliked Post")
                completion(.success(postData))
            case .failure(let error):
                print("Error: \(error)")
            }
        }
    }
    
    // get post likes
    func getLikes(postID: String, completion: @escaping (Result<PostLikesRes, Error>) -> Void) {
        print("likes of post")
        let APIUrl = baseAPIurl + Route.likes(postID)
        self.apiHelper.requestData(urlString: APIUrl, httpMethod: "GET") { (result: Result<PostLikesRes, Error>) in
            switch result {
            case .success(let postData):
                print("Unliked Post")
                completion(.success(postData))
            case .failure(let error):
                completion(.failure(error))
                print("Error: \(error)")
            }
        }
    }
    
    
    // get post replies
    func getReplies(postID: String) async throws -> PostReplyResV2 {
        print("replies of post")
        let APIUrl = baseAPIurl + Route.replies(postID)
        
        do {
            let data:PostReplyResV2 = try await apiHelper.asyncRequestData(urlString: APIUrl, httpMethod: "GET");
            return data;
        } catch {
            print(error)
            throw ErrorData(code: "Z001", msg: "Uknown", error: true)
        }
    }
    
    // get post replies
    func getQuotes(postID: String) async throws -> PostQuoteResV2 {
        print("quotes of post")
        let APIUrl = baseAPIurl + Route.quotes(postID)
        
        do {
            let data:PostQuoteResV2 = try await apiHelper.asyncRequestData(urlString: APIUrl, httpMethod: "GET");
            return data;
        } catch {
            print(error)
            throw ErrorData(code: "Z001", msg: "Uknown", error: true)
        }
    }
    
    // get post edits
    func getEdits(postID: String, completion: @escaping (Result<PostEditSchema, Error>) -> Void) {
        print("edits of post")
        let APIUrl = baseAPIurl + Route.edits(postID)
        self.apiHelper.requestData(urlString: APIUrl, httpMethod: "GET") { (result: Result<PostEditSchema, Error>) in
            switch result {
            case .success(let postData):
                print("edits Post")
                completion(.success(postData))
            case .failure(let error):
                completion(.failure(error))
                print("Error: \(error)")
            }
        }
    }
    
    // edit post
    func editPost(postID: String, newContent: String, completion: @escaping (Result<PostEditRes, Error>) -> Void) {
        print("edit post")
        let APIUrl = baseAPIurl + Route.edit
        self.apiHelper.requestDataWithBody(urlString: APIUrl, httpMethod: "PUT", httpBody: PostEditReq(postID: postID, content: newContent)) { (result: Result<PostEditRes, Error>) in
            switch result {
            case .success(let postData):
                print("edits Post")
                completion(.success(postData))
            case .failure(let error):
                completion(.failure(error))
                print("Error: \(error)")
            }
        }
    }
    
    // delete post
    func deletePost(postID: String, completion: @escaping (Result<PostDeleteRes, Error>) -> Void) {
        print("unliking post")
        let APIUrl = baseAPIurl + Route.remove(postID)
        self.apiHelper.requestData(urlString: APIUrl, httpMethod: "DELETE") { (result: Result<PostDeleteRes, Error>) in
            switch result {
            case .success(let postData):
                print("Unliked Post")
                completion(.success(postData))
            case .failure(let error):
                print("Error: \(error)")
            }
        }
    }
    
    // add to bookmarks
    func savePost(bookmarkData: PostBookmarkReq, completion: @escaping (Result<PostBookmarkRes, Error>) -> Void) {
        let APIUrl = baseAPIurl + Route.save
        self.apiHelper.requestDataWithBody(urlString: APIUrl, httpMethod: "POST", httpBody: bookmarkData) { (result: Result<PostBookmarkRes, Error>) in
            switch result {
            case .success(let postData):
                print("Unliked Post")
                completion(.success(postData))
            case .failure(let error):
                print("Error: \(error)")
            }
        }
    }
    
    // remove from bookmark
    func unsavePost(bookmarkData: PostBookmarkReq, completion: @escaping (Result<PostUnbookmarkRes, Error>) -> Void) {
        let APIUrl = baseAPIurl + Route.unsave
        self.apiHelper.requestDataWithBody(urlString: APIUrl, httpMethod: "DELETE", httpBody: bookmarkData) { (result: Result<PostUnbookmarkRes, Error>) in
            switch result {
            case .success(let postData):
                print("Unliked Post")
                completion(.success(postData))
            case .failure(let error):
                print("Error: \(error)")
            }
        }
    }
    
    // coposts - approve
    func copostsApprove(requestID: String) async throws -> CopostRequestData {
        do {
            let data:CopostRequestData = try await apiHelper.asyncRequestData(urlString: baseAPIurl + Route.copostApprove(requestID), httpMethod: "POST")
            print(data)
            return data;
        } catch {
            throw error;
        }
    }

    
    // coposts - decline
    func copostsDecline(requestID: String) async throws -> CopostRequestData {
        do {
            let data:CopostRequestData = try await apiHelper.asyncRequestData(urlString: baseAPIurl + Route.copostDecline(requestID), httpMethod: "DELETE")
            print(data)
            return data;
        } catch {
            throw error;
        }
    }

    // coposts - requests
    func copostsRequests() async throws -> [CopostRequestsData] {
        do {
            let data:[CopostRequestsData] = try await apiHelper.asyncRequestData(urlString: baseAPIurl + Route.copostRequests, httpMethod: "GET")
            print(data)
            return data;
        } catch {
            throw error;
        }
    }

    func summerizePosts(postID: String) async throws -> SummerizeResponseData {
        print("summarizing")
        do {
            let data:SummerizeResponseData = try await apiHelper.asyncRequestData(urlString: baseAPIurl + Route.aiSummary + postID, httpMethod: "GET")
            print(data);
            return data;
        } catch {
            throw error;
        }
    }
}
