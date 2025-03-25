//
//  SearchView.swift
//  social-apple
//
//  Created by Daniel Kravec on 2024-01-12.
//

import SwiftUI

struct SearchView: View {
    @ObservedObject var client: Client
    @ObservedObject var searchClass: SearchClass
    
    init(client: Client) {
        self.client = client;
        self.searchClass = SearchClass(client: client)
    }

    @State var searchText:String = ""

    var body: some View {
        NavigationView {
            VStack {
                if (searchClass.foundData == true) {
                    ScrollView {
                        VStack {
                            if (searchClass.searchResults.usersFound?.isEmpty != true) {
                                FancyText(text: "Users Found")
                            }
                            ForEach (searchClass.searchResults.usersFound ?? []) { user in
                                userPreview(client: client, userData: user)
                            }
                            if (searchClass.searchResults.hashtagsFound?.isEmpty != true) {
                                FancyText(text: "Related Hashtags")
                            }
                            ForEach ($searchClass.searchResults.hashtagsFound ?? []) { $tag in
                                FancyText(text: tag.tag)
                            }
                            // exported out cause xcode complains a lot
                            SearchHashtagResultsView(client: client, searchClass: searchClass)
                            if (searchClass.searchResults.postsFound?.isEmpty != true) {
                                FancyText(text: "Posts Found")

                            }
                            SearchPostResultsView(client: client, searchClass: searchClass)
                            
                            VStack {
                                
                            }
                            .padding(50)
                        }
                        .padding(10)
                    }
                }
                else {
                    Text("Start Searching")
                }
            }
        }
        
        .navigationTitle("Search")
        .searchable(text: $searchClass.searchText,/* placement: .toolbar,*/ prompt: "Search for something")
        .onChange(of: searchClass.searchText) { newValue in
            self.searchClass.search(newValue: newValue)
        }
    }
}

struct SearchHashtagResultsView: View {
    @ObservedObject var client: Client
    @ObservedObject var searchClass: SearchClass

    var body: some View {
        ForEach($searchClass.searchResults.tagsFound ?? []) { $tag in
            if (tag.posts?.isEmpty != true) {
                FancyText(text: "Posts for \(tag.tag)")
            }

            ForEach($tag.posts ?? []) { $post in
                postSearchPreview(client: client, feedData: $post)
            }
        }
    }
}

struct SearchPostResultsView: View {
    @ObservedObject var client: Client
    @ObservedObject var searchClass: SearchClass

    var body: some View {
        ForEach ($searchClass.searchResults.postsFound ?? []) { $post in
            postSearchPreview(client: client, feedData: $post)
        }
    }
}

struct postSearchPreview: View {
    @ObservedObject var client: Client
    @Binding var feedData: AllPosts
    @State var showingPost:Bool = false
    @State var selectedProfile:SelectedProfileData = SelectedProfileData()
    
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
                                ProfilePostView(client: client, feedData: $feedData, selectedProfile: $selectedProfile)
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
                            .background(client.themeData.greenBackground)
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
                                        .background(client.themeData.greenBackground)
                                        
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
        .background(client.themeData.mainBackground)
        .cornerRadius(20)
        .overlay(
            RoundedRectangle(cornerRadius: 20)
                .stroke(Color.secondary, lineWidth: 3)
        )
        
        if (self.feedData.postLiveData.actionExpanded == true) {
            ExpandedPostView(client: client, feedData: $feedData)
        }
    }
}

struct userPreview: View {
    @ObservedObject var client: Client
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
        .background(client.themeData.mainBackground)
        .cornerRadius(20)
        .overlay(
            RoundedRectangle(cornerRadius: 20)
                .stroke(Color.accentColor, lineWidth: 3)
        )
    }
}
