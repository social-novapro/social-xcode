//
//  AdminErrors.swift
//  social-apple
//
//  Created by Daniel Kravec on 2024-04-11.
//

import Foundation

class AdminErrorsApi: API_Base {
    func get(errorID: String, completion: @escaping (Result<ErrorIssueData, Error>) -> Void) {
        let APIUrl = baseAPIurl + "/admin/errors/" + errorID
        self.apiHelper.requestData(urlString: APIUrl) { (result: Result<ErrorIssueData, Error>) in
            switch result {
            case .success(let data):
                completion(.success(data))
            case .failure(let error):
                print("Error: \(error)")
            }
        }
    }
    
    func list(completion: @escaping (Result<ErrorIndexData, Error>) -> Void) {
        let APIUrl = baseAPIurl + "/admin/errors/list/"
        self.apiHelper.requestData(urlString: APIUrl) { (result: Result<ErrorIndexData, Error>) in
            switch result {
            case .success(let data):
                completion(.success(data))
            case .failure(let error):
                print("Error: \(error)")
            }
        }
    }
    
    func list(indexID: String, completion: @escaping (Result<ErrorIndexData, Error>) -> Void) {
        let APIUrl = baseAPIurl + "/admin/errors/list/" + indexID
        self.apiHelper.requestData(urlString: APIUrl) { (result: Result<ErrorIndexData, Error>) in
            switch result {
            case .success(let data):
                completion(.success(data))
            case .failure(let error):
                print("Error: \(error)")
            }
        }
    }
}
