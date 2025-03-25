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
    
    @State private var selectedPostIndex: Int?
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
                        ForEach(self.feedPosts.posts.indices, id: \.self) { index in
                            PostFeedPreView(client: client, feedData: $feedPosts.posts[index], selectedPostIndex: $selectedPostIndex, selectedPost: $selectedPost, selectedProfile: $selectedProfile, currentPostIndex: index)
                                #if !os(tvOS)
                                .listRowSeparator(.hidden)
                                #endif
                                .listRowInsets(EdgeInsets())
                                .padding(10)
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
                                    if (self.feedPosts.posts.last?.id == feedPosts.posts[index].id && self.feedPosts.loadingScroll == false) {
                                        client.hapticPress()
                                        
                                        self.feedPosts.loadingScroll = true
                                        
                                        if (self.feedPosts.feed.prevIndexID != nil) {
                                            DispatchQueue.main.async {
                                                feedPosts.nextIndex()
                                            }
                                        }
                                    }
                                }
                        }
                    }
                    .listStyle(.plain)
                    #if !os(tvOS)
                    .listRowSeparator(.hidden)
                    #endif
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
            .navigationDestination(isPresented: $selectedPost) {
                if let selectedPostIndex = selectedPostIndex {
                    PostView(client: client, feedData: $feedPosts.posts[selectedPostIndex], selectedProfile: $selectedProfile)
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
