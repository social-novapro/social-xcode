//
//  Developer.swift
//  social-apple
//
//  Created by Daniel Kravec on 2024-01-16.
//

import Foundation

class DeveloperApi: API_Base {
    func getDeveloperData(completion: @escaping (Result<DeveloperResponseData, Error>) -> Void) {
        let APIUrl = baseAPIurl + "/get/developer"

        self.apiHelper.requestData(urlString: APIUrl) { (result: Result<DeveloperResponseData, Error>) in
            switch result {
            case .success(let developerData):
                print("dev data")
                completion(.success(developerData))
            case .failure(let error):
                print("Error: \(error)")
            }
        }
    }
    
    func newDev(completion: @escaping (Result<DeveloperTokenData, Error>) -> Void) {
        let APIUrl = baseAPIurl + "Priv/post/newDev"
        
        self.apiHelper.requestData(urlString: APIUrl) { (result: Result<DeveloperTokenData, Error>) in
            switch result {
            case .success(let developerData):
                print("dev data")
                completion(.success(developerData))
            case .failure(let error):
                print("Error: \(error)")
            }
        }
    }
    
    func newAppToken(newAppToken: NewAppTokenReq, completion: @escaping (Result<AppTokenData, Error>) -> Void) {
        let APIUrl = baseAPIurl + "Priv/post/newAppToken"
        
        self.apiHelper.requestDataWithBody(urlString: APIUrl, httpMethod: "POST", httpBody: newAppToken) { (result: Result<AppTokenData, Error>) in
            switch result {
            case .success(let appTokenData):
                print("app token data")
                completion(.success(appTokenData))
            case .failure(let error):
                print("Error: \(error)")
            }
        }
    }
}
