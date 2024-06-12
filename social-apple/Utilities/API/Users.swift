//
//  Users.swift
//  social-apple
//
//  Created by Daniel Kravec on 2023-11-19.
//

import Foundation

class UsersApi: API_Helper {
    var themes: UsersThemesAPI

    override init(userTokensProv: UserTokenData) {
        self.themes = UsersThemesAPI(userTokensProv: userTokensProv)
        super .init(userTokensProv: userTokensProv)
    }
    func getByID(userID: String, completion: @escaping (Result<UserData, Error>) -> Void) {
        print("user login request")
        let APIUrl = baseAPIurl + "/get/userByID/" + userID
        self.requestData(urlString: APIUrl) { (result: Result<UserData, Error>) in
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
        let APIUrl = baseAPIurl + "/get/user/" + userID
        self.requestData(urlString: APIUrl) { (result: Result<UserDataFull, Error>) in
            switch result {
            case .success(let userData):
                print("Logged in")
                completion(.success(userData))
            case .failure(let error):
                print("Error: \(error)")
            }
        }
    }

    
    func edit_pinsAdd(postID: String, completion: @escaping (Result<AllPosts, Error>) -> Void) {
        let APIUrl = baseAPIurl + "/users/edit/pins/" + postID
        self.requestData(urlString: APIUrl, httpMethod: "POST") { (result: Result<AllPosts, Error>) in
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
        self.requestData(urlString: APIUrl, httpMethod: "DELETE") { (result: Result<AllPosts, Error>) in
            switch result {
            case .success(let pinData):
                completion(.success(pinData))
            case .failure(let error):
                print("Error: \(error)")
            }
        }
    }
}
