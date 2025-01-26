//
//  UserData.swift
//  social-apple
//
//  Created by Daniel Kravec on 2023-04-19.
//

import Foundation


class ProfileViewClass: ObservableObject {
    var client: Client
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
    @Published var isClient: Bool = false

    @Published var loadingNextIndex: Bool = false
    @Published var userPostIndexData: UserPostIndexData?
    
    init(client: Client, userData: UserData?, userID: String?) {
        self.client = client
        self.userID = userID ?? client.userTokens.userID
        self.userData = userData ?? nil
        if (userData?._id == client.userTokens.userID) {
            isClient = true;
        } else {
            isClient = false;
        }
    }
    
    func provBasic(userData: UserData) {
        self.userData = userData
        if (userData._id == client.userTokens.userID) {
            isClient = true;
        } else {
            isClient = false;
        }
    }
    
    func ready() {
        // check cache
        client.api.users.getUser(userID: self.userID) { result in
            switch result {
            case .success(let results):
                print("Updating results")
                DispatchQueue.main.async {
                    self.followed = results.extraData?.followed ?? false
                    self.userDataFull = results;
                    self.userData = results.userData;
//                    self.postData = results.postData.reversed();
                    self.addPosts(newPosts: results.postData.reversed())
                    self.pinData = results.pinData.reversed();
                    self.badgeData = results.badgeData?.reversed() ?? []
                    self.mentionData = results.mentionData?.reversed() ?? []
                    self.doneLoading = true
                    self.possibleFail = false

                    self.userPostIndexData = results.userPostIndexData ?? nil;
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
    
    func nextUserPostsIndex() {
        if (self.loadingNextIndex == true) {return;}

        DispatchQueue.main.async {
            self.client.hapticPress()
            
            if (
                (self.userPostIndexData == nil) ||
                (self.userPostIndexData?.indexID == nil) ||
                (self.userPostIndexData?.prevIndexID == nil)
            ) {
                print("no index data", self.userPostIndexData as Any)
                return;
            }
            
            // need to do here, because it still thinks its loading if it exits early
            self.loadingNextIndex = true
            var myIndexData:UserIndexDataRes?
            
            Task{
                do {
                    myIndexData = try await self.client.api.users.getNextUserPostIndex(indexID:(self.userPostIndexData?.prevIndexID)!)// { result in
                    
                    self.userPostIndexData = myIndexData?.index ?? nil;
                    self.addPosts(newPosts: myIndexData?.posts ?? [])
                    
                    self.loadingNextIndex = false
                    self.client.hapticPress()
                } catch {
                    self.loadingNextIndex = false
                    print("Failed get user index: \(error.localizedDescription)")
                    return;
                }
            }
        }
    }
    
    // copied from PostData.swift
    func addPosts(newPosts: [AllPosts], toClear:Bool=false) -> Void {
        DispatchQueue.main.async {
            // due to new posts showing at bottom
            // could change that and fix it needing to be clear
            if (toClear==true) {
                self.postData = []
            }
            
            for var newPost in newPosts {
                if newPost.postData.userID == self.client.userTokens.userID {
                    newPost.postLiveData.isOwner = true
                }
                
                // this isnt working, will need to figure out, only in case of bad index going to server or getting from
//                if let existingIndex = self.postData.firstIndex(where: { $0.postData._id == newPost.postData._id }) {
//                    print("existing")
//                    self.postData[existingIndex] = newPost
//                } else {
//                    print("adding")
                    self.postData.append(newPost)
//                }
            }
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

struct UserIndexDataRes: Decodable {
    var index: UserPostIndexData
    var posts: [AllPosts]
    
    private enum CodingKeys: String, CodingKey {
        case index
        case posts
    }
}

struct UserPostIndexData: Decodable {
    var indexID: String
    var prevIndexID: String?
    var nextIndexID: String?
    var amount: Int64
    
    private enum CodingKeys: String, CodingKey {
        case indexID
        case prevIndexID
        case nextIndexID
        case amount
    }
}

struct SelectedProfileData {
    var showProfile: Bool = false
    var profileData: UserData?
    var userID: String = ""
}

struct UserDataFull: Decodable, Identifiable {
    var id = UUID()

    var included: UserIncluded
    var userData: UserData
    var postData: [AllPosts]
    var userPostIndexData: UserPostIndexData?
    var pinData: [AllPosts]
    var badgeData: [BadgeData]?
    var mentionData: [AllPosts]?
    var extraData: UserExtraData?
    
    private enum CodingKeys: String, CodingKey {
        case included
        case userData
        case postData
        case userPostIndexData
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

struct UserFollowListDataPoint: Decodable, Encodable, Identifiable {
    var id = UUID()
    var followData: UserFollowData
    var userData: UserData
    
    private enum CodingKeys: String, CodingKey {
        case followData
        case userData
    }
}

struct UserFollowListData: Decodable, Encodable {
    let found: Bool
    let followIndexID: String?
    let prevIndexID: String?
    let nextIndexID: String?
    let timestamp: Int64?
    let current: Bool?
    let type: Int?
    let userID: String?
    let userData: UserData?
    let amount: Int?
    let includedIndexes: [String]?
    let follows: [String]?
    var data: [UserFollowListDataPoint]? = []
}

struct UserEditNoUpdateResponse: Encodable, Decodable {
    let field: String
    let value: String
}

struct UserEditAcceptedResponse: Identifiable, Encodable, Decodable {
    var id = UUID()
    let field: String
    let value: String
    let prevValueString: String?
    let newValueString: String?
    let prevValueDate: Int64?
    let newValueDate: Int64?
    
    private enum CodingKeys: String, CodingKey {
        case field
        case value
        case prevValueString
        case newValueString
        case prevValueDate
        case newValueDate
    }
}

struct UserEditChangeResponse: Identifiable, Encodable, Decodable {
    var id = UUID()
    var title: String
    var description: String
    var dbName: String
    var required: Bool
    var type: String
    var currentValueString: String?
    var currentValueDate: Int64?
    var newValueString: String = ""
    var newValueDate: Date = Date()
    var updated: Bool = false
    
    private enum CodingKeys: String, CodingKey {
        case title
        case description
        case dbName
        case required
        case type
        case currentValueString
        case currentValueDate
    }
}

struct GetUserEditResponse: Encodable, Decodable {
    let oldData: [UserEditChangeResponse]

}
struct UserEditResponse: Encodable, Decodable {
    let success: Bool
    let partialSuccess: Bool
    var invalidFields: [ErrorUserEdit]
    var fails: [ErrorUserEdit]
    var noUpdates: [UserEditNoUpdateResponse]
    var acceptedChanges: [UserEditAcceptedResponse]
    let oldData: [UserEditChangeResponse]
    let newData: [UserEditChangeResponse]
    
    private enum CodingKeys: String, CodingKey {
        case success
        case partialSuccess
        case invalidFields
        case fails
        case noUpdates
        case acceptedChanges
        case oldData
        case newData
    }
}

struct HttpReqKeyValue: Encodable, Decodable {
    let key: String
    let value: String
}
