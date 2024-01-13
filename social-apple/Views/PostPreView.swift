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
    @State var isOwner: Bool = false;
    @State var deleted: Bool = false

    
    /*
     0=none
     1=reply
     2=quote
     3=showing reply parent
     4=delete post
     5=edit post
     */
    
    var body: some View {
        if (self.activeAction==3) {
            ReplyParentPostView(client: client, feedData: $feedData)
        }
            VStack {
                if (self.deleted) {
                    HStack {
                        Text("This post was deleted.")
                        Spacer()
                    }
                }
                else if showData {
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
                                HStack {
                                    if (self.activeAction == 3) {
                                        Text("Click here to hide reply.")
                                    } else {
                                        Text("This is a reply, click here to view.")
                                    }
                                }
                                .foregroundColor(.secondary)
                            }
                            .buttonStyle(PlainButtonStyle())
                        }
                        VStack {
                            Spacer()
                            VStack {
                                ProfilePostView(client: client, feedData: $feedData, isActive: $isActive, isSpecificPageActive: $isSpecificPageActive, isOwner: $isOwner)
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
                            PostActionButtons(client: client, feedData: $feedData, activeAction: $activeAction, showingPopover: $showingPopover, actionExpanded: $actionExpanded, postIsLiked: $postIsLiked, isOwner: $isOwner, deleted: $deleted)
                            Spacer()
                        }
                        Spacer()
                        if (client.devMode?.isEnabled == true) {
                            DevModePostView(feedData: $feedData)
                            Spacer()
                        }
                    }
                }
                
                else {
                    HStack {
                        Text("Unknown Error with Post Apperance. Try again later.")
                        Spacer()
                    }
                }
            }
            .popover(isPresented: $showingPopover) {
                NavigationView {
                    PopoverPostAction(client: client, feedData: $feedData, activeAction: $activeAction, showingPopover: $showingPopover)
                }
            }
            .onAppear {
                feedData = self.feedDataIn
                if (feedData != nil) {
                    showData = true;
                    print ("showing")
                    postIsLiked = feedData?.extraData.liked ?? false
                    
                    if (feedData?.postData.userID == client.userTokens.userID) {
                        self.isOwner = true;
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
            if (self.actionExpanded == true) {
                ExpandedPostView(client: client, feedData: $feedData)
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

struct ProfilePostView: View {
    @ObservedObject var client: ApiClient
    @Binding var feedData: AllPosts?
    @Binding var isActive: Bool
    @Binding var isSpecificPageActive: Bool
    @Binding var isOwner: Bool
    @State var profileShowing: Bool = false;
    
    var body: some View {
        VStack {
            Button(action: {
                isActive=true
                profileShowing = true
                self.isSpecificPageActive.toggle()
                print("showing usuer?")
            }) {
                VStack {
                    HStack {
                        Text(feedData!.userData?.displayName ?? "")
                        Text("@\(feedData!.userData?.username ?? "")")
                        if (feedData!.userData?.verified == true) {
                            Image(systemName: "checkmark.seal.fill")
                        }
                        Spacer()
                    }
                    .foregroundColor(isOwner==true ? .accentColor : .primary)
                   
                    if (self.feedData?.coposterData != nil) {
                        ForEach(self.feedData!.coposterData ?? []) { coposter in
                            HStack {
                                Text(coposter.displayName ?? "")
                                Text("@\(coposter.username ?? "")")
                                if (coposter.verified != nil) {
                                    Image(systemName: "checkmark.seal.fill")
                                }
                                Spacer()
                            }
                            .foregroundColor(coposter._id == client.userTokens.userID ? .accentColor : .primary)
                        }
                    }
                        
                    HStack {
                        Text(int64TimeFormatter(timestamp: feedData?.postData.timestamp ?? 0))
                        Spacer()
                    }
                    .foregroundColor(isOwner==true ? .accentColor : .primary)
                }
                .buttonStyle(PlainButtonStyle())
            }
            .buttonStyle(PlainButtonStyle())
            .onAppear {
                print(self.feedData?.coposterData ?? "none")
            }
            .navigationDestination(isPresented: $profileShowing) {
                ProfileView(client: client, userData: feedData!.userData ?? nil)
            }
        }
    }
}

struct DevModePostView: View {
    @Binding var feedData: AllPosts?
    
    var body: some View {
        VStack {
            HStack {
                Text("PostID: \(feedData?.postData._id ?? "xx")")
                Spacer()
            }
            HStack {
                Text("UserID: \(feedData?.userData?._id ?? "xx")")
                Spacer()
            }

            if (feedData?.postData.indexID != nil) {
                HStack {
                    Text("Index: \(feedData?.postData.indexID ?? "xx")")
                    Spacer()
                }
            }
            
            if (feedData?.quoteData?.quoteUser != nil) {
                HStack {
                    Text("Quoted UserID: \(feedData?.quoteData?.quoteUser?._id ?? "xx")")
                    Spacer()
                }
                HStack {
                    Text("Quoted PostID: \(feedData?.quoteData?.quotePost?._id ?? "xx")")
                    Spacer()
                }
            }
            
            if (feedData?.pollData != nil) {
                HStack {
                    Text("PollID: \(feedData?.pollData?._id ?? "xx")")
                    Spacer()
                }
                if (feedData?.voteData != nil) {
                    HStack {
                        Text("VoteID: \(feedData?.voteData?._id ?? "xx")")
                        Spacer()
                    }
                }
            }
        }
    }
}

struct ExpandedPostView: View {
    @ObservedObject var client: ApiClient
    @Binding var feedData: AllPosts?
    @State var subAction: Int32 = 0 // inactive
//    @Binding
//    @State var editingPost: Bool = false
//    @State var confirmDelete: Bool = false

    var body : some View {
        VStack {
            VStack {
                HStack {
                    Text("NONE OF THIS IS WORKING")
                }
                HStack {
                    Text("Expanded action area")
                        .underline()
                        .bold()
                    Spacer()
                }
                HStack {
                    Text("Pin to Profile")
                    Spacer()
                }
                HStack {
                    Text("Save to Bookmarks")
                    Spacer()
                }
                HStack {
                    Text("Copy Post Link")
                    Spacer()
                }
                HStack {
                    Text("Check Edit History")
                    Spacer()
                }
                HStack {
                    Text("Check Who Liked")
                    Spacer()
                }
                HStack {
                    Text("Check Replies")
                    Spacer()
                }
                HStack {
                    Text("Check Quotes")
                    Spacer()
                }
            }
            .padding(15)
            .background(client.devMode?.isEnabled == true ? Color.red : Color.clear)
            .cornerRadius(20)
            .overlay(
                RoundedRectangle(cornerRadius: 20)
                    .stroke(Color.accentColor, lineWidth: 3)
            )
            
            if (subAction==1) {
                Text("activate")
            }
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
    @Binding var isOwner: Bool
    @Binding var deleted: Bool
    @State var deletePostConfirm: Bool = false;

    var body : some View {
        HStack {
            VStack {
                Button(action: {
                    if (self.postIsLiked == true) {
                        client.posts.unlikePost(postID: feedData!.postData._id) { result in
                            switch result {
                            case .success(let newPostData):
                                self.postIsLiked.toggle()
                                self.feedData?.postData = newPostData
                                self.feedData?.extraData.liked?.toggle()
                            case .failure(let error):
                                print("Error: \(error.localizedDescription)")
                            }
                        }
                    } else {
                        client.posts.likePost(postID: feedData!.postData._id) { result in
                            switch result {
                            case .success(let newPostData):
                                self.postIsLiked.toggle()
                                self.feedData?.postData = newPostData
                                self.feedData?.extraData.liked?.toggle() 
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
                        if (self.postIsLiked == true) {
                            Image(systemName: "heart.slash")
                        } else {
                            Image(systemName: "heart")
                        }
                    }
                    .padding(5)
                    .foregroundColor(postIsLiked == true ? .accentColor : .secondary)
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

            if (isOwner==true) {
                VStack {
                    Button(action: {
                        self.activeAction = 4
                        self.deletePostConfirm = true
                    }) {
                        HStack {
                            Image(systemName: "trash")
                        }
                        .padding(5)
                        .foregroundColor(.secondary)
                        .background(client.devMode?.isEnabled == true ? Color.blue : Color.clear)
                        .cornerRadius(10)
                    }
                    .buttonStyle(PlainButtonStyle())
                    .confirmationDialog("Delete Post", isPresented: $deletePostConfirm) {
                        Button("Delete") {
                            print("pretend delete")
                            self.deletePostConfirm = false
                            
                            client.posts.deletePost(postID: feedData?.postData._id ?? "") { result in
                                print("api rquest login:")
                                switch result {
                                case .success(let res):
                                    if (res.deleted) {
                                        self.deleted = true
                                    }
                                case .failure(let error):
                                    self.deleted = false
                                    print("Error: \(error.localizedDescription)")
                                }
                            }

                            self.deleted = true;
                        }
                        .foregroundColor(.red)
                        Button("Cancel", role: .cancel) {
                            self.deleted = false
                        }
                    } message: {
                        Text("Confirm Post Deletion")
                    }
                }
            }
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

//            Spacer()
            
            VStack {
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
            .padding(15)
            .cornerRadius(20)
            .overlay(
                RoundedRectangle(cornerRadius: 20)
                    .stroke(Color.accentColor, lineWidth: 3)
            )
            Spacer()

        }
        .padding(10)
        .navigationTitle(self.activeAction==1 ? "Reply" : self.activeAction==2 ? "Quote" : "Unknown Action")
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
