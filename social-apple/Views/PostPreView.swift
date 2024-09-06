//
//  PostView.swift
//  social-apple
//
//  Created by Daniel Kravec on 2023-04-20.
//

import SwiftUI


struct PostPreView: View {
    @ObservedObject var client: Client
    @Binding var feedData: AllPosts
    @Binding var selectedProfile: SelectedProfileData
    
    var body: some View {
        if (self.feedData.postLiveData.activeAction==3) {
            ReplyParentPostView(client: client, feedData: $feedData)
        }
            VStack {
                if (self.feedData.postLiveData.deleted) {
                    HStack {
                        Text("This post was deleted.")
                        Spacer()
                    }
                }
                else if feedData.postLiveData.showData {
                    Button(action: {
                        client.hapticPress()
                        self.feedData.postLiveData.showPostPage = true
                        print("showing post?")
                    }) {
                        VStack {
                            PostPreviewView(client: client, feedData: $feedData, selectedProfile: $selectedProfile)
                        }
                    }
                    .buttonStyle(.plain)
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
                }
            }
            .sheet(isPresented: $feedData.postLiveData.showingEditPopover) {
                NavigationView {
                    EditPostPopover(client: client, feedData: $feedData, content: feedData.postData.content ?? "")
                }
            }
            .navigationDestination(isPresented: $feedData.postLiveData.showPostPage) {
                PostView(client: client, feedData: $feedData, selectedProfile: $selectedProfile)
            }
            .onAppear {
                print ("showing")
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
    }
}

struct PostFeedPreView: View {
    @ObservedObject var client: Client
    @Binding var feedData: AllPosts

    @Binding var selectedPostIndex: Int?
    @Binding var selectedPost: Bool
    @Binding var selectedProfile: SelectedProfileData
    @State var currentPostIndex: Int
    
    var body: some View {
        if (self.feedData.postLiveData.activeAction==3) {
            ReplyParentPostView(client: client, feedData: $feedData)
        }
            VStack {
                if (self.feedData.postLiveData.deleted) {
                    HStack {
                        Text("This post was deleted.")
                        Spacer()
                    }
                }
                else if feedData.postLiveData.showData {
                    Button(action: {
                        client.hapticPress()
                        self.feedData.postLiveData.showPostPage = true
                        print("showing post?")
                        self.selectedPost = true
                        self.selectedPostIndex = currentPostIndex
                    }) {
                        VStack {
                            PostPreviewView(client: client, feedData: $feedData, selectedProfile: $selectedProfile)
                        }
                    }
                    .buttonStyle(.plain)
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
                }
            }
            .sheet(isPresented: $feedData.postLiveData.showingEditPopover) {
                NavigationView {
                    EditPostPopover(client: client, feedData: $feedData, content: feedData.postData.content ?? "")
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
    }
}

struct PostPreviewView: View {
    @ObservedObject var client: Client
    @Binding var feedData: AllPosts
    @Binding var selectedProfile: SelectedProfileData

    var body: some View {
        VStack {
            if (feedData.postData.isReply == true) {
                Button(action: {
                    client.hapticPress()
                    withAnimation(.interactiveSpring(response: 0.45, dampingFraction: 0.6, blendDuration: 0.6)) {
                        if (self.feedData.postLiveData.activeAction == 3) {
                            self.feedData.postLiveData.activeAction = 0
                        } else {
                            self.feedData.postLiveData.activeAction = 3
                        }
                    }
                }) {
                    HStack {
                        if (self.feedData.postLiveData.activeAction == 3) {
                            Text("Click here to hide reply.")
                        } else {
                            Text("This is a reply, click here to view.")
                        }
                    }
                    .foregroundColor(.secondary)
                }
                .buttonStyle(PlainButtonStyle())
                .foregroundColor(.secondary)
            }
            if (self.feedData.postData.edited==true) {
                HStack {
                    Text("This post was edited...")
                            .italic()
                }
                .foregroundColor(.secondary)
            }
            VStack {
                Spacer()
                VStack {
                    ProfilePostView(client: client, feedData: $feedData, selectedProfile: $selectedProfile)
                }
                Spacer()
                HStack {
                    VStack {
                        // doesnt work
//                        TappableText(content: feedData.postData.content!) { word in
//                            print("tapped on \(word)")
//                        }
                        Text(feedData.postData.content!)
//                            .foregroundColor(.secondary)
                            .lineLimit(100) // or set a specific number
                            .multilineTextAlignment(.leading) // or .center, .trailing
                    }
                    Spacer()
                }
                .background(client.themeData.greenBackground)
                Spacer()
// This is an extra long content that will totally look great on a large display with a small content area.
            }
            VStack {
                if (feedData.quoteData != nil) {
                    Divider()
                    VStack {
                        if (feedData.quoteData?.quotePost != nil) {
                            Spacer()
                            Button(action: {
                                client.hapticPress()
                                DispatchQueue.main.async {
                                    feedData.postLiveData.isActive=true
                                }
                                print ("showing usuer?")
                                // go to user
//                                selectedProfile = true
                                selectedProfile.showProfile = true
                                selectedProfile.profileData = feedData.quoteData?.quoteUser
                                selectedProfile.userID = feedData.quoteData?.quoteUser?._id ?? ""

                            }) {
                                if (feedData.quoteData?.quoteUser != nil) {
                                    HStack {
                                        Text(feedData.quoteData?.quoteUser?.displayName ?? "")
                                        Text("@\(feedData.quoteData?.quoteUser?.username ?? "")")
                                        if (feedData.userData?.verified == true) {
                                            Image(systemName: "checkmark.seal.fill")
                                        }
                                        Spacer()
                                    }
                                    .foregroundColor(.secondary)

                                }
                            }
                            .buttonStyle(PlainButtonStyle())
                            Spacer()
                            VStack {
                                HStack {
                                    Text(feedData.quoteData?.quotePost?.content ?? "empty quote")
                                        .lineLimit(nil) // or set a specific number
                                        .multilineTextAlignment(.leading) // or .center, .trailing

                                    Spacer()
                                }
                            }
                            .foregroundColor(.primary)
                            .background(client.themeData.greenBackground)
                            
                            Spacer()
                        }
                    }
                }
                VStack {
                    if (feedData.pollData != nil) {
                        Divider()
                        PollView(client: client, feedData: $feedData,
                            pollData: feedData.pollData ?? PollData(_id: ""), voteOption: feedData.voteData?.pollOptionID ?? "")
                    }
                }
            }
            
            Spacer()
            
            HStack {
                Spacer()
                PostActionButtons(client: client, feedData: $feedData)
                Spacer()
            }
            Spacer()
            if (client.devMode?.isEnabled == true) {
                DevModePostView(feedData: $feedData)
                Spacer()
            }
        }
    }
}

struct ReplyParentPostView : View {
    @ObservedObject var client: Client
    @Binding var feedData: AllPosts

    var body : some View {
        VStack {
            HStack {
                Text(feedData.replyData?.replyUser?.displayName ?? "")
                Text("@\(feedData.replyData?.replyUser?.username ?? "")")
                if (feedData.replyData?.replyUser?.verified == true) {
                    Image(systemName: "checkmark.seal.fill")
                }
                Spacer()
            }
            .foregroundColor(.secondary)

            VStack {
                HStack {
                    Text(feedData.replyData?.replyPost?.content ?? "")
                        .foregroundColor(.primary)
                        .lineLimit(100) // or set a specific number
                        .multilineTextAlignment(.leading) // or .center, .trailing
                    Spacer()
                }
            }
        }
        .padding(15)
        .background(client.themeData.mainBackground)
        .cornerRadius(20)
        .overlay(
            RoundedRectangle(cornerRadius: 20)
                .stroke(Color.gray, lineWidth: 3)
        )
    }
}

struct ProfilePostView: View {
    @ObservedObject var client: Client
    @Binding var feedData: AllPosts

    @Binding var selectedProfile: SelectedProfileData
    
    var body: some View {
        VStack {
                VStack {
                    HStack {
                        Button(action: {
                            client.hapticPress()
                            DispatchQueue.main.async {
                                feedData.postLiveData.isActive=true
                                selectedProfile.showProfile = true
                                selectedProfile.profileData = feedData.userData
                                selectedProfile.userID = feedData.userData?._id ?? ""
                                self.feedData.postLiveData.isSpecificPageActive.toggle()
            //                    selectedProfile = true
                            }
                            print("showing usuer?")
                        }) {
                            HStack {
                                Text(feedData.userData?.displayName ?? "")
                                Text("@\(feedData.userData?.username ?? "")")
                                if (feedData.userData?.verified == true) {
                                    Image(systemName: "checkmark.seal.fill")
                                }
                            }
                        }
                        .buttonStyle(PlainButtonStyle())
                        Spacer()
                        
                        if ((client.userTokens.userID != feedData.userData?._id) && (feedData.extraData.followed ?? false) == false) {
                            Button(action: {
                                client.hapticPress()
                                DispatchQueue.main.async {
                                    Task {
                                        do {
                                            _ = try await client.api.users.followUser(userID: self.feedData.userData?._id ?? "unknown")
                                            feedData.extraData.followed=true
                                        } catch {
                                            let foundError = error as! ErrorData
                                            print("failed true" )
                                            print(foundError)
                                            if (foundError.code == "C022") {
                                                print("already following")
                                                feedData.extraData.followed = true
//                                                print(feedData.extraData.followed)
                                            }
                                        }
                                    }
                                }
                                print("following user?")
                            }) {
                                HStack {
                                    Text("Follow") // only on non followed users
                                }
                            }
                            .buttonStyle(PlainButtonStyle())
                        }
                    }
                    .foregroundColor(feedData.postLiveData.isOwner==true ? .accentColor : .secondary)
                    .background(client.themeData.greenBackground)
                   
                    if (self.feedData.coposterData != nil) {
                        ForEach(self.feedData.coposterData ?? []) { coposter in
                            Button(action: {
                                client.hapticPress()
                                DispatchQueue.main.async {
                                    feedData.postLiveData.isActive=true
                                    selectedProfile.showProfile = true
                                    selectedProfile.profileData = coposter
                                    selectedProfile.userID = coposter._id ?? "unknown"
                                    self.feedData.postLiveData.isSpecificPageActive.toggle()
                                }
                                print("showing usuer?")
                            }) {
                                HStack {
                                    Text(coposter.displayName ?? "")
                                    Text("@\(coposter.username ?? "")")
                                    if (coposter.verified == true) {
                                        Image(systemName: "checkmark.seal.fill")
                                    }
                                    Spacer()
                                }
                                .foregroundColor(coposter._id == client.userTokens.userID ? .accentColor : .secondary)
                            }
                            .buttonStyle(PlainButtonStyle())
                        }
                    }
                        
                    HStack {
                        Text(int64TimeFormatter(timestamp: feedData.postData.timestamp ?? 0))
                        Spacer()
                    }
                    .foregroundColor(feedData.postLiveData.isOwner==true ? .accentColor : .secondary)
            }
            .onAppear {
                print(self.feedData.coposterData ?? "none")
            }
        }
    }
}


struct TappableText: View {
    let content: String
    let onTap: (String) -> Void

    var words: [String] {
        content.split(separator: " ").map { String($0) }
    }

    var body: some View {
        VStack {
            HStack {
                ForEach(words, id: \.self) { word in
                    Text(word + " ")
                        .foregroundColor(.blue)
                        .onTapGesture {
                            onTap(word)
                        }
//                        .padding(.trailing, 4) // Add some space between words
                }
                Spacer()
            }
            .frame(maxWidth: .infinity, alignment: .leading) // Allow text to wrap
        }
    }
}


struct DevModePostView: View {
    @Binding var feedData: AllPosts
    
    var body: some View {
        VStack {
            HStack {
                Text("PostID: \(feedData.postData._id)")
                Spacer()
            }
            HStack {
                Text("UserID: \(feedData.userData?._id ?? "xx")")
                Spacer()
            }

            if (feedData.postData.indexID != nil) {
                HStack {
                    Text("Index: \(feedData.postData.indexID ?? "xx")")
                    Spacer()
                }
            }
            
            if (feedData.quoteData?.quoteUser != nil) {
                HStack {
                    Text("Quoted UserID: \(feedData.quoteData?.quoteUser?._id ?? "xx")")
                    Spacer()
                }
                HStack {
                    Text("Quoted PostID: \(feedData.quoteData?.quotePost?._id ?? "xx")")
                    Spacer()
                }
            }
            
            if (feedData.pollData != nil) {
                HStack {
                    Text("PollID: \(feedData.pollData?._id ?? "xx")")
                    Spacer()
                }
                if (feedData.voteData != nil) {
                    HStack {
                        Text("VoteID: \(feedData.voteData?._id ?? "xx")")
                        Spacer()
                    }
                }
            }
        }
    }
}

struct ExpandedPostView: View {
    @ObservedObject var client: Client
    @Binding var feedData: AllPosts

    @State var savedPost: Bool?
    @State var pinnedPost: Bool?
    @State var followed: Bool?
    
    var body : some View {
        VStack {
            VStack {
                HStack {
                    Button(action: {
                        client.hapticPress()
                        withAnimation(.interactiveSpring(response: 0.45, dampingFraction: 0.6, blendDuration: 0.6)) {
                            feedData.postLiveData.actionExpanded=false;
                        }
                    }) {
                        Text("Close Expanded Area")
                    }
                    .buttonStyle(PlainButtonStyle())
                    Spacer()
                    
                }
                Divider()
                if (client.userTokens.userID != feedData.userData?._id ?? "") {
                    HStack {
                        Button(action: {
                            client.hapticPress()
                            DispatchQueue.main.async {
                                Task {
                                    if ((self.feedData.extraData.followed ?? false) == true) {
                                        do {
                                            _ = try await client.api.users.unFollowUser(userID: self.feedData.userData?._id ?? "")
                                            self.feedData.extraData.followed = false
                                        } catch let error as ErrorData {
                                            print("ErrorData: \(error.code), \(error.msg)")
                                        } catch {
                                            print("Unexpected error: \(error)")
                                            let foundError = error as! ErrorData

                                            if (foundError.code == "C026") {
                                                print("not already following")
                                                feedData.extraData.followed = false
//                                                print(feedData.extraData.followed)
                                            }
                                        }
                                    } else {
                                        do {
                                            _ = try await client.api.users.followUser(userID: self.feedData.userData?._id ?? "")
                                            self.feedData.extraData.followed = true
                                        } catch {
                                            print("failed true" )
                                            let foundError = error as! ErrorData
                                            
                                            if (foundError.code == "C022") {
                                                print("already following")
                                                feedData.extraData.followed = true
//                                                print(feedData.extraData.followed)
                                            }

                                        }
                                    }
                                }
                            }
                        }) {
                            if ((self.feedData.extraData.followed ?? false) == true) {
                                Image(systemName: "person.badge.minus")
                                Text("Unfollow User")
                            } else {
                                Image(systemName: "person.badge.plus")
                                Text("Follow User")
                            }
                        }
                        .buttonStyle(PlainButtonStyle())
                        Spacer()
                    }
                }
                
                HStack {
                    Button(action: {
                        client.hapticPress()

                        if (pinnedPost == true) {
                            client.api.users.edit_pinsRemove(postID: self.feedData.postData._id) { result in
                                switch result {
                                case .success(_):
                                    self.pinnedPost = false
                                    print("Done")
                                case .failure(let error):
                                    print("Error: \(error.localizedDescription)")
                                }
                            }
                        } else {
                            client.api.users.edit_pinsAdd(postID: self.feedData.postData._id) { result in
                                switch result {
                                case .success(_):
                                    self.pinnedPost = true
                                    print("Done")
                                case .failure(let error):
                                    print("Error: \(error.localizedDescription)")
                                }
                            }
                        }
                    }) {
                        if (pinnedPost == true) {
                            Image(systemName: "pin.slash")
                            Text("Remove Pin from Profile.")
                        } else {
                            Image(systemName: "pin")
                            Text("Pin to Profile")
                        }
                    }
                    .buttonStyle(PlainButtonStyle())
                    Spacer()
                }
                HStack {
                    Button(action: {
                        client.hapticPress()
                        let bookmarkData = PostBookmarkReq(postID: self.feedData.postData._id)
                        if (savedPost == true) {
                            client.api.posts.unsavePost(bookmarkData: bookmarkData) { result in
                                switch result {
                                case .success(_):
                                    self.savedPost = false
                                    print("Done")
                                case .failure(let error):
                                    print("Error: \(error.localizedDescription)")
                                }
                            }
                        } else {
                            client.api.posts.savePost(bookmarkData: bookmarkData) { result in
                                switch result {
                                case .success(_):
                                    self.savedPost = true
                                    print("Done")
                                case .failure(let error):
                                    print("Error: \(error.localizedDescription)")
                                }
                            }
                        }
                    }) {
                        if (savedPost == true) {
                            Image(systemName: "bookmark.slash")
                            Text("Remove from Bookmarks")
                        } else {
                            Image(systemName: "bookmark")
                            Text("Save to Bookmarks")
                        }
                    }
                    .buttonStyle(PlainButtonStyle())
                    
                    Spacer()
                }
                if (client.devMode?.isEnabled == true) {
                HStack {
                    Text("Copy Post Link")
                    Spacer()
                }
                }
                HStack {
                    Button(action: {
                        client.hapticPress()
                        DispatchQueue.main.async {
                            feedData.postLiveData.subAction=1;
                        }
                    }) {
                        Image(systemName: "clock")
                        Text("Check Edit History")
                    }
                    .buttonStyle(PlainButtonStyle())
                    Spacer()
                }
                HStack {
                    Button(action: {
                        client.hapticPress()
                        DispatchQueue.main.async {
                            feedData.postLiveData.subAction=2;
                        }
                    }) {
                        Image(systemName: "heart.text.square")
                        Text("Check Who Liked")
                    }
                    .buttonStyle(PlainButtonStyle())
                    Spacer()
                    
                }
                HStack {
                    Button(action: {
                        client.hapticPress()
                        DispatchQueue.main.async {
                            feedData.postLiveData.subAction=3;
                        }
                    }) {
                        Image(systemName: "arrowshape.turn.up.left.2")
                        Text("Check Replies")
                    }
                    .buttonStyle(PlainButtonStyle())
                    Spacer()
                }
                HStack {
                    Button(action: {
                        client.hapticPress()
                        DispatchQueue.main.async {
                            feedData.postLiveData.subAction=4;
                        }
                    }) {
                        Image(systemName: "quote.bubble")
                        Text("Check Quotes")
                    }
                    .buttonStyle(PlainButtonStyle())
                    Spacer()
                }
            }
            .padding(15)
            .background(client.themeData.mainBackground)
            .cornerRadius(20)
            .overlay(
                RoundedRectangle(cornerRadius: 20)
                    .stroke(Color.gray, lineWidth: 3)
            )
            
            if (feedData.postLiveData.subAction != 0) {
                SubExpandedPostView(client: client, feedData: $feedData)
            }
        }
        .onAppear {
            savedPost = self.feedData.extraData.saved ?? false
            pinnedPost = self.feedData.extraData.pinned ?? false
            followed = self.feedData.extraData.followed ?? false
        }
    }
}

struct SubExpandedPostView: View {
    @ObservedObject var client: Client
    @Binding var feedData: AllPosts

    var body: some View {
        VStack {
            HStack {
                Button(action: {
                    client.hapticPress()
                    feedData.postLiveData.subAction=0;
                }) {
                    Text("Close Section")
                }
                .buttonStyle(PlainButtonStyle())
                Spacer()
                
            }
            Divider()
            if (feedData.postLiveData.subAction == 1) {
                PostViewEditHistory(client: client, postID: feedData.postData._id)
            } else if (feedData.postLiveData.subAction == 2) {
                Text("Likes")
                PostViewLiked(client: client, postID: feedData.postData._id)
            } else if (feedData.postLiveData.subAction == 3) {
                Text("Replies")
                PostViewReplies(client: client, postID: feedData.postData._id)
            } else if (feedData.postLiveData.subAction == 4) {
                Text("Quotes")
                PostViewQuotes(client: client, postID: feedData.postData._id)
            }
        }
        .padding(15)
        .background(client.themeData.mainBackground)
        .cornerRadius(20)
        .overlay(
            RoundedRectangle(cornerRadius: 20)
                .stroke(Color.gray, lineWidth: 3)
        )
    }
}

struct CrapPostView: View {
    @State var postData: PostData
    
    var body: some View {
        VStack {
            HStack {
                Text("User: \(postData.userID ?? "XX")")
                Spacer()
            }
            HStack {
                Text(int64TimeFormatter(timestamp:postData.timestamp ?? 0))
                Spacer()
            }
            HStack {
                Text(postData.content ?? "unknown")
                Spacer()
            }
        }
        .padding(15)
        .cornerRadius(20)
        .overlay(
            RoundedRectangle(cornerRadius: 20)
                .stroke(Color.gray, lineWidth: 3)
        )

    }
}

struct PostViewEditHistory: View {
    @ObservedObject var client: Client
    @State var postID: String
    @State var isLoading: Bool = true
    @State var failed: Bool = false

    @State var edits: PostEditSchema?

    var body : some View {
        VStack {
            if (isLoading != true) {
                ForEach(self.edits?.edits ?? []) { edit in
                    HStack {
                        Text(edit.content)
                        Spacer()
                    }
                }
            } else  if (failed==true){
                HStack {
                    Text("Could not find any likes.")
                    Spacer()
                }
            } else {
                HStack {
                    Text("Loading edits... Or might not have any...")
                    Spacer()
                }
            }
        }
        .onAppear {
            client.api.posts.getEdits(postID: postID) { result in
                switch result {
                case .success(let edits):
                    self.edits = edits
                    print("Done")
                    self.isLoading = false
                case .failure(let error):
//                    failed=true
                    print("Error: \(error.localizedDescription)")
                }
            }
        }

    }
}

struct PostViewLiked: View {
    @ObservedObject var client: Client
    @State var postID: String
    @State var isLoading: Bool = true
    @State var failed: Bool = false

    @State var likes: PostLikesRes?
    
    var body : some View {
        VStack {
            if (isLoading != true) {
                ForEach(self.likes?.peopleLiked ?? []) { like in
                    HStack {
                        Text("@\(like.username)")
                        Spacer()
                    }
                }
            } else  if (failed==true){
                HStack {
                    Text("Could not find any likes.")
                    Spacer()
                }
            } else {
                HStack {
                    Text("Loading likes... Or might not have any...")
                    Spacer()
                }
            }
        }
        .onAppear {
            client.api.posts.getLikes(postID: postID) { result in
                switch result {
                case .success(let likes):
                    self.likes = likes
                    print("Done")
                    self.isLoading = false
                case .failure(let error):
                    failed=true
                    print("Error: \(error.localizedDescription)")
                }
                
                if (isLoading == false) {
                    failed = true
                }
            }
        }
    }
}

struct PostViewReplies: View {
    @ObservedObject var client: Client
    @State var postID: String
    @State var isLoading: Bool = true
    @State var failed: Bool = false

    @State var replies: PostReplyRes?

    var body : some View {
        VStack {
            if (isLoading != true) {
                ForEach(self.replies?.replies ?? []) { reply in
                    CrapPostView(postData: reply)
                }
            } else if (failed==true) {
                HStack {
                    Text("Post has no replies.")
                    Spacer()
                }
            } else {
                HStack {
                    Text("Loading replies... Or might not have any...")
                    Spacer()
                }
            }
        }
        .onAppear {
            client.api.posts.getReplies(postID: postID) { result in
                switch result {
                case .success(let replies):
                    self.replies = replies
                    print("Done")
                    self.isLoading = false
                case .failure(let error):
                    failed=true
                    print("Error: \(error.localizedDescription)")
                }
            }
            
            if (isLoading == false) {
                failed = true
            }
        }
    }
}

struct PostViewQuotes: View {
    @ObservedObject var client: Client
    @State var postID: String
    @State var isLoading: Bool = true
    @State var failed: Bool = false

    @State var quotes: PostQuoteRes?

    var body : some View {
        VStack {
            if (isLoading != true) {
                ForEach(self.quotes?.quotes ?? []) { quote in
                    CrapPostView(postData: quote)
                }
            } else if (failed==true) {
                HStack {
                    Text("Post has no quotes.")
                    Spacer()
                }
            } else {
                HStack {
                    Text("Loading quotes... Or might not have any...")
                    Spacer()
                }
            }
        }
        .onAppear {
            client.api.posts.getQuotes(postID: postID) { result in
                switch result {
                case .success(let quotes):
                    self.quotes = quotes
                    print("Done")
                    self.isLoading = false
                case .failure(let error):
                    failed=true
                    print("Error: \(error.localizedDescription)")
                }
                if (isLoading == false) {
                    failed = true
                }
            }
        }
    }
}

struct PostActionButtons: View {
    @ObservedObject var client: Client
    @Binding var feedData: AllPosts
    @State var deletePostConfirm: Bool = false;

    var body : some View {
        HStack {
            VStack {
                Button(action: {
                    client.hapticPress()
                    if (self.feedData.extraData.liked == true) {
                        client.api.posts.unlikePost(postID: feedData.postData._id) { result in
                            switch result {
                            case .success(let newPostData):
                                DispatchQueue.main.async {
                                    self.feedData.postData = newPostData
                                    self.feedData.extraData.liked?.toggle()
                                }
                            case .failure(let error):
                                print("Error: \(error.localizedDescription)")
                            }
                        }
                    } else {
                        client.api.posts.likePost(postID: feedData.postData._id) { result in
                            switch result {
                            case .success(let newPostData):
                                DispatchQueue.main.async {
                                    feedData.postData = newPostData
                                    feedData.extraData.liked?.toggle()
                                }
                            case .failure(let error):
                                print("Error: \(error.localizedDescription)")
                            }
                        }
                    }
                }) {
                    HStack {
                        if (self.feedData.postData.totalLikes ?? 0 != 0) {
                            Text("\(self.feedData.postData.totalLikes ?? 0)")
                        }
                        if (self.feedData.extraData.liked == true) {
                            Image(systemName: "heart.slash")
                        } else {
                            Image(systemName: "heart")
                        }
                    }
                    .padding(5)
                    .foregroundColor(self.feedData.extraData.liked == true ? .accentColor : .secondary)
                    .background(client.themeData.blueBackground)
                    .cornerRadius(10)
                }
                .buttonStyle(PlainButtonStyle())
            }
            
            VStack {
                Button(action: {
                    client.hapticPress()
                    print("reply button")
                    DispatchQueue.main.async {
                        self.feedData.postLiveData.showingPopover = false // force close
                        self.feedData.postLiveData.popoverAction = 0

                        self.feedData.postLiveData.popoverAction = 1
                        self.feedData.postLiveData.showingPopover = true
                    }
                }) {
                    HStack {
                        if (self.feedData.postData.totalReplies ?? 0 != 0) {
                            Text("\(self.feedData.postData.totalReplies ?? 0)")
                        }
                        Image(systemName: "arrowshape.turn.up.left")
                    }
                    .padding(5)
                    .foregroundColor(.secondary)
                    .background(client.themeData.blueBackground)
                    .cornerRadius(10)
                }
                .buttonStyle(PlainButtonStyle())
            }
            
            VStack {
                Button(action: {
                    client.hapticPress()
                    print("quote button")
                    DispatchQueue.main.async {
                        self.feedData.postLiveData.showingPopover = false // force close
                        self.feedData.postLiveData.popoverAction = 0

                        self.feedData.postLiveData.popoverAction = 2
                        self.feedData.postLiveData.showingPopover = true
                    }
                }) {
                    HStack {
                        if (self.feedData.postData.totalQuotes ?? 0 != 0) {
                            Text("\(self.feedData.postData.totalQuotes ?? 0)")
                        }
                        Image(systemName: "quote.closing")
                    }
                    .padding(5)
                    .foregroundColor(.secondary)
                    .background(client.themeData.blueBackground)
                    .cornerRadius(10)
                }
                .buttonStyle(PlainButtonStyle())
            }
            
            VStack {
                Button(action: {
                    client.hapticPress()
                    print("expand")
                    withAnimation(.interactiveSpring(response: 0.45, dampingFraction: 0.6, blendDuration: 0.6)) {
                        DispatchQueue.main.async {
                            self.feedData.postLiveData.actionExpanded.toggle()
                        }
                    }
                }) {
                    HStack {
                        if (self.feedData.postLiveData.actionExpanded == true) {
                            Image(systemName: "chevron.up")
                        } else {
                            Image(systemName: "chevron.down")
                        }
                    }
                    .padding(5)
                    .foregroundColor(.secondary)
                    .background(client.themeData.blueBackground)
                    .cornerRadius(10)
                }
                .buttonStyle(PlainButtonStyle())
            }
            
            Spacer()

            if (feedData.postLiveData.isOwner==true) {
                VStack {
                    Button(action: {
                        client.hapticPress()
                        DispatchQueue.main.async {
                            self.feedData.postLiveData.activeAction = 5
                            self.feedData.postLiveData.showingEditPopover = true

                        }
                    }) {
                        HStack {
                            Image(systemName: "pencil")
                        }
                        .padding(5)
                        .foregroundColor(.secondary)
                        .background(client.themeData.blueBackground)
                        .cornerRadius(10)
                    }
                    .buttonStyle(PlainButtonStyle())
                }
                VStack {
                    Button(action: {
                        client.hapticPress()
                        DispatchQueue.main.async {
                            self.feedData.postLiveData.activeAction = 4
                        }
                        self.deletePostConfirm = true
                    }) {
                        HStack {
                            Image(systemName: "trash")
                        }
                        .padding(5)
                        .foregroundColor(.secondary)
                        .background(client.themeData.blueBackground)
                        .cornerRadius(10)
                    }
                    .buttonStyle(PlainButtonStyle())
                    .confirmationDialog("Delete Post", isPresented: $deletePostConfirm) {
                        Button("Delete") {
                            client.hapticPress()
                            print("pretend delete")
                            self.deletePostConfirm = false
                            
                            client.api.posts.deletePost(postID: feedData.postData._id) { result in
                                print("api rquest login:")
                                switch result {
                                case .success(let res):
                                    if (res.deleted) {
                                        DispatchQueue.main.async {
                                            self.feedData.postLiveData.deleted = true
                                        }
                                    }
                                case .failure(let error):
                                    DispatchQueue.main.async {
                                        self.feedData.postLiveData.deleted = false
                                    }
                                    print("Error: \(error.localizedDescription)")
                                }
                            }

                            DispatchQueue.main.async {
                                self.feedData.postLiveData.deleted = true;
                            }
                        }
                        .foregroundColor(.red)
                        Button("Cancel", role: .cancel) {
                            client.hapticPress()
                            self.feedData.postLiveData.deleted = false
                        }
                    } message: {
                        Text("Confirm Post Deletion")
                    }
                }
            }
        }
    }
}

struct EditPostPopover: View {
    @ObservedObject var client: Client
    @Binding var feedData: AllPosts
    
    @State var content: String
    @State var sending: Bool = false
    @State var sent: Bool = false
    @State var failed: Bool = false
    
    var body : some View {
        VStack {
            if (self.feedData.postLiveData.activeAction==5) {
                if sending==true {
                    HStack {
                        Text("Status: ")
                        if sent==true {
                            Text("Edited!")
                        } else {
                            if failed==true {
                                Text("Failed to edit!")
                            } else {
                                Text("Editing")
                            }
                        }
                    }
                }
                VStack {
                    HStack {
                        Text(feedData.userData?.displayName ?? "")
                        Text("@\(feedData.userData?.username ?? "")")
                        if (feedData.userData?.verified == nil) {
                            Image(systemName: "checkmark.seal.fill")
                        }
                        Spacer()
                    }
                    HStack {
                        Text(feedData.postData.content ?? "")
                        Spacer()
                    }
                }
                .padding(15)
                .background(client.themeData.mainBackground)
                .cornerRadius(20)
                .overlay(
                    RoundedRectangle(cornerRadius: 20)
                        .stroke(Color.gray, lineWidth: 3)
                )
                
                VStack {
                    ZStack {
                        #if os(tvOS)
                        TextField("content", text: $content)
                        #else
                        TextEditor(text: $content)

                        if content.isEmpty {
                            VStack {
                                HStack {
                                    Text("Content")
                                        .foregroundStyle(.tertiary)
                                        .padding(.top, 8)
                                        .padding(.leading, 5)
                                    
                                    Spacer()
                                }
                                Spacer()
                            }
                        }
                        #endif
                    }

                    Button(action: {
                        client.hapticPress()
                        print("button pressed")
                        print("createPost")
                        self.sending = true
                        if (content == "") {
                            self.failed = true
                            return;
                        }
                        
                        client.api.posts.editPost(postID: self.feedData.postData._id, newContent: content) { result in
                            print("api rquest login:")
                            switch result {
                            case .success(let newPost):
                                DispatchQueue.main.async {
                                    
                                    self.feedData.postData = newPost.new
                                    self.sent = true
                                }
                                client.hapticPress()
                            case .failure(let error):
                                self.failed = true
                                print("Error: \(error.localizedDescription)")
                            }
                        }
                        self.content = ""

                    }) {
                        Text("Publish Changes")
                    }
                }
                .padding(15)
                .cornerRadius(20)
                .overlay(
                    RoundedRectangle(cornerRadius: 20)
                        .stroke(Color.gray, lineWidth: 3)
                )
            }
            Spacer()
        }
        .padding(10)
        .navigationTitle(self.feedData.postLiveData.activeAction==5 ? "Editing Post" : "Unknown Action")
    }
}

struct PopoverPostAction: View {
    @ObservedObject var client: Client
    @Binding var feedData: AllPosts

    @State var newPost:PostData?
    @State private var content: String = ""
    @State var sending: Bool = false
    @State var sent: Bool = false
    @State var failed: Bool = false

    var body : some View {
        VStack {
            if (self.feedData.postLiveData.activeAction==1) {
                Text("Relplying to Post")
            } else if (self.feedData.postLiveData.activeAction==2) {
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
                    Text(feedData.userData?.displayName ?? "")
                    Text("@\(feedData.userData?.username ?? "")")
                    if (feedData.userData?.verified == true) {
                        Image(systemName: "checkmark.seal.fill")
                    }
                    Spacer()
                }
                HStack {
                    Text(feedData.postData.content ?? "")
                    Spacer()
                }
            }
            .padding(15)
            .background(client.themeData.mainBackground)
            .cornerRadius(20)
            .overlay(
                RoundedRectangle(cornerRadius: 20)
                    .stroke(Color.gray, lineWidth: 3)
            )
            
            VStack {
                TextField("Content", text: $content)
                Button(action: {
                    client.hapticPress()
                    print("button pressed")
                    print("createPost")
                    var postCreateContent = PostCreateContent(userID: client.userTokens.userID, content: self.content)
                    print(postCreateContent)
                    
                    if (self.feedData.postLiveData.activeAction == 1) {
                        postCreateContent.replyingPostID = self.feedData.postData._id
                    } else if (self.feedData.postLiveData.activeAction == 2) {
                        postCreateContent.quoteReplyPostID = self.feedData.postData._id
                    }
                    
                    print(postCreateContent)
                    self.content = ""
                    self.sending = true
                    
                    client.api.posts.createPost(postCreateContent: postCreateContent) { result in
                        print("api rquest login:")
                        switch result {
                        case .success(let newPost):
                            self.newPost = newPost
                            self.sent = true
                            client.hapticPress()
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
                    .stroke(Color.gray, lineWidth: 3)
            )
            Spacer()

        }
        .padding(10)
        .navigationTitle(self.feedData.postLiveData.activeAction==1 ? "Reply" : self.feedData.postLiveData.activeAction==2 ? "Quote" : "Unknown Action")
    }
}

struct BasicPostView: View {
    @ObservedObject var client: Client
    @Binding var feedData: AllPosts

    var body: some View {
        VStack {
            HStack {
                Text(feedData.userData?.displayName ?? "")
                Text("@\(feedData.userData?.username ?? "")")
                if (feedData.userData?.verified != nil) {
                    Image(systemName: "checkmark.seal.fill")
                }
                Spacer()
            }
            VStack {
                Text(feedData.postData.content ?? "")
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

func ??<T>(lhs: Binding<Optional<T>>, rhs: T) -> Binding<T> {
    Binding(
        get: { lhs.wrappedValue ?? rhs },
        set: { lhs.wrappedValue = $0 }
    )
}
