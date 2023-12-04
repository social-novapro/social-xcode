//
//  Auth.swift
//  social-apple
//
//  Created by Daniel Kravec on 2023-11-19.
//

import Foundation

class AuthApi: API_Helper {
    func userLoginRequest(userLogin: UserLoginData, completion: @escaping (Result<UserLoginResponse, Error>) -> Void) {
        print("Request login")
        let username = ApiHeader(value: userLogin.username, field: "username")
        let password = ApiHeader(value: userLogin.password, field: "password")
        
        let APIUrl = baseAPIurl + "/auth/userLogin"
        self.requestData(urlString: APIUrl, errorType: "withAuth", httpHeaders: [username, password]) { (result: Result<UserLoginResponse, Error>) in
            switch result {
            case .success(let userLoginData):
                completion(.success(userLoginData))
            case .failure(let error):
                print("Error: \(error)")
            }
        }
    }
    func userCreateRequest(userCreate: UserCreateData, completion: @escaping (Result<UserLoginResponse, Error>) -> Void) {
        print("Request create user")

        let APIUrl = baseAPIurl + "Priv/post/newUser"
        self.requestDataWithBody(urlString: APIUrl, httpMethod: "post", httpBody: userCreate) { (result: Result<UserLoginResponse, Error>) in
            switch result {
            case .success(let userLoginData):
                completion(.success(userLoginData))
            case .failure(let error):
                print("Error: \(error)")
            }
        }
    }
}
