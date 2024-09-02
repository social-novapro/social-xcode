//
//  PostView.swift
//  social-apple
//
//  Created by Daniel Kravec on 2024-01-29.
//

import SwiftUI

struct PostView: View {
    @ObservedObject var client: ApiClient
    @Binding var feedData: AllPosts
    @Binding var selectedProfile: SelectedProfileData
    
    var body: some View {
        ScrollView {
            VStack {
                if (self.feedData.postData.isReply == true) {
                    ReplyParentPostView(client: client, feedData: $feedData)
                }
                
                VStack {
                    if (self.feedData.postLiveData.deleted == true) {
                        HStack {
                            Text("This post was deleted.")
                            Spacer()
                        }
                    }
                    else if (feedData.postLiveData.showData == true) {
//                        VStack {
                        PostPreviewView(client: client, feedData: $feedData, selectedProfile: $selectedProfile)
//                        }
                    }
                    else {
                        HStack {
                            Text("Unknown Error with Post Apperance. Try again later.")
                            Spacer()
                        }
                    }
                }
                .sheet(isPresented: $feedData.postLiveData.showingPopover) {
                    NavigationView {
                        CreatePost(client: client, feedData: $feedData.optionalBinding())

//                        PopoverPostAction(client: client, feedData: $feedData)
                    }
                }
                .onAppear {
                    feedData.postLiveData.showData = true;
                    
                    if (feedData.postData.userID == client.userTokens.userID) {
                        self.feedData.postLiveData.isOwner = true;
                    }
                }
                .padding(15)
                .background(client.themeData.mainBackground)
                .cornerRadius(20)
                .overlay(
                    RoundedRectangle(cornerRadius: 20)
                        .stroke(Color.gray, lineWidth: 3)
                )
                
                if (self.feedData.postLiveData.actionExpanded == true) {
                    ExpandedPostView(client: client, feedData: $feedData)
                }
                
                if (self.feedData.postData.totalReplies ?? 0 > 0) {
                    VStack {
                        PostViewReplies(client: client, postID: self.feedData.postData._id)
                    }
                }
                Spacer()
            }
            .padding(10)
        }
        .navigationTitle("Post by @\(feedData.userData?.username ?? "Unknown)")")
    }
}

