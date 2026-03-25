//
//  Search.swift
//  social-apple
//
//  Created by Daniel Kravec on 2024-04-07.
//

import Foundation

class SearchApi: API_Base {
    private enum Route {
        static let search = "/search/v2"
        static let exploreV2 = "/search/v2/explore"
        static let setting = "/search/setting"
        static func tags(_ value: String) -> String { "/search/tags/" + value }
    }

    func searchRequest(lookup: SearchLookupData, completion: @escaping (Result<SearchFoundData, Error>) -> Void) {
        print("Request login")
        let lookupkey = ApiHeader(value: lookup.lookupkey, field: "lookupkey")
        let APIUrl = baseAPIurl + Route.search
        
        self.apiHelper.requestData(urlString: APIUrl, errorType: "withAuth", httpHeaders: [lookupkey]) { (result: Result<SearchFoundData, Error>) in
            switch result {
            case .success(let userLoginData):
                completion(.success(userLoginData))
            case .failure(let error):
                print("Error: \(error)")
                completion(.failure(error))
            }
        }
    }

    func getExploreV2(completion: @escaping (Result<SearchFoundData, Error>) -> Void) {
        let APIUrl = baseAPIurl + Route.exploreV2

        self.apiHelper.requestData(urlString: APIUrl, httpMethod: "GET") { (result: Result<SearchFoundData, Error>) in
            switch result {
            case .success(let data):
                completion(.success(data))
            case .failure(let error):
                print("Error: \(error)")
                completion(.failure(error))
            }
        }
    }

    func searchSetting(completion: @escaping (Result<SearchSettingResponse, Error>) -> Void) {
        print("Request login")
        let APIUrl = baseAPIurl + Route.setting
        
        self.apiHelper.requestData(urlString: APIUrl) { (result: Result<SearchSettingResponse, Error>) in
            switch result {
            case .success(let searchSettingData):
                completion(.success(searchSettingData))
            case .failure(let error):
                print("Error: \(error)")
                completion(.failure(error))
            }
        }
    }
    
    func changeSearchSetting(newSearch: String, completion: @escaping (Result<SearchSettingResponse, Error>) -> Void) {
        print("Request login")
        let APIUrl = baseAPIurl + Route.setting
        
        self.apiHelper.requestDataWithBody(urlString: APIUrl, httpMethod: "POST", httpBody: SearchSettingRequest(newSearch: newSearch)) { (result: Result<SearchSettingResponse, Error>) in
            switch result {
            case .success(let searchSettingData):
                completion(.success(searchSettingData))
            case .failure(let error):
                print("Error: \(error)")
                completion(.failure(error))
            }
        }
    }
    
    func searchTagSuggestion(searchText: String, completion: @escaping (Result<SearchPossibleTags, Error>) -> Void) {
        print("Request login")
        var searchTextReplace = searchText
        if (searchText.starts(with: "@")){
            searchTextReplace = searchText.replacingOccurrences(of: "@", with: "0")
        }
        else if (searchText.starts(with: "#")){
            searchTextReplace = searchText.replacingOccurrences(of: "#", with: "1")
        }
        
        let APIUrl = baseAPIurl + Route.tags(searchTextReplace)
        
        self.apiHelper.requestData(urlString: APIUrl, httpMethod: "GET") { (result: Result<SearchPossibleTags, Error>) in
            switch result {
            case .success(let seachTags):
                completion(.success(seachTags))
            case .failure(let error):
                print("Error: \(error)")
                completion(.failure(error))
            }
        }
    }
}
