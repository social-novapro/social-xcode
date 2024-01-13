//
//  Users.swift
//  social-apple
//
//  Created by Daniel Kravec on 2023-11-19.
//

import Foundation

class UsersApi: API_Helper {
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
}
