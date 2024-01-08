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
    
    @State var allPosts: [AllPosts]? = []
    @State var originalPosts = [AllPosts]();
    
    var body: some View {
        VStack {
            if (!isLoading) {
                childFeed(client: client, allPostsIn: $allPosts)
            }
            else {
                Text("loading feed")
            }
        }
        .onAppear {
            client.posts.getAllPosts(userTokens: client.userTokens) { result in
                print("allpost request")
                
                switch result {
                case .success(let allPosts):
                    self.allPosts = allPosts
                    print("Done")
                    self.isLoading = false
                case .failure(let error):
                    print("Error: \(error.localizedDescription)")
                }
            }
        }
        .navigationTitle("Feed")
    }
}

struct childFeed: View {
    @ObservedObject var client: ApiClient
    @Binding var allPostsIn: [AllPosts]?
    @State var allPosts: [AllPosts]?
    @State var showData: Bool = false
    @State var activePost: AllPosts?
    @State var activeAction: Int32 = 0
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
                                if (self.allPosts?.last == post){
                                    print("hit bottom")
    //                                newsfeed.loadData(pageNum: page + 1)
    //                                self.page =+ 1
                                }
                            }

                    }
                }
                .refreshable {
                    client.posts.getAllPosts(userTokens: client.userTokens) { result in
                        switch result {
                        case .success(let allPosts):
                            self.allPosts = allPosts
                            print("Done")
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
            allPosts = self.allPostsIn
            if (allPosts != nil) {
                showData = true;
                print ("showing? why is it so many times")
            }
        }
    }
}
