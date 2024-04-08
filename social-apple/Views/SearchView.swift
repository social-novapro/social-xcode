//
//  SearchView.swift
//  social-apple
//
//  Created by Daniel Kravec on 2024-01-12.
//

import SwiftUI

struct SearchView: View {
    @ObservedObject var client: ApiClient
    @State var searchText:String = ""
    @State var foundData: Bool = false
    @State var searchData: SearchFoundData = SearchFoundData(usersFound: [], postsFound: [])
    @State var foundPosts: [AllPosts] = []
    
    var body: some View {
        VStack {
            if (foundData == true) {
                ScrollView {
                    ForEach (searchData.usersFound ?? []) { user in
                        userPreview(client: client, userData: user)
                            .padding(10)
                    }
                    ForEach ($foundPosts) { $post in
                        PostPreView(client: client, feedData: $post)
                            .padding(10)
                    }
                }
            }
            else {
                Text("Start Searching")
            }
        }
        .navigationTitle("Search")
        .searchable(text: $searchText, prompt: "Look for something")
        .onChange(of: searchText) { newValue in
            if (newValue == "") {
                foundData = false;
                return;
            }
            print(newValue)
            client.search.searchRequest(lookup: SearchLookupData(lookupkey: newValue)) { result in
                print("allpost request")
                
                switch result {
                case .success(let results):
                    if (newValue != searchText) {
                        print("canceled " + newValue)
                        return;
                    } else {
                        self.searchData = results
                        self.foundPosts = results.postsFound?.reversed() ?? []
                        print("Done")
                        self.foundData = true
                    }
                case .failure(let error):
                    print("Error: \(error.localizedDescription)")
                }
            }
        }
    }
}

struct userPreview: View {
    @ObservedObject var client: ApiClient
    @State var userData: UserData
    @State var profileShowing: Bool = false
    
    var body: some View {
        VStack {
            Button(action: {
                self.profileShowing = true;
            }) {
                VStack {
                    HStack {
                        Text(userData.displayName!)
                        Text("@" + userData.username!)
                        if (userData.verified == true) {
                            Image(systemName: "checkmark.seal.fill")
                        }
                        Spacer()
                    }
                    HStack {
                        Text(userData.description!)
                        Spacer()
                    }
                    HStack {
                        Text(String(userData.likeCount!) + " Likes - " + String(userData.likedCount!) + " Liked")
                    }
                    
                }
            }
        }
        .navigationDestination(isPresented: $profileShowing) {
            ProfileView(client: client, userData: userData)
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
