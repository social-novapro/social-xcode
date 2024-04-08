//
//  Search.swift
//  social-apple
//
//  Created by Daniel Kravec on 2024-04-07.
//

import Foundation

class SearchApi: API_Helper {
    func searchRequest(lookup: SearchLookupData, completion: @escaping (Result<SearchFoundData, Error>) -> Void) {
        print("Request login")
        let lookupkey = ApiHeader(value: lookup.lookupkey, field: "lookupkey")
        let APIUrl = baseAPIurl + "/search/"
        
        self.requestData(urlString: APIUrl, errorType: "withAuth", httpHeaders: [lookupkey]) { (result: Result<SearchFoundData, Error>) in
            switch result {
            case .success(let userLoginData):
                completion(.success(userLoginData))
            case .failure(let error):
                print("Error: \(error)")
            }
        }
    }
    
    func searchSetting(completion: @escaping (Result<SearchSettingResponse, Error>) -> Void) {
        print("Request login")
        let APIUrl = baseAPIurl + "/search/setting"
        
        self.requestData(urlString: APIUrl) { (result: Result<SearchSettingResponse, Error>) in
            switch result {
            case .success(let searchSettingData):
                completion(.success(searchSettingData))
            case .failure(let error):
                print("Error: \(error)")
            }
        }
    }
    
    func changeSearchSetting(newSearch: String, completion: @escaping (Result<SearchSettingResponse, Error>) -> Void) {
        print("Request login")
        let APIUrl = baseAPIurl + "/search/setting"
        
        self.requestDataWithBody(urlString: APIUrl, httpMethod: "POST", httpBody: SearchSettingRequest(newSearch: newSearch)) { (result: Result<SearchSettingResponse, Error>) in
            switch result {
            case .success(let searchSettingData):
                completion(.success(searchSettingData))
            case .failure(let error):
                print("Error: \(error)")
            }
        }
    }
}
