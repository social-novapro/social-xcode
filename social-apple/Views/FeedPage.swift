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
    
    init(client: ApiClient, feedPosts: FeedPosts) {
        self.client = client
        self.feedPosts = feedPosts
    }
    
    var body: some View {
        VStack {
            if (self.feedPosts.isLoading == false) {
                List {
                    ForEach(self.feedPosts.posts.indices, id: \.self) { index in
                        PostPreView(client: client, feedData: $feedPosts.posts[index])
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
        .onAppear {
            self.feedPosts.getFeed()
        }
        .navigationTitle("Feed")
        .toolbar {
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
        .popover(isPresented: $writingPost) {
            NavigationView {
                CreatePost(client: client)
            }
        }
        .popover(isPresented: $showProfile) {
            NavigationView {
                ProfileView(client: client, userData: client.userData)
            }
        }
    }
}
