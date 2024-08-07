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
    @Published var mentionData: [AllPosts] = []
    @Published var userDataFull: UserDataFull?
    @Published var followed: Bool = false
    
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
        client.users.getUser(userID: self.userID) { result in
            switch result {
            case .success(let results):
                print("Updating results")
                DispatchQueue.main.async {
                    self.followed = results.extraData?.followed ?? false
                    self.userDataFull = results;
                    self.userData = results.userData;
                    self.postData = results.postData.reversed();
                    self.pinData = results.pinData.reversed();
                    self.badgeData = results.badgeData?.reversed() ?? []
                    self.mentionData = results.mentionData?.reversed() ?? []
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
    var followed: Bool? = nil
    
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
        case followed
    }
}


struct UserDataFull: Decodable, Identifiable {
    var id = UUID()

    var included: UserIncluded
    var userData: UserData
    var postData: [AllPosts]
    var pinData: [AllPosts]
    var badgeData: [BadgeData]?
    var mentionData: [AllPosts]?
    var extraData: UserExtraData?
    
    private enum CodingKeys: String, CodingKey {
        case included
        case userData
        case postData
        case pinData
        case badgeData
        case mentionData
        case extraData
    }
}
struct UserExtraData: Decodable {
    var followed: Bool
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

/*
 {
   "_id": "e8b85ea2-cbda-4eee-97ca-ed0cb069fbcd",
   "timestamp": 1722458728039,
   "current": true,
   "userID": "6ceae342-2ca2-48ec-8ce3-0e39caebe989",
   "followedUserID": "fa7f424d-9cd9-4818-a4bf-670d3da2a174",
   "indexFollowingID": "6fd32f05-5a43-4408-82c7-6fa4617f7a87",
   "indexFollowersID": "f1ef58f0-a0ea-4d1d-a38d-e13d59c5927b",
   "__v": 0
 }
 */

struct UserFollowData: Decodable, Encodable {
    let _id: String
    let timestamp: Int64
    let current: Bool
    let userID: String
    let followedUserID: String
    let indexFollowingID: String
    let indexFollowersID: String
}

struct UserFollowDataList: Decodable, Encodable, Identifiable {
    var id = UUID()
    let followData: UserFollowData
    let userData: UserData
    
    private enum CodingKeys: String, CodingKey {
        case followData
        case userData
    }
}

struct UserFollowListData: Decodable, Encodable {
    let found: Bool
    let followIndexID: String
    let prevIndexID: String?
    let nextIndexID: String?
    let timestamp: Int64
    let current: Bool
    let type: Int
    let userID: String
    let userData: UserData
    let amount: Int
    let includedIndexes: [String]
    let follows: [UserFollowData]
}
