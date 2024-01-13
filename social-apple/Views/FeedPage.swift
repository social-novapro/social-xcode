//
//  FeedPage.swift
//  social-apple
//
//  Created by Daniel Kravec on 2023-04-21.
//

import SwiftUI

struct FeedPage: View {
    @ObservedObject var client: ApiClient
    @State var userData: UserData?
    @State var isLoading:Bool = true
    
    @State var feed: FeedV2Data?
    @State var writingPost: Bool = false
    @State var showProfile: Bool = false
//    @State var allPosts: [AllPosts]? = []
//    @State var originalPosts = [AllPosts]();
    
    var body: some View {
        VStack {
            if (!isLoading) {
                childFeed(client: client, feedIn: $feed)
            }
            else {
                Text("loading feed")
            }
        }
        .onAppear {
            client.posts.getUserFeed(userTokens: client.userTokens) { result in
                print("allpost request")
                
                switch result {
                case .success(let feed):
                    self.feed = feed
                    print("Done")
                    self.isLoading = false
                case .failure(let error):
                    print("Error: \(error.localizedDescription)")
                }
            }
        }
        .navigationTitle("Feed")
        .toolbar {
            HStack {
                Button(action: {
                    self.writingPost = true;
                }, label: {
                    HStack {
                        Image(systemName: "pencil.circle")
                            .foregroundColor(.accentColor)
                            .font(.system(size: 22))
                    }
                })
                .buttonStyle(.plain)
                Button(action: {
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

struct childFeed: View {
    @ObservedObject var client: ApiClient
    
    @Binding var feedIn: FeedV2Data?
    @State var feed: FeedV2Data?
    @State var allPosts: [AllPosts]?
    @State var showData: Bool = false
    @State var activePost: AllPosts?
    @State var activeAction: Int32 = 0
    @State var loadingScroll: Bool = false
    
    /*
     0=none
     1=reply
     2=quote
     3=share
     */
    
    var body: some View {
        VStack {
            if showData {
                List {
                    ForEach(allPosts!) { post in
                        PostPreView(client: client, feedDataIn: post)
                            .listRowSeparator(.hidden)
                            .listRowInsets(EdgeInsets())
                            .padding(10)
                            .onAppear(){
                                if (self.feed!.posts.last == post && self.loadingScroll == false){
                                    self.loadingScroll = true
                                    client.posts.getUserFeedIndex(userTokens: client.userTokens, index: self.feed?.prevIndexID ?? "") { result in
                                        switch result {
                                        case .success(let feed):
                                            self.feed = feed
                                            self.allPosts! += feed.posts
                                            self.loadingScroll = false
                                        case .failure(let error):
                                            print("Error: \(error.localizedDescription)")
                                        }
                                    }
                                }
                            }
                    }
                }
                .refreshable {
                    client.posts.getUserFeed(userTokens: client.userTokens) { result in
                        switch result {
                        case .success(let feedData):
                            self.feed = feedData
                            self.allPosts = feed!.posts
                        case .failure(let error):
                            print("Error: \(error.localizedDescription)")
                        }
                    }
               }
                .listStyle(.plain)
                .listRowSeparator(.hidden)
            }
            else {
                Text("Loading")
            }
        }
        .onAppear {
            self.feed = self.feedIn
            self.allPosts = feed!.posts
            if (feed != nil) {
                showData = true;
                print ("showing? why is it so many times")
            }
        }
    }
}
