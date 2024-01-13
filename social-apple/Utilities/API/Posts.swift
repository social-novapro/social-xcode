//
//  Posts.swift
//  social-apple
//
//  Created by Daniel Kravec on 2023-11-19.
//

import Foundation

class PostsApi: API_Helper {
    func userLoginRequest(userLogin: UserLoginData, completion: @escaping (Result<UserLoginResponse, Error>) -> Void) {
        print("user login request")
        let APIUrl = baseAPIurl + "/auth/userLogin"
        self.requestData(urlString: APIUrl) { (result: Result<UserLoginResponse, Error>) in
            switch result {
            case .success(let userLoginData):
                print("Logged in")
                completion(.success(userLoginData))
            case .failure(let error):
                print("Error: \(error)")
            }
        }
    }
    
    func getUserFeed(userTokens: UserTokenData, completion: @escaping (Result<FeedV2Data, Error>) -> Void) {
        print("Getting all posts")
        let APIUrl = baseAPIurl + "/feeds/userFeed/v2"
        self.requestData(urlString: APIUrl) { (result: Result<FeedV2Data, Error>) in
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
        let APIUrl = baseAPIurl + "/feeds/userFeed/v2/" + index
        self.requestData(urlString: APIUrl) { (result: Result<FeedV2Data, Error>) in
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
        let APIUrl = baseAPIurl + "/feeds/userFeed"
        self.requestData(urlString: APIUrl) { (result: Result<[AllPosts], Error>) in
            switch result {
            case .success(let allPosts):
                completion(.success(allPosts.reversed()))
            case .failure(let error):
                print("Error: \(error)")
            }
        }
    }
    
    func createPost(postCreateContent: PostCreateContent, completion: @escaping (Result<PostData, Error>) -> Void) {
        print("Creating post")
        let APIUrl = baseAPIurl + "/posts/create"
        self.requestDataWithBody(urlString: APIUrl, httpMethod: "POST", httpBody: postCreateContent) { (result: Result<PostData, Error>) in
            switch result {
            case .success(let postData):
                print("Created Post")
                completion(.success(postData))
            case .failure(let error):
                print("Error: \(error)")
            }
        }
    }
    
    func likePost(postID: String, completion: @escaping (Result<PostData, Error>) -> Void) {
        print("liking post")

        let APIUrl = baseAPIurl + "/posts/like/\(postID)"
        self.requestData(urlString: APIUrl, httpMethod: "PUT") { (result: Result<PostData, Error>) in
            switch result {
            case .success(let postData):
                print("Liked Post")
                completion(.success(postData))
            case .failure(let error):
                print("Error: \(error)")
            }
        }
    }
    
    func unlikePost(postID: String, completion: @escaping (Result<PostData, Error>) -> Void) {
        print("unliking post")
        let APIUrl = baseAPIurl + "/posts/unlike/\(postID)"
        self.requestData(urlString: APIUrl, httpMethod: "DELETE") { (result: Result<PostData, Error>) in
            switch result {
            case .success(let postData):
                print("Unliked Post")
                completion(.success(postData))
            case .failure(let error):
                print("Error: \(error)")
            }
        }
    }
    
    func deletePost(postID: String, completion: @escaping (Result<PostDeleteRes, Error>) -> Void) {
        print("unliking post")
        let APIUrl = baseAPIurl + "/posts/remove/\(postID)"
        self.requestData(urlString: APIUrl, httpMethod: "DELETE") { (result: Result<PostDeleteRes, Error>) in
            switch result {
            case .success(let postData):
                print("Unliked Post")
                completion(.success(postData))
            case .failure(let error):
                print("Error: \(error)")
            }
        }
    }
}
