//
//  SearchData.swift
//  social-apple
//
//  Created by Daniel Kravec on 2024-04-07.
//

import Foundation

class SearchClass: ObservableObject {
    var client: Client
    @Published var searchText: String = ""
    @Published var searchResults: SearchFoundData = SearchFoundData()
    @Published var foundData: Bool = false

    init(client: Client) {
        self.client = client
    }
            
    func search(newValue: String) {
        if (newValue == "") {
            DispatchQueue.main.async {
                self.foundData = false;
            }
            return;
        }
        
        client.api.search.searchRequest(lookup: SearchLookupData(lookupkey: newValue)) { result in
            switch result {
            case .success(let results):
                if (newValue != self.searchText) {
                    return;
                } else {
                    DispatchQueue.main.async {
                        self.searchResults = results
                        self.searchResults.postsFound = self.searchResults.postsFound?.reversed()
                        self.foundData = true
                    }
                }
            case .failure(let error):
                print("Error: \(error.localizedDescription)")
            }
        }
    }
}

struct SearchLookupData: Encodable {
    var lookupkey: String
}

struct SearchFoundData: Decodable {
    var usersFound: [UserData]? = []
    var postsFound: [AllPosts]? = []
    var tagsFound: [TagFoundData]? = []
    var hashtagsFound: [TagPotentialData]? = []
}

struct SearchPossibleTags : Decodable {
    var hashtags: [TagPotentialData]? = []
    var users: [UserPotentialData]? = []
    var found: Bool? = false
}

struct UserPotentialData: Identifiable, Decodable {
    var id = UUID()
    var possibility: String
    var user: UserData
    
    private enum CodingKeys: String, CodingKey {
        case possibility
        case user
    }
}

struct SearchSettingResponse: Decodable {
    var userID: String
    var possibleSearch: [PossibleSearchVersion]
    var currentSearch: SearchUserSetting
}

struct SearchUserSetting: Decodable {
    var _id: String // userID
    var timestamp: Int64
    var preferredSearch: String
}

struct PossibleSearchVersion: Identifiable, Decodable {
    var id = UUID()
    
    var name: String
    var niceName: String
    var description: String
    var version: Int32
    
    private enum CodingKeys: String, CodingKey {
        case name
        case niceName
        case description
        case version
    }
}

struct SearchSettingRequest: Encodable {
    var newSearch: String
}
