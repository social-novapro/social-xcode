//
//  FeedPage.swift
//  social-apple
//
//  Created by Daniel Kravec on 2023-04-21.
//

import SwiftUI

struct FeedPage: View {
    @ObservedObject var client: ApiClient
    @ObservedObject var feedPosts: FeedPosts

    @State var userData: UserData?
    @State var writingPost: Bool = false
    @State var showProfile: Bool = false
    
    
    @State private var selectedPostIndex: Int?
    @State var selectedPost: Bool = false
    
    init(client: ApiClient, feedPosts: FeedPosts) {
        self.client = client
        self.feedPosts = feedPosts
    }
    
    var body: some View {
        NavigationStack {
            VStack {
                if (self.feedPosts.isLoading == false) {
                    List {
                        ForEach(self.feedPosts.posts.indices, id: \.self) { index in
                            PostFeedPreView(client: client, feedData: $feedPosts.posts[index], selectedPostIndex: $selectedPostIndex, selectedPost: $selectedPost, currentPostIndex: index)
                                .listRowSeparator(.hidden)
                                .listRowInsets(EdgeInsets())
                                .padding(10)
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
                    .listRowSeparator(.hidden)
                    .refreshable {
                        client.hapticPress()
                        DispatchQueue.main.async {
                            feedPosts.refreshFeed()
                        }
                    }
                }
                else {
                    Text("loading feed")
                }
            }
            .navigationDestination(isPresented: $selectedPost) {
                if let selectedPostIndex = selectedPostIndex {
                    PostView(client: client, feedData: $feedPosts.posts[selectedPostIndex])
                }
            }
            .onAppear {
                self.feedPosts.getFeed()
            }
            .navigationTitle("Feed")
            .toolbar {
                FeedToolBarPage(client: client, feedPosts: feedPosts, writingPost: $writingPost, showProfile: $showProfile)
            }
            .sheet(isPresented: $writingPost) {
                NavigationView {
                    CreatePost(client: client)
                }
            }
            .sheet(isPresented: $showProfile) {
                NavigationView {
                    ProfileView(client: client, userData: client.userData, userID: client.userTokens.userID)
                }
            }
        }
    }
}

struct FeedToolBarPage : View {
    @ObservedObject var client: ApiClient
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
