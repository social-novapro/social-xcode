//
//  Users.swift
//  social-apple
//
//  Created by Daniel Kravec on 2023-11-19.
//

import Foundation

class UsersApi: API_Base {
    var themes: UsersThemesAPI

    override init(apiHelper: API_Helper) {
        self.themes = UsersThemesAPI(apiHelper: apiHelper)
        super .init(apiHelper: apiHelper)
    }
    func getByID(userID: String, completion: @escaping (Result<UserData, Error>) -> Void) {
        print("user login request")
        let APIUrl = baseAPIurl + "/users/get/basic/" + userID
        self.apiHelper.requestData(urlString: APIUrl) { (result: Result<UserData, Error>) in
            switch result {
            case .success(let userData):
                print("Logged in")
                completion(.success(userData))
            case .failure(let error):
                print("Error: \(error)")
            }
        }
    }
    func getUser(userID: String, completion: @escaping (Result<UserDataFull, Error>) -> Void) {
        print("user login request")
        let APIUrl = baseAPIurl + "/users/get/" + userID
        self.apiHelper.requestData(urlString: APIUrl) { (result: Result<UserDataFull, Error>) in
            switch result {
            case .success(let userData):
                print("Logged in")
                completion(.success(userData))
            case .failure(let error):
                print("Error: \(error)")
            }
        }
    }
    
    func getNextUserPostIndex(indexID: String) async throws -> UserIndexDataRes {
        do {
            let APIUrl = baseAPIurl + "/users/get/userPosts/" + indexID
            
            let data:UserIndexDataRes = try await apiHelper.asyncRequestData(urlString: APIUrl, httpMethod: "GET");
            return data;
        } catch {
            print(error)
            throw ErrorData(code: "Z001", msg: "Uknown", error: true)
        }
    }
    
    func followingFollowerList(userID: String, type: Int, indexID: String? = nil) async throws -> UserFollowListData {
        //
        var doList:String = "following"
        if (type == 0) {
            doList = "following"
        } else if (type == 1) {
            doList = "followers"
        }
        
        do {
            print("doing \(doList)")
            var APIUrl = baseAPIurl + "/users/\(doList)/\(userID)/"
            if (indexID != nil) {
                APIUrl += indexID!
            }
            
            let data:UserFollowListData = try await apiHelper.asyncRequestData(urlString: APIUrl, httpMethod: "GET");
//            print(data)
            return data;
        } catch {
            print(error)
            throw ErrorData(code: "Z001", msg: "Uknown", error: true)
        }
    }

    
    func edit_pinsAdd(postID: String, completion: @escaping (Result<AllPosts, Error>) -> Void) {
        let APIUrl = baseAPIurl + "/users/edit/pins/" + postID
        self.apiHelper.requestData(urlString: APIUrl, httpMethod: "POST") { (result: Result<AllPosts, Error>) in
            switch result {
                
            case .success(let pinData):
                completion(.success(pinData))
            case .failure(let error):
                print("Error: \(error)")
            }
        }
    }
    
    func edit_pinsRemove(postID: String, completion: @escaping (Result<AllPosts, Error>) -> Void) {
        let APIUrl = baseAPIurl + "/users/edit/pins/" + postID
        self.apiHelper.requestData(urlString: APIUrl, httpMethod: "DELETE") { (result: Result<AllPosts, Error>) in
            switch result {
            case .success(let pinData):
                completion(.success(pinData))
            case .failure(let error):
                print("Error: \(error)")
            }
        }
    }
    
    func followUser(userID: String) async throws -> UserFollowData {
        do {
            let data:UserFollowData = try await apiHelper.asyncRequestData(urlString: "\(baseAPIurl)/users/follow/\(userID)", httpMethod: "POST");
            return data;
        } catch {
            throw error
        }
    }
    
    func unFollowUser(userID: String) async throws -> UserFollowData {
        do {
            let data:UserFollowData = try await apiHelper.asyncRequestData(urlString: "\(baseAPIurl)/users/unfollow/\(userID)", httpMethod: "DELETE");
            return data;
        } catch {
            throw error;
        }
    }
    func getUserEdit() async throws -> [UserEditChangeResponse] {
        do {
            let data:[UserEditChangeResponse] = try await apiHelper.asyncRequestData(urlString: "\(baseAPIurl)/users/update", httpMethod: "GET");
            return data;
        } catch {
            throw error;
        }
    }
    
    func userEdit(userEditReq: [HttpReqKeyValue]) async throws -> UserEditResponse {
        do {
            let data:UserEditResponse = try await apiHelper.asyncRequestDataKeyMap(urlString: "\(baseAPIurl)/users/update", httpMethod: "POST", httpKeyMap: userEditReq)
            print(data)
            return data;
        } catch {
            throw error;
        }
    }
}
