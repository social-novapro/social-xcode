//
//  ProfileView.swift
//  social-apple
//
//  Created by Daniel Kravec on 2023-11-28.
//

import SwiftUI

struct ProfileView : View {
    @ObservedObject var client: ApiClient
    @ObservedObject var profileData: ProfileViewClass
    @State var userData: UserData?
    @State var userID: String?

    init (client: ApiClient, userData: UserData?, userID: String?) {
        self.client = client
        self.userData = userData
        self.userID = userID
        self.profileData = ProfileViewClass(client: client, userData: userData ?? nil, userID: userID)
    }
    
    var body: some View {
        VStack {
            if (profileData.doneLoading) {
                TabView {
                    VStack {
                        Text("Quick Info")

                        ProfileUserDataView(client: client, profileData: profileData)
                    }
                    .frame(maxWidth: .infinity, maxHeight: .infinity)

                    VStack {
                        Text("User Badges")
                        
                        ScrollView(.vertical, showsIndicators: false) {
                            ForEach(profileData.badgeData, id: \.id) { badge in
                                BadgeCardView(client: client, badgeData: badge)
                                    .padding(10)
                            }
                            EmptyView()
                                .padding(.bottom, 20)
                        }
                    }
                    .frame(maxWidth: .infinity, maxHeight: .infinity)

                    VStack {
                        Text("User Pins")

                        List {
                            ForEach(self.profileData.pinData.indices, id: \.self) { index in
                                PostPreView(client: client, feedData: $profileData.pinData[index])
                                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                                    .listRowSeparator(.hidden)
                                    .listRowInsets(EdgeInsets())
                                    .padding(10)
                            }
                            EmptyView()
                                .padding(.bottom, 20)
                        }
                        .listStyle(.plain)
                        .listRowSeparator(.hidden)

                    }
                    .frame(maxWidth: .infinity, maxHeight: .infinity)

                    VStack {
                        Text("User Posts")

                        List {
                            ForEach(self.profileData.postData.indices, id: \.self) { index in
                                PostPreView(client: client, feedData: $profileData.postData[index])
                                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                                    .listRowSeparator(.hidden)
                                    .listRowInsets(EdgeInsets())
                                    .padding(10)
                            }
                            VStack {
                                
                            }
                            .padding(50)
                        }
                        .listStyle(.plain)
                        .listRowSeparator(.hidden)
                    }
                    .frame(maxWidth: .infinity, maxHeight: .infinity)

                    ProfileMentionView(client: client, profileData: profileData)
//                    VStack {
//                        Text("User Mentions")
//
//                        List {
//                            ForEach(self.profileData.mentionData.indices, id: \.self) { index in
//                                PostPreView(client: client, feedData: $profileData.mentionData[index])
//                                    .frame(maxWidth: .infinity, maxHeight: .infinity)
//                                    .listRowSeparator(.hidden)
//                                    .listRowInsets(EdgeInsets())
//                                    .padding(10)
//                            }
//                            EmptyView()
//                                .padding(.bottom, 20)
//                        }
//                        .listStyle(.plain)
//                        .listRowSeparator(.hidden)
//
//                    }
//                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                }
                .padding(15)
#if os(iOS)
                .tabViewStyle(PageTabViewStyle())
                .indexViewStyle(PageIndexViewStyle(backgroundDisplayMode: .always))
#endif
            } else {
                if ((profileData.userData) != nil) {
                    TabView {
                        VStack {
                            Text("Quick Info")
                            ProfileUserDataView(client: client, profileData: profileData)
                        }
                    }
                    .padding(10)
#if os(iOS)
                    .tabViewStyle(PageTabViewStyle())
                    .indexViewStyle(PageIndexViewStyle(backgroundDisplayMode: .always))
#endif
                } else {
                    Text("Loading")
                }
            }
        }
        .onAppear() {
            if (self.userData != nil) {
                profileData.provBasic(userData: userData!)
            }
            profileData.ready()
        }
        .navigationTitle("Profile of @" + (profileData.userData?.username ?? "unknown"))
    }
}

struct ProfileMentionView: View {
    @ObservedObject var client: ApiClient
    @ObservedObject var profileData: ProfileViewClass

    init(client: ApiClient, profileData: ProfileViewClass) {
        self.client = client
        self.profileData = profileData
        print(profileData)
    }

    var body: some View {
        VStack {
            Text("User Mentions")

            List {
                ForEach(self.profileData.mentionData.indices, id: \.self) { index in
                    PostPreView(client: client, feedData: $profileData.mentionData[index])
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                        .listRowSeparator(.hidden)
                        .listRowInsets(EdgeInsets())
                        .padding(10)
                }
                EmptyView()
                    .padding(.bottom, 20)
            }
            .listStyle(.plain)
            .listRowSeparator(.hidden)

        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}

struct ProfileUserDataView: View {
    @ObservedObject var client: ApiClient
    @ObservedObject var profileData: ProfileViewClass

    init(client: ApiClient, profileData: ProfileViewClass) {
        self.client = client
        self.profileData = profileData
        print(profileData)
    }
    
    var body: some View {
        VStack {
            HStack {
                Text(profileData.userData!.displayName!)
                Text("@" + profileData.userData!.username!)
                if (profileData.userData!.verified == true) {
                    Image(systemName: "checkmark.seal.fill")
                }
                Spacer()
            }
            HStack {
                Text(profileData.userData!.description!)
                Spacer()
            }
            if (profileData.userData!.likeCount != nil) {
                HStack {
                    Text(String(profileData.userData!.likeCount!) + " Likes")
                    Spacer()
                }                }
            if (profileData.userData!.likedCount != nil) {
                HStack {
                    Text(String(profileData.userData!.likedCount!) + " Liked Posts")
                    Spacer()
                }
            }
            if (profileData.userData!.statusTitle != nil) {
                HStack {
                    Text("Status: " + profileData.userData!.statusTitle!)
                    Spacer()
                }
            }
            HStack {
                Text("Created " + int64TimeFormatter(timestamp: profileData.userData!.creationTimestamp!))
                Spacer()
            }
            if (profileData.userData!.totalPosts != nil) {
                HStack {
                    Text(String(profileData.userData!.totalPosts!) + " Total Posts")
                    Spacer()
                }
            }
            if (profileData.userData!.totalReplies != nil) {
                HStack {
                    Text(String(profileData.userData!.totalReplies!) + " Total Replies")
                    Spacer()
                }

            }
            if (profileData.userData!.totalQuotes != nil) {
                HStack {
                    Text(String(profileData.userData!.totalQuotes!) + " Total Quote Posts")
                    Spacer()
                }
            }
        }
        Spacer()
    }
}

struct BadgeCardView : View {
    @ObservedObject var client: ApiClient
    @State var badgeData: BadgeData

    var body: some View {
        HStack {
            Spacer()
            VStack {
                Spacer()

                VStack {
                    Text(badgeData.name)
                    Text(badgeData.description)
                    Text("Achieved: " + int64TimeFormatter(timestamp: badgeData.achieved));
                    Spacer()
                }
                VStack {
                    if (badgeData.showCount==true) {
                        Text("Achieved " + String(badgeData.count) + " times")
                        Text("Lastest: " + int64TimeFormatter(timestamp: badgeData.latest ?? badgeData.achieved));
                        Spacer()
                    }
                }
                Spacer()

            }
            Spacer()
        }
        .padding(10)
        .background(client.devMode?.isEnabled == true ? Color.red : Color.clear)
        .cornerRadius(20)
        .overlay(
            RoundedRectangle(cornerRadius: 20)
                .stroke(Color.gray, lineWidth: 3)
        )
//        .padding(15)
    }
}
