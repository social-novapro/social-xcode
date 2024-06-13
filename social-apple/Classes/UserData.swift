//
//  UserData.swift
//  social-apple
//
//  Created by Daniel Kravec on 2023-04-19.
//

import Foundation

class ProfileViewClass: ObservableObject {
    var client: ApiClient
    @Published var userID: String
    @Published var userData: UserData?
    
    @Published var postData: [AllPosts] = []
    @Published var pinData: [AllPosts] = []
    @Published var badgeData: [BadgeData] = []
    @Published var userDataFull: UserDataFull?
    
    @Published var doneLoading: Bool = false
    @Published var possibleFail: Bool = false

    init(client: ApiClient, userData: UserData?, userID: String?) {
        self.client = client
        self.userID = userID ?? client.userTokens.userID
        self.userData = userData ?? nil

//        client.users.getUser(userID: userID ?? client.userTokens.userID) { result in
//            switch result {
//            case .success(let results):
//                DispatchQueue.main.async {
//                    self.userDataFull = results;
//                    self.userData = results.userData;
//                    self.postData = results.postData;
//                    self.pinData = results.pinData;
//                    self.badgeData = results.badgeData ?? []
//                    self.doneLoading = true
//                    self.possibleFail = false
//                }
//                print(results)
//            case .failure(let error):
//                print("Error: \(error.localizedDescription)")
//            }
//        }
//        
//        DispatchQueue.main.async {
//            self.possibleFail = true;
//        }
    }
    
    func provBasic(userData: UserData) {
        self.userData = userData
    }
    
    func ready() {
//        self.client = client
//        self.userID = userID ?? client.userTokens.userID

        client.users.getUser(userID: self.userID) { result in
            switch result {
            case .success(let results):
                DispatchQueue.main.async {
                    self.userDataFull = results;
                    self.userData = results.userData;
                    self.postData = results.postData.reversed();
                    self.pinData = results.pinData.reversed();
                    self.badgeData = results.badgeData?.reversed() ?? []
                    self.doneLoading = true
                    self.possibleFail = false
                }
                
                print(results)
            case .failure(let error):
                print("Error: \(error.localizedDescription)")
            }
        }
        
        DispatchQueue.main.async {
            self.possibleFail = true;
        }
    }
}

struct UserData: Decodable, Encodable, Identifiable {
    var id = UUID()
    var _id: String? = nil
    var __v: Int64? = nil
    var creationTimestamp: Int64? = nil
    var description: String? = nil
    var displayName: String? = nil
    var followerCount: Int64? = nil
    var followingCount: Int64? = nil
    var lastEditDisplayname: Int64? = nil
    var lastEditUsername: Int64? = nil
    var likeCount: Int64? = nil
    var likedCount: Int64? = nil
    var pronouns: String? = nil
    var statusTitle: String? = nil
    var totalPosts: Int64? = nil
    var totalReplies: Int64? = nil
    var totalQuotes: Int64? = nil
    var username: String? = nil
    var verified: Bool? = nil
    
    private enum CodingKeys: String, CodingKey {
        case _id
        case __v
        case creationTimestamp
        case description
        case displayName
        case followerCount
        case followingCount
        case lastEditDisplayname
        case lastEditUsername
        case likeCount
        case likedCount
        case pronouns
        case statusTitle
        case totalPosts
        case totalReplies
        case totalQuotes
        case username
        case verified
    }
}


struct UserDataFull: Decodable, Identifiable {
    var id = UUID()

    var included: UserIncluded
    var userData: UserData
    var postData: [AllPosts]
    var pinData: [AllPosts]
    var badgeData: [BadgeData]?
    
    private enum CodingKeys: String, CodingKey {
        case included
        case userData
        case postData
        case pinData
        case badgeData
    }
}

struct UserIncluded: Decodable {
    var user: String
    var posts: String
    var pins: Bool
    var badges: Bool
}

struct BadgeData: Decodable {
    var id: String
    var name: String
    var description: String
    var count: Int64
    var showCount: Bool
    var achieved: Int64
    var latest: Int64?
    var info: BadgeInfoData
}

struct BadgeInfoData: Decodable {
    var technical_description: String
    var date_achieved: String
    var version_introduced: String
    var multiple_count: Bool
}
