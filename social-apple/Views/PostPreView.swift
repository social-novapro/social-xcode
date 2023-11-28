//
//  PostView.swift
//  social-apple
//
//  Created by Daniel Kravec on 2023-04-20.
//

import SwiftUI

struct PostPreView: View {
    @Binding var client: ApiClient
    @Binding var userTokenData: UserTokenData?
    @Binding var devMode: DevModeData?
    @State var feedDataIn: AllPosts
    @State var feedData: AllPosts?
    @State var showData: Bool = false
    @State private var isActive:Bool = false
    @State var postIsLiked:Bool = false
    @State var api_requests: API_Rquests
    @State var actionExpanded:Bool = false
    
    var body: some View {
        VStack {
            VStack {
                if showData {
                    VStack {
                        VStack {
                            Spacer()
                            Button(action: {
                                isActive=true
                                print ("showing usuer?")
                                // go to user
                            }) {
                                HStack {
                                    Text(feedData!.userData?.displayName ?? "")
                                    Text("@\(feedData!.userData?.username ?? "")")
                                    if (feedData!.userData?.verified != nil) {
                                        Image(systemName: "checkmark.seal.fill")
                                    }
                                    Spacer()
                                }
                            }
                            .buttonStyle(PlainButtonStyle())
                            Spacer()
                            HStack {
                                Text(feedData!.postData.content!)
                                    .foregroundColor(.secondary)
                                    .lineLimit(nil) // or set a specific number
                                    .multilineTextAlignment(.leading) // or .center, .trailing
                                Spacer()
                            }
                            .background(devMode?.isEnabled == true ? Color.green : Color.clear)
//                            .foregroundColor(devMode?.isEnabled == true ? Color.black : Color.primary)
                            Spacer()
                        }
                        VStack {
                            if (feedData?.quoteData != nil) {
                                Divider()
                                VStack {
                                    if (feedData?.quoteData?.quotePost != nil) {
                                        Spacer()
                                        Button(action: {
                                            isActive=true
                                            print ("showing usuer?")
                                            // go to user
                                        }) {
                                            if (feedData?.quoteData?.quoteUser != nil) {
                                                HStack {
                                                    Text(feedData!.quoteData?.quoteUser?.displayName ?? "")
                                                    Text("@\(feedData!.quoteData?.quoteUser?.username ?? "")")
                                                    if (feedData!.userData?.verified != nil) {
                                                        Image(systemName: "checkmark.seal.fill")
                                                    }
                                                    Spacer()
                                                }
                                            }
                                        }
                                        .buttonStyle(PlainButtonStyle())
                                        Spacer()
                                        HStack {
                                            Text(feedData?.quoteData?.quotePost?.content ?? "empty quote")
                                                .lineLimit(nil) // or set a specific number
                                                .multilineTextAlignment(.leading) // or .center, .trailing

                                            Spacer()
                                        }
                                        .foregroundColor(.secondary)
                                        .background(devMode?.isEnabled == true ? Color.green : Color.clear)
                                        Spacer()
                                    }
                                }
                            }
                            VStack {
                                if (feedData?.pollData != nil) {
                                    Divider()
                                    PollView(
                                        pollData: feedData?.pollData ?? PollData(_id: ""), voteOption: feedData?.voteData?.pollOptionID ?? "")
                                }
                            }
                        }
                        
                        Spacer()
                        
                        HStack {
                            Spacer()
                            HStack {
                                Button(action: {
                                    print("like button")
                                    if (feedData!.extraData.liked == true) {
                                        client.posts.unlikePost(postID: feedData!.postData._id) { result in
                                            switch result {
                                            case .success(let newPostData):
                                                self.postIsLiked = false
                                                self.feedData?.postData = newPostData
                                                self.feedData?.extraData.liked = false // temp code
                                            case .failure(let error):
                                                print("Error: \(error.localizedDescription)")
                                            }
                                        }
                                    } else {
                                        client.posts.likePost(postID: feedData!.postData._id) { result in
                                            switch result {
                                            case .success(let newPostData):
                                                self.postIsLiked = true
                                                self.feedData?.postData = newPostData
                                                self.feedData?.extraData.liked = true // temp code
                                            case .failure(let error):
                                                print("Error: \(error.localizedDescription)")
                                            }
                                        }
                                    }
                                }) {
                                    HStack {
                                        if (self.feedData?.postData.totalLikes ?? 0 != 0) {
                                            Text("\(self.feedData?.postData.totalLikes ?? 0)")
                                        }
                                        if (feedData!.extraData.liked == true) {
                                            Image(systemName: "heart.slash")
                                        } else {
                                            Image(systemName: "heart")
                                        }
                                    }
                                    .padding(5)
                                    .foregroundColor(feedData!.extraData.liked == true ? .accentColor : .secondary)
                                    .background(devMode?.isEnabled == true ? Color.blue : Color.clear)
                                    .cornerRadius(10)
                                }
                                .buttonStyle(PlainButtonStyle())
                                
                                Button(action: {
                                    print("reply button")
                                }) {
                                    HStack {
                                        if (self.feedData?.postData.totalReplies ?? 0 != 0) {
                                            Text("\(self.feedData?.postData.totalReplies ?? 0)")
                                        }
                                        Image(systemName: "arrowshape.turn.up.left")
                                    }
                                    .padding(5)
                                    .foregroundColor(.secondary)
                                    .background(devMode?.isEnabled == true ? Color.blue : Color.clear)
                                    .cornerRadius(10)
                                }
                                .buttonStyle(PlainButtonStyle())
                                
                                Button(action: {
                                    print("quote button")
                                }) {
                                    HStack {
                                        if (self.feedData?.postData.totalQuotes ?? 0 != 0) {
                                            Text("\(self.feedData?.postData.totalQuotes ?? 0)")
                                        }
                                        Image(systemName: "quote.closing")
                                    }
                                    .padding(5)
                                    .foregroundColor(.secondary)
                                    .background(devMode?.isEnabled == true ? Color.blue : Color.clear)
                                    .cornerRadius(10)
                                }
                                .buttonStyle(PlainButtonStyle())
                                
                                Button(action: {
                                    print("action")
//                                    self.actionExpanded.toggle()
                                    withAnimation(.interactiveSpring(response: 0.45, dampingFraction: 0.6, blendDuration: 0.6)) {
                                        self.actionExpanded.toggle()
                                    }
                                }) {
                                    HStack {
                                        if (self.actionExpanded == true) {
                                            Image(systemName: "chevron.up")
                                        } else {
                                            Image(systemName: "chevron.down")
                                        }
                                    }
                                    .padding(5)
                                    .foregroundColor(.secondary)
                                    .background(devMode?.isEnabled == true ? Color.blue : Color.clear)
                                    .cornerRadius(10)
                                }
                                .buttonStyle(PlainButtonStyle())

                                Spacer()
                            }
                            Spacer()
                        }
                        Spacer()
                        
                        if (devMode?.isEnabled == true) {
                            VStack {
                                Text("PostID: \(feedData?.postData._id ?? "xx")")
                                Text("UserID: \(feedData?.userData?._id ?? "xx")")
                                
                                if (feedData?.quoteData?.quoteUser != nil) {
                                    Text("Quoted UserID: \(feedData?.quoteData?.quoteUser?._id ?? "xx")")
                                    Text("Quoted PostID: \(feedData?.quoteData?.quotePost?._id ?? "xx")")
                                }
                                
                                if (feedData?.pollData != nil) {
                                    Text("PollID: \(feedData?.pollData?._id ?? "xx")")
                                    if (feedData?.voteData != nil) {
                                        Text("VoteID: \(feedData?.voteData?._id ?? "xx")")
                                    }
                                }
                            }
                            Spacer()
                        }
                    }
                }
                else {
                    EmptyView()
                }
            }
            .onAppear {
                feedData = self.feedDataIn
                if (feedData != nil) {
                    showData = true;
                    print ("showing")
                }
                
            }
            .padding(15)
            .background(devMode?.isEnabled == true ? Color.red : Color.clear)
            .cornerRadius(20)
            .overlay(
                RoundedRectangle(cornerRadius: 20)
                    .stroke(Color.accentColor, lineWidth: 3)
            )
            if (self.actionExpanded == true) {
                HStack {
                    Text("Expanded action area")
                }
                .padding(15)
                .background(devMode?.isEnabled == true ? Color.red : Color.clear)
                .cornerRadius(20)
                .overlay(
                    RoundedRectangle(cornerRadius: 20)
                        .stroke(Color.accentColor, lineWidth: 3)
                )
                
            }
        }
    }
}

struct PostContentArea: View {
    @Binding var postData: PostData?
    var body: some View {
        Text("hi")
    }
}

struct PostUserArea: View {
    @Binding var userData: UserData?

    var body: some View {
        Text("hi")
    }
}
