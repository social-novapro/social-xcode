//
//  FeedPage.swift
//  social-apple
//
//  Created by Daniel Kravec on 2023-04-21.
//

import SwiftUI

struct FeedPage: View {
    @ObservedObject var client: Client
    @ObservedObject var feedPosts: FeedPosts
//    @ObservedObject var postActiveData: PostActiveData

    @State var userData: UserData?
    @State var writingPost: Bool = false
    @State var showProfile: Bool = false
    
    @State private var selectedPostID: String?
    @State var selectedPost: Bool = false
    @State var selectedProfile: SelectedProfileData = SelectedProfileData()
    
    init(client: Client, feedPosts: FeedPosts) {
        self.client = client
        self.feedPosts = feedPosts
//        self._postActiveData = .init(wrappedValue: PostActiveData(client: client, postData: feedData.wrappedValue))
    }
    
    var body: some View {
        NavigationStack {
            VStack {
                if (self.feedPosts.isLoading == false) {
                    // FIX - BUG WHEN CLOSING REQUESTS THEN SCROLLING 
                    if (self.feedPosts.copostsFound) {
                        CopostRequestsHyper(client: client, feedPosts: feedPosts)
                            .padding(10)
                    }
                    
                    List {
                        ForEach(self.feedPosts.posts, id: \.postData._id) { post in
                            let postID = post.postData._id
                            
                            PostFeedPreView(client: client, feedData: postBinding(for: postID, fallback: post), selectedPostID: $selectedPostID, selectedPost: $selectedPost, selectedProfile: $selectedProfile)
                                .interactPlainListRow()
//                                .onpress
                                /*.swipeActions(allowsFullSwipe: false) {
                                    Button {
                                        print("Muting conversation")
                                    } label: {
                                        Label("Mute", systemImage: "bell.slash.fill")
                                    }
                                    .tint(.indigo)
                                    Button(role: .destructive) {
                                        print("Deleting conversation")
                                    } label: {
                                        Label("Delete", systemImage: "trash.fill")
                                    }
                                }*/
                                .onAppear(){
                                    if (self.feedPosts.posts.last?.postData._id == postID) {
                                        self.feedPosts.nextIndex()
                                    }
                                }
                        }
                    }
                    .onChange(of: client.loggedIn, perform: { newValue in
                        if (newValue == true) {
                            client.hapticPress()
                            DispatchQueue.main.async {
                                self.feedPosts.refreshFeed()
    //                            self.feedPosts.getCopostRequests()
                            }

                        }
                    })
                    .interactCardListScreen()
                    .refreshable {
                        client.hapticPress()
                        DispatchQueue.main.async {
                            self.feedPosts.refreshFeed()
//                            self.feedPosts.getCopostRequests()
                        }
                    }
                }
                else {
                    Text("loading feed")
                }
            }
            .interactAppBackground()
            .navigationDestination(isPresented: $selectedPost) {
                if let selectedPostID,
                   let selectedPostBinding = currentPostBinding(for: selectedPostID) {
                    PostView(client: client, feedData: selectedPostBinding, selectedProfile: $selectedProfile)
                } else {
                    EmptyView()
                        .onAppear {
                            selectedPost = false
                            selectedPostID = nil
                        }
                }
            }
            .sheet(isPresented: $selectedProfile.showProfile) {
                NavigationView {
                    ProfileView(client: client, userData: selectedProfile.profileData, userID: selectedProfile.userID)
                }
            }
            .onAppear {
                self.feedPosts.getFeed()
//                self.feedPosts.getCopostRequests()
            }
            
            .navigationTitle("Feed")
            .toolbar {
                FeedToolBarPage(client: client, feedPosts: feedPosts, writingPost: $writingPost, showProfile: $showProfile)
            }
            .sheet(isPresented: $writingPost) {
                #if os(iOS)
                NavigationView {
                    CreatePost(client: client)
                }
                #else
                CreatePost(client: client)
                #endif

            }
            .sheet(isPresented: $showProfile) {
                #if os(iOS)
                NavigationView {
                    ProfileView(client: client, userData: client.userData, userID: client.userTokens.userID)
                }
                #else
                ProfileView(client: client, userData: client.userData, userID: client.userTokens.userID)
                #endif
            }
        }
    }
    
    private func postBinding(for postID: String, fallback: AllPosts) -> Binding<AllPosts> {
        Binding {
            feedPosts.posts.first { $0.postData._id == postID } ?? fallback
        } set: { updatedPost in
            guard let index = feedPosts.posts.firstIndex(where: { $0.postData._id == postID }) else {
                return
            }
            feedPosts.posts[index] = updatedPost
        }
    }
    
    private func currentPostBinding(for postID: String) -> Binding<AllPosts>? {
        guard let fallback = feedPosts.posts.first(where: { $0.postData._id == postID }) else {
            return nil
        }
        
        return postBinding(for: postID, fallback: fallback)
    }
}

struct FeedToolBarPage : View {
    @ObservedObject var client: Client
    @ObservedObject var feedPosts: FeedPosts
    @Binding var writingPost: Bool
    @Binding var showProfile: Bool
    
    var body: some View {
        HStack {
            Button(action: {
                client.hapticPress()
                self.writingPost = true;
            }, label: {
                HStack {
                    Image(systemName: "plus.circle")
                        .foregroundColor(.accentColor)
                        .font(.system(size: 22))
                }
            })
            .buttonStyle(.plain)
        }
        HStack {
            Button(action: {
                client.hapticPress()
                self.showProfile = true;
            }, label: {
                HStack {
                    Image(systemName: "person.circle")
                        .foregroundColor(.accentColor)
                        .font(.system(size: 22))
                }
            })
            .buttonStyle(.plain)
        }
    }
}
