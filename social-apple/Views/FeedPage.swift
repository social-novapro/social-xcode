//
//  FeedPage.swift
//  social-apple
//
//  Created by Daniel Kravec on 2023-04-21.
//

import SwiftUI

struct FeedPage: View {
    @Binding var userTokenData: UserTokenData?
//^ turn to state when using init
    //    @Binding var userID: String?
    let api_requests = API_Rquests()

    @State var userData: UserData?
    @State var isLoading:Bool = true
    
    @State var allPosts: [AllPosts]? = []
    @State var originalPosts = [AllPosts]();
    
    var body: some View {
        VStack {
            if (!isLoading) {
                childFeed(userTokenData: $userTokenData, allPostsIn: $allPosts)
            }
            else {
                Text("loading feed")
            }
        }
        .onAppear {
            api_requests.getAllPosts(userTokens: userTokenData ?? UserTokenData(accessToken: "", userToken: "", userID: "")) { result in
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
    @Binding var userTokenData: UserTokenData?
    @Binding var allPostsIn: [AllPosts]?
    @State var allPosts: [AllPosts]?
    @State var showData: Bool = false
    
    var body: some View {
        VStack {
            if showData {
                List {
                    ForEach(allPosts!) { post in
                        PostPreView(userTokenData: $userTokenData, feedDataIn: post)
                    }
                }
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
