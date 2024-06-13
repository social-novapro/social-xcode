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
        NavigationView {
            VStack {
                if (foundData == true) {
                    ScrollView {
                        ForEach (searchData.usersFound ?? []) { user in
                            userPreview(client: client, userData: user)
                                .padding(10)
                        }
                        ForEach ($foundPosts) { $post in
                            postSearchPreview(client: client, feedData: $post)
                                .padding(10)
                        }
                        VStack {
                            
                        }
                        .padding(50)
                    }
                }
                else {
                    Text("Start Searching")
                }
            }
        }
        
        .navigationTitle("Search")
        .searchable(text: $searchText,/* placement: .toolbar,*/ prompt: "Search for something")
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

struct postSearchPreview: View {
    @ObservedObject var client: ApiClient
    @Binding var feedData: AllPosts
    @State var showingPost:Bool = false
    
    var body: some View {
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
                        }
                        
                        VStack {
                            if (feedData.quoteData != nil) {
                                VStack {
                                    if (feedData.quoteData?.quotePost != nil) {
                                        Divider()
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
                        }
                    }
                    .buttonStyle(.plain)
                }
            }
        }
        .onAppear {
            print ("showing")
        }
        
        .padding(15)
        .background(client.devMode?.isEnabled == true ? Color.red : Color.clear)
        .cornerRadius(20)
        .overlay(
            RoundedRectangle(cornerRadius: 20)
                .stroke(Color.accentColor, lineWidth: 3)
        )
        
        if (self.feedData.postLiveData.actionExpanded == true) {
            ExpandedPostView(client: client, feedData: $feedData)
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
            ProfileView(client: client, userData: userData, userID: userData._id)
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
