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
    @Published var isLoading: Bool = false
    @Published var errorText: String?
    @Published var exploreResults: SearchFoundData = SearchFoundData()
    @Published var searchResults: SearchFoundData = SearchFoundData()
    @Published var foundData: Bool = false
    private var debounceWorkItem: DispatchWorkItem?

    init(client: Client) {
        self.client = client
        self.loadExplore()
    }

    func loadExplore() {
        DispatchQueue.main.async {
            self.isLoading = true
            self.errorText = nil
        }

        client.api.search.getExploreV2 { result in
            switch result {
            case .success(let results):
                DispatchQueue.main.async {
                    self.exploreResults = results
                    self.isLoading = false
                }
            case .failure(let error):
                DispatchQueue.main.async {
                    self.errorText = error.localizedDescription
                    self.isLoading = false
                }
            }
        }
    }

    func onSearchTextChanged(_ newValue: String) {
        debounceWorkItem?.cancel()

        let trimmed = newValue.trimmingCharacters(in: .whitespacesAndNewlines)
        if trimmed.isEmpty {
            DispatchQueue.main.async {
                self.foundData = false
                self.searchResults = SearchFoundData()
                self.errorText = nil
                self.isLoading = false
            }
            return
        }

        let work = DispatchWorkItem { [weak self] in
            self?.runSearch(query: trimmed)
        }
        debounceWorkItem = work
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.35, execute: work)
    }

    private func runSearch(query: String) {
        DispatchQueue.main.async {
            self.isLoading = true
            self.errorText = nil
        }

        client.api.search.searchRequest(lookup: SearchLookupData(lookupkey: query)) { result in
            switch result {
            case .success(let results):
                DispatchQueue.main.async {
                    guard self.searchText.trimmingCharacters(in: .whitespacesAndNewlines) == query else {
                        return
                    }
                    self.searchResults = results
                    self.foundData = true
                    self.isLoading = false
                }
            case .failure(let error):
                DispatchQueue.main.async {
                    guard self.searchText.trimmingCharacters(in: .whitespacesAndNewlines) == query else {
                        return
                    }
                    self.errorText = error.localizedDescription
                    self.isLoading = false
                }
            }
        }
    }

    func setFollow(userID: String, followed: Bool, inSearchResults: Bool) {
        if inSearchResults {
            guard var users = searchResults.usersFound else { return }
            if let index = users.firstIndex(where: { $0._id == userID }) {
                users[index].followed = followed
                DispatchQueue.main.async {
                    self.searchResults.usersFound = users
                }
            }
            return
        }

        guard var users = exploreResults.usersFound else { return }
        if let index = users.firstIndex(where: { $0._id == userID }) {
            users[index].followed = followed
            DispatchQueue.main.async {
                self.exploreResults.usersFound = users
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
    var hashtagsFound: [SearchV2HashtagData]? = []
}

struct SearchPossibleTags : Decodable {
    var hashtags: [TagPotentialData]? = []
    var users: [UserPotentialData]? = []
    var found: Bool? = false
}

struct SearchV2HashtagData: Identifiable, Decodable {
    var id: String { displayText }
    var tagText: String?
    var tag: String?
    var count: Int?
    
    var displayText: String {
        tagText ?? tag ?? ""
    }

    private enum CodingKeys: String, CodingKey {
        case tagText
        case tag
        case count
    }
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
