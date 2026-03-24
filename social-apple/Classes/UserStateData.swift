//
//  UserStateData.swift
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
