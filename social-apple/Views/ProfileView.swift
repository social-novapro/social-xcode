//
//  ProfileView.swift
//  social-apple
//
//  Created by Daniel Kravec on 2023-11-28.
//

import SwiftUI

struct ProfileView: View {
    @ObservedObject var client: ApiClient
    @State var userData: UserData?
    @State var userID: String?
    @State var giveUpSearch: Bool = false
//    @State var extraData
    
    var body: some View {
        HStack {
            Spacer()
            VStack {
                if (userData == nil && giveUpSearch == true) {
                    Text("There might have been an error... No profile found...")
                } else if (userData == nil && giveUpSearch == false) {
                    Text("Loading Data...")
                } else {
                    HStack {
                        Text(userData!.displayName!)
                        Text("@" + userData!.username!)
                        if (userData!.verified == true) {
                            Image(systemName: "checkmark.seal.fill")
                        }
                        Spacer()
                    }
                    HStack {
                        Text(userData!.description!)
                        Spacer()
                    }
                    if (userData!.likeCount != nil) {
                        HStack {
                            Text(String(userData!.likeCount!) + " Likes")
                            Spacer()
                        }                }
                    if (userData!.likedCount != nil) {
                        HStack {
                            Text(String(userData!.likedCount!) + " Liked Posts")
                            Spacer()
                        }
                    }
                    if (userData!.statusTitle != nil) {
                        HStack {
                            Text("Status: " + userData!.statusTitle!)
                            Spacer()
                        }
                    }
                    HStack {
                        Text("Created " + int64TimeFormatter(timestamp: userData!.creationTimestamp!))
                        Spacer()
                    }
                    if (userData!.totalPosts != nil) {
                        HStack {
                            Text(String(userData!.totalPosts!) + " Total Posts")
                            Spacer()
                        }
                    }
                    if (userData!.totalReplies != nil) {
                        HStack {
                            Text(String(userData!.totalReplies!) + " Total Replies")
                            Spacer()
                        }

                    }
                    if (userData!.totalQuotes != nil) {
                        HStack {
                            Text(String(userData!.totalQuotes!) + " Total Quote Posts")
                            Spacer()
                        }
                    }
                }
                Spacer()
            }
            Spacer()
        }
        .navigationTitle("Profile of @" + (userData?.username ?? "unknown"))

        .onAppear {
            if (self.userData == nil && (self.userID == nil)) {
                client.users.getByID(userID: client.userTokens.userID) { result in
                    print("Done")
                    switch result {
                        case .success(let results):
                            self.userData = results;
                        case .failure(let error):
                            self.giveUpSearch = true;
                            print("Error: \(error.localizedDescription)")
                    }
                }
            }
            else if (self.userData == nil && (self.userID != nil)) {
                client.users.getByID(userID: client.userTokens.userID) { result in
                    print("Done")
                    switch result {
                        case .success(let results):
                            self.userData = results;
                        case .failure(let error):
                        self.giveUpSearch = true;
                            print("Error: \(error.localizedDescription)")
                    }
                }
            } else {
                self.giveUpSearch = true;
            }
        }
    }
}
