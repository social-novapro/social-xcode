//
//  Developer.swift
//  social-apple
//
//  Created by Daniel Kravec on 2024-01-16.
//

import Foundation

class DeveloperApi: API_Helper {
    func getDeveloperData(completion: @escaping (Result<DeveloperResponseData, Error>) -> Void) {
        let APIUrl = baseAPIurl + "/get/developer"

        self.requestData(urlString: APIUrl) { (result: Result<DeveloperResponseData, Error>) in
            switch result {
            case .success(let developerData):
                print("dev data")
                completion(.success(developerData))
            case .failure(let error):
                print("Error: \(error)")
            }
        }
    }
}
