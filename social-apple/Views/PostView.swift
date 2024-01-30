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
    @Binding var postExtraData: PostExtraData
    
    var body: some View {
        ScrollView {
            VStack {
                if (self.feedData.postData.isReply == true) {
                    ReplyParentPostView(client: client, feedData: $feedData)
                }
                
                VStack {
                    if (self.postExtraData.deleted) {
                        HStack {
                            Text("This post was deleted.")
                            Spacer()
                        }
                    }
                    else if postExtraData.showData {
                        VStack {
                            PostPreviewView(client: client, feedData: $feedData, postExtraData: $postExtraData)
                        }
                    }
                    else {
                        HStack {
                            Text("Unknown Error with Post Apperance. Try again later.")
                            Spacer()
                        }
                    }
                }
                .popover(isPresented: $postExtraData.showingPopover) {
                    NavigationView {
                        PopoverPostAction(client: client, feedData: $feedData, postExtraData: $postExtraData)
                    }
                }
                .onAppear {
                    postExtraData.showData = true;
                    postExtraData.postIsLiked = feedData.extraData.liked ?? false
                    
                    if (feedData.postData.userID == client.userTokens.userID) {
                        self.postExtraData.isOwner = true;
                    }
                }
                .padding(15)
                .background(client.devMode?.isEnabled == true ? Color.red : Color.clear)
                .cornerRadius(20)
                .overlay(
                    RoundedRectangle(cornerRadius: 20)
                        .stroke(Color.accentColor, lineWidth: 3)
                )
                
                if (self.postExtraData.actionExpanded == true) {
                    ExpandedPostView(client: client, feedData: $feedData, postExtraData: $postExtraData)
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
