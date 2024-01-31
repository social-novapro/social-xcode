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
                        VStack {
                            PostPreviewView(client: client, feedData: $feedData)
                        }
                    }
                    else {
                        HStack {
                            Text("Unknown Error with Post Apperance. Try again later.")
                            Spacer()
                        }
                    }
                }
                .popover(isPresented: $feedData.postLiveData.showingPopover) {
                    NavigationView {
                        PopoverPostAction(client: client, feedData: $feedData)
                    }
                }
                .onAppear {
                    feedData.postLiveData.showData = true;
                    
                    if (feedData.postData.userID == client.userTokens.userID) {
                        self.feedData.postLiveData.isOwner = true;
                    }
                }
                .padding(15)
                .background(client.devMode?.isEnabled == true ? Color.red : Color.clear)
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
