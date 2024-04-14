//
//  PostView.swift
//  social-apple
//
//  Created by Daniel Kravec on 2023-04-20.
//

import SwiftUI


struct PostPreView: View {
    @ObservedObject var client: ApiClient
    @Binding var feedData: AllPosts

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
                            PostPreviewView(client: client, feedData: $feedData)
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
            .popover(isPresented: $feedData.postLiveData.showingPopover) {
                NavigationView {
                    PopoverPostAction(client: client, feedData: $feedData)
                }
            }
            .popover(isPresented: $feedData.postLiveData.showingEditPopover) {
                NavigationView {
                    EditPostPopover(client: client, feedData: $feedData)
                }
            }
            .navigationDestination(isPresented: $feedData.postLiveData.showPostPage) {
                PostView(client: client, feedData: $feedData)
            }
            .onAppear {
                print ("showing")
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
    }
}

struct PostPreviewView: View {
    @ObservedObject var client: ApiClient
    @Binding var feedData: AllPosts

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
                    ProfilePostView(client: client, feedData: $feedData)
                }
                Spacer()
                HStack {
                    VStack {
                        Text(feedData.postData.content!)
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
                            .foregroundColor(.secondary)
                            .background(client.devMode?.isEnabled == true ? Color.green : Color.clear)
                            
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
    @ObservedObject var client: ApiClient
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
            VStack {
                HStack {
                    Text(feedData.replyData?.replyPost?.content ?? "")
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
                .stroke(Color.gray, lineWidth: 3)
        )
    }
}

struct ProfilePostView: View {
    @ObservedObject var client: ApiClient
    @Binding var feedData: AllPosts

    @State var profileShowing: Bool = false;
    
    var body: some View {
        VStack {
            Button(action: {
                client.hapticPress()
                DispatchQueue.main.async {
                    feedData.postLiveData.isActive=true
                    profileShowing = true
                    self.feedData.postLiveData.isSpecificPageActive.toggle()
                }
                print("showing usuer?")
            }) {
                VStack {
                    HStack {
                        Text(feedData.userData?.displayName ?? "")
                        Text("@\(feedData.userData?.username ?? "")")
                        if (feedData.userData?.verified == true) {
                            Image(systemName: "checkmark.seal.fill")
                        }
                        Spacer()
                    }
                    .foregroundColor(feedData.postLiveData.isOwner==true ? .accentColor : .primary)
                   
                    if (self.feedData.coposterData != nil) {
                        ForEach(self.feedData.coposterData ?? []) { coposter in
                            HStack {
                                Text(coposter.displayName ?? "")
                                Text("@\(coposter.username ?? "")")
                                if (coposter.verified == true) {
                                    Image(systemName: "checkmark.seal.fill")
                                }
                                Spacer()
                            }
                            .foregroundColor(coposter._id == client.userTokens.userID ? .accentColor : .primary)
                        }
                    }
                        
                    HStack {
                        Text(int64TimeFormatter(timestamp: feedData.postData.timestamp ?? 0))
                        Spacer()
                    }
                    .foregroundColor(feedData.postLiveData.isOwner==true ? .accentColor : .primary)
                }
                .buttonStyle(PlainButtonStyle())
            }
            .buttonStyle(PlainButtonStyle())
            .onAppear {
                print(self.feedData.coposterData ?? "none")
            }
            .navigationDestination(isPresented: $profileShowing) {
                ProfileView(client: client, userData: feedData.userData ?? nil)
            }
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
    @ObservedObject var client: ApiClient
    @Binding var feedData: AllPosts

    @State var savedPost: Bool?
    @State var pinnedPost: Bool?
    
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
                HStack {
                    Text("Expanded action area")
                        .underline()
                    Spacer()
                }
                HStack {
                    
                    Button(action: {
                        client.hapticPress()

                        if (pinnedPost == true) {
                            client.users.edit_pinsRemove(postID: self.feedData.postData._id) { result in
                                switch result {
                                case .success(_):
                                    self.pinnedPost = false
                                    print("Done")
                                case .failure(let error):
                                    print("Error: \(error.localizedDescription)")
                                }
                            }
                        } else {
                            client.users.edit_pinsAdd(postID: self.feedData.postData._id) { result in
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
                            Text("Remove Pin from Profile.")
                        } else {
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
                            client.posts.unsavePost(bookmarkData: bookmarkData) { result in
                                switch result {
                                case .success(_):
                                    self.savedPost = false
                                    print("Done")
                                case .failure(let error):
                                    print("Error: \(error.localizedDescription)")
                                }
                            }
                        } else {
                            client.posts.savePost(bookmarkData: bookmarkData) { result in
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
                            Text("Remove from Bookmarks")
                        } else {
                            Text("Save to Bookmarks")
                        }
                    }
                    .buttonStyle(PlainButtonStyle())
                    
                    Spacer()
                }
                HStack {
                    Text("Copy Post Link")
                    Spacer()
                }
                HStack {
                    Button(action: {
                        client.hapticPress()
                        DispatchQueue.main.async {
                            feedData.postLiveData.subAction=1;
                        }
                    }) {
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
                        Text("Check Quotes")
                    }
                    .buttonStyle(PlainButtonStyle())
                    Spacer()
                }
            }
            .padding(15)
            .background(client.devMode?.isEnabled == true ? Color.red : Color.clear)
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
        }
    }
}

struct SubExpandedPostView: View {
    @ObservedObject var client: ApiClient
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
        .background(client.devMode?.isEnabled == true ? Color.red : Color.clear)
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
    @ObservedObject var client: ApiClient
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
            client.posts.getEdits(postID: postID) { result in
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
    @ObservedObject var client: ApiClient
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
            client.posts.getLikes(postID: postID) { result in
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
    @ObservedObject var client: ApiClient
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
            client.posts.getReplies(postID: postID) { result in
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
    @ObservedObject var client: ApiClient
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
            client.posts.getQuotes(postID: postID) { result in
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
    @ObservedObject var client: ApiClient
    @Binding var feedData: AllPosts
    @State var deletePostConfirm: Bool = false;

    var body : some View {
        HStack {
            VStack {
                Button(action: {
                    client.hapticPress()
                    if (self.feedData.extraData.liked == true) {
                        client.posts.unlikePost(postID: feedData.postData._id) { result in
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
                        client.posts.likePost(postID: feedData.postData._id) { result in
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
                    .background(client.devMode?.isEnabled == true ? Color.blue : Color.clear)
                    .cornerRadius(10)
                }
                .buttonStyle(PlainButtonStyle())
            }
            
            VStack {
                Button(action: {
                    client.hapticPress()
                    print("reply button")
                    DispatchQueue.main.async {
                        self.feedData.postLiveData.activeAction = 1
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
                    .background(client.devMode?.isEnabled == true ? Color.blue : Color.clear)
                    .cornerRadius(10)
                }
                .buttonStyle(PlainButtonStyle())
            }
            
            VStack {
                Button(action: {
                    client.hapticPress()
                    print("quote button")
                    DispatchQueue.main.async {
                        self.feedData.postLiveData.activeAction = 2
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
                    .background(client.devMode?.isEnabled == true ? Color.blue : Color.clear)
                    .cornerRadius(10)
                }
                .buttonStyle(PlainButtonStyle())
            }
            
            VStack {
                Button(action: {
                    client.hapticPress()
                    print("action")
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
                    .background(client.devMode?.isEnabled == true ? Color.blue : Color.clear)
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
                        .background(client.devMode?.isEnabled == true ? Color.blue : Color.clear)
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
                        .background(client.devMode?.isEnabled == true ? Color.blue : Color.clear)
                        .cornerRadius(10)
                    }
                    .buttonStyle(PlainButtonStyle())
                    .confirmationDialog("Delete Post", isPresented: $deletePostConfirm) {
                        Button("Delete") {
                            client.hapticPress()
                            print("pretend delete")
                            self.deletePostConfirm = false
                            
                            client.posts.deletePost(postID: feedData.postData._id) { result in
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
    @ObservedObject var client: ApiClient
    @Binding var feedData: AllPosts
    
    @State private var content: String = ""
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
                .background(client.devMode?.isEnabled == true ? Color.red : Color.clear)
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
                        self.sending = true
                        if (content == "") {
                            self.failed = true
                            return;
                        }
                        
                        client.posts.editPost(postID: self.feedData.postData._id, newContent: content) { result in
                            print("api rquest login:")
                            switch result {
                            case .success(let newPost):
                                self.feedData.postData = newPost.new
                                self.sent = true
                                client.hapticPress()
                            case .failure(let error):
                                self.failed = true
                                print("Error: \(error.localizedDescription)")
                            }
                        }
                        self.content = ""

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
            }
            Spacer()
        }
        .padding(10)
        .navigationTitle(self.feedData.postLiveData.activeAction==5 ? "Editing Post" : "Unknown Action")
    }
}

struct PopoverPostAction: View {
    @ObservedObject var client: ApiClient
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
            .background(client.devMode?.isEnabled == true ? Color.red : Color.clear)
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
                    
                    client.posts.createPost(postCreateContent: postCreateContent) { result in
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
    @ObservedObject var client: ApiClient
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
