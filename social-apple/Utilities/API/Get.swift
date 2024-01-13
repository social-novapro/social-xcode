//
//  Get.swift
//  social-apple
//
//  Created by Daniel Kravec on 2024-01-12.
//

import Foundation

class GetApi: API_Helper {
    func searchRequest(lookup: SearchLookupData, completion: @escaping (Result<SearchFoundData, Error>) -> Void) {
        print("Request login")
        let lookupkey = ApiHeader(value: lookup.lookupkey, field: "lookupkey")
        let APIUrl = baseAPIurl + "/get/search"
        
        self.requestData(urlString: APIUrl, errorType: "withAuth", httpHeaders: [lookupkey]) { (result: Result<SearchFoundData, Error>) in
            switch result {
            case .success(let userLoginData):
                completion(.success(userLoginData))
            case .failure(let error):
                print("Error: \(error)")
            }
        }
    }
}
