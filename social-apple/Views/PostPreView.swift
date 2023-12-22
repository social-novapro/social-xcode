//
//  PostView.swift
//  social-apple
//
//  Created by Daniel Kravec on 2023-04-20.
//

import SwiftUI

struct PostPreView: View {
    @ObservedObject var client: ApiClient
    @State var feedDataIn: AllPosts
    @State var feedData: AllPosts?
    @State var showData: Bool = false
    @State private var isActive:Bool = false
    @State var postIsLiked:Bool = false
    @State var actionExpanded:Bool = false
    @State private var isSpecificPageActive = false
    @State var activeAction: Int32 = 0
    @State var showingPopover: Bool = false
    
    /*
     0=none
     1=reply
     2=quote
     3=showing reply parent
     */
    
    var body: some View {
        if (self.activeAction==3) {
            ReplyParentPostView(client: client, feedData: $feedData)
        }
            VStack {
                if showData {
                   
                    VStack {
                        if (feedData?.postData.isReply == true) {
                            Button(action: {
                                withAnimation(.interactiveSpring(response: 0.45, dampingFraction: 0.6, blendDuration: 0.6)) {
                                    if (self.activeAction == 3) {
                                        self.activeAction = 0
                                    } else {
                                        self.activeAction = 3
                                    }
                                }
                            }) {
                                if (self.activeAction == 3) {
                                    Text("Click here to hide reply.")
                                } else {
                                    Text("This is a reply, click here to view.")
                                }
                            }
                            .buttonStyle(PlainButtonStyle())
                        }
                        VStack {
                            Spacer()
                            VStack {
                                Button(action: {
                                    isActive=true
                                    self.isSpecificPageActive.toggle()
                                    print("showing usuer?")
                                }) {
                                    NavigationLink {
                                        ProfileView(userData: feedData!.userData ?? nil)
                                    } label: {
                                        VStack {
                                            HStack {
                                                Text(feedData!.userData?.displayName ?? "")
                                                Text("@\(feedData!.userData?.username ?? "")")
                                                if (feedData!.userData?.verified != nil) {
                                                    Image(systemName: "checkmark.seal.fill")
                                                }
                                                Spacer()
                                            }
                                            HStack {
                                                Text(stringTimeFormatter(timestamp: feedData?.postData.timePosted ?? ""))
                                                Spacer()
                                            }
                                        }
                                    }
                                    .buttonStyle(PlainButtonStyle())
                                }
                                .buttonStyle(PlainButtonStyle())
                            }
                            Spacer()
                            HStack {
                                VStack {
                                    Text(feedData!.postData.content!)
                                        .foregroundColor(.secondary)
                                        .lineLimit(100) // or set a specific number
                                        .multilineTextAlignment(.leading) // or .center, .trailing
                                }
                                Spacer()
                            }
                            .background(client.devMode?.isEnabled == true ? Color.green : Color.clear)
                            Spacer()
// This is an extra long content that will totally look great on a large display with a small content area.
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
                                        VStack {
                                            HStack {
                                                Text(feedData?.quoteData?.quotePost?.content ?? "empty quote")
                                                    .lineLimit(nil) // or set a specific number
                                                    .multilineTextAlignment(.leading) // or .center, .trailing

                                                Spacer()
                                            }
                                        }
                                        .foregroundColor(.secondary)
                                        .background(client.devMode?.isEnabled == true ? Color.green : Color.clear)
                                        
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
                            PostActionButtons(client: client, feedData: $feedData, activeAction: $activeAction, showingPopover: $showingPopover, actionExpanded: $actionExpanded, postIsLiked: $postIsLiked)
                            Spacer()
                        }
                        Spacer()
                        if (client.devMode?.isEnabled == true) {
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
            .popover(isPresented: $showingPopover) {
                PopoverPostAction(client: client, feedData: $feedData, activeAction: $activeAction, showingPopover: $showingPopover)
            }
            .onAppear {
                feedData = self.feedDataIn
                if (feedData != nil) {
                    showData = true;
                    print ("showing")
                }
                
            }
            .padding(15)
            .background(client.devMode?.isEnabled == true ? Color.red : Color.clear)
            .cornerRadius(20)
            .overlay(
                RoundedRectangle(cornerRadius: 20)
                    .stroke(Color.accentColor, lineWidth: 3)
            )
            if (self.actionExpanded == true) {
                ExpandedPostView(client: client)
            }
    }
}
struct ReplyParentPostView : View {
    @ObservedObject var client: ApiClient
    @Binding var feedData: AllPosts?

    var body : some View {
        VStack {
            HStack {
                Text(feedData!.replyData?.replyUser?.displayName ?? "")
                Text("@\(feedData!.replyData?.replyUser?.username ?? "")")
                if (feedData!.replyData?.replyUser?.verified != nil) {
                    Image(systemName: "checkmark.seal.fill")
                }
                Spacer()
            }
            VStack {
                HStack {
                    Text(feedData!.replyData?.replyPost?.content ?? "")
                        .foregroundColor(.secondary)
                        .lineLimit(100) // or set a specific number
                        .multilineTextAlignment(.leading) // or .center, .trailing
                    Spacer()
                }
            }
        }
        .padding(15)
        .background(client.devMode?.isEnabled == true ? Color.red : Color.clear)
        .cornerRadius(20)
        .overlay(
            RoundedRectangle(cornerRadius: 20)
                .stroke(Color.accentColor, lineWidth: 3)
        )

    }
}
struct ExpandedPostView: View {
    @ObservedObject var client: ApiClient

    var body : some View {
        VStack {
            HStack {
                Text("Expanded action area")
                Spacer()
            }
            .padding(15)
            .background(client.devMode?.isEnabled == true ? Color.red : Color.clear)
            .cornerRadius(20)
            .overlay(
                RoundedRectangle(cornerRadius: 20)
                    .stroke(Color.accentColor, lineWidth: 3)
            )
            
        }
    }
}

struct PostActionButtons: View {
    @ObservedObject var client: ApiClient
    @Binding var feedData: AllPosts?
    @Binding var activeAction: Int32
    @Binding var showingPopover: Bool
    @Binding var actionExpanded: Bool
    @Binding var postIsLiked: Bool

    var body : some View {
        HStack {
            VStack {
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
                    .background(client.devMode?.isEnabled == true ? Color.blue : Color.clear)
                    .cornerRadius(10)
                }
                .buttonStyle(PlainButtonStyle())
            }
            
            VStack {
                Button(action: {
                    print("reply button")
                    self.activeAction = 1
                    self.showingPopover = true
                }) {
                    HStack {
                        if (self.feedData?.postData.totalReplies ?? 0 != 0) {
                            Text("\(self.feedData?.postData.totalReplies ?? 0)")
                        }
                        Image(systemName: "arrowshape.turn.up.left")
                    }
                    .padding(5)
                    .foregroundColor(.secondary)
                    .background(client.devMode?.isEnabled == true ? Color.blue : Color.clear)
                    .cornerRadius(10)
                }
                .buttonStyle(PlainButtonStyle())
            }
            
            VStack {
                Button(action: {
                    print("quote button")
                    self.activeAction = 2
                    self.showingPopover = true
                }) {
                    HStack {
                        if (self.feedData?.postData.totalQuotes ?? 0 != 0) {
                            Text("\(self.feedData?.postData.totalQuotes ?? 0)")
                        }
                        Image(systemName: "quote.closing")
                    }
                    .padding(5)
                    .foregroundColor(.secondary)
                    .background(client.devMode?.isEnabled == true ? Color.blue : Color.clear)
                    .cornerRadius(10)
                }
                .buttonStyle(PlainButtonStyle())
            }
            
            VStack {
                Button(action: {
                    print("action")
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
                    .background(client.devMode?.isEnabled == true ? Color.blue : Color.clear)
                    .cornerRadius(10)
                }
                .buttonStyle(PlainButtonStyle())

            }
            Spacer()
        }
    }
}

struct PopoverPostAction: View {
    @ObservedObject var client: ApiClient
    @Binding var feedData: AllPosts?
    @Binding var activeAction: Int32
    @Binding var showingPopover: Bool
    @State var newPost:PostData?
    @State private var content: String = ""
    @State var sending: Bool = false
    @State var sent: Bool = false
    @State var failed: Bool = false

    var body : some View {
        VStack {
            if (self.activeAction==1) {
                Text("Relplying to Post")
            } else if (self.activeAction==2) {
                Text("Quoting Post")
            }
            Spacer()
            if sending==true {
                HStack {
                    Text("Status: ")
                    if sent==true {
                        Text("Sent!")
                    } else {
                        if failed==true {
                            Text("Failed to send!")
                        } else {
                            Text("Sending")
                        }
                    }
                }
            }
            VStack {
                HStack {
                    Text(feedData!.userData?.displayName ?? "")
                    Text("@\(feedData!.userData?.username ?? "")")
                    if (feedData!.userData?.verified != nil) {
                        Image(systemName: "checkmark.seal.fill")
                    }
                    Spacer()
                }
                VStack {
                    Text(feedData!.postData.content ?? "")
                }
            }
            .padding(15)
            .background(client.devMode?.isEnabled == true ? Color.red : Color.clear)
            .cornerRadius(20)
            .overlay(
                RoundedRectangle(cornerRadius: 20)
                    .stroke(Color.accentColor, lineWidth: 3)
            )

            Spacer()
            
            Form {
                TextField("Content", text: $content)
                Button(action: {
                    print("button pressed")
                    print("createPost")
                    var postCreateContent = PostCreateContent(userID: client.userTokens.userID, content: self.content)
                    print(postCreateContent)
                    
                    if (self.activeAction == 1) {
                        postCreateContent.replyingPostID = self.feedData!.postData._id
                    } else if (self.activeAction == 2) {
                        postCreateContent.quoteReplyPostID = self.feedData!.postData._id
                    }
                    
                    print(postCreateContent)
                    self.content = ""
                    self.sending = true
                    
                    client.posts.createPost(postCreateContent: postCreateContent) { result in
                        print("api rquest login:")
                        switch result {
                        case .success(let newPost):
                            self.newPost = newPost
                            self.sent = true
                        case .failure(let error):
                            self.failed = true
                            print("Error: \(error.localizedDescription)")
                        }
                    }
                }) {
                    Text("Publish Post")
                }
            }
        }
    }
}

struct BasicPostView: View {
    @ObservedObject var client: ApiClient
    @Binding var feedData: AllPosts?

    var body: some View {
        VStack {
            HStack {
                Text(feedData!.userData?.displayName ?? "")
                Text("@\(feedData!.userData?.username ?? "")")
                if (feedData!.userData?.verified != nil) {
                    Image(systemName: "checkmark.seal.fill")
                }
                Spacer()
            }
            VStack {
                Text(feedData!.postData.content ?? "")
            }
        }
    }
}

struct PostUserArea: View {
    @Binding var userData: UserData?

    var body: some View {
        Text("hi")
    }
}
