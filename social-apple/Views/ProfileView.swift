//
//  ProfileView.swift
//  social-apple
//
//  Created by Daniel Kravec on 2023-11-28.
//

import SwiftUI

struct ProfileView : View {
    @ObservedObject var client: Client
    @ObservedObject var profileData: ProfileViewClass
    @State var userData: UserData?
    @State var userID: String?
    @State var selectedProfile: SelectedProfileData = SelectedProfileData()
    @State var userFollowingList: UserFollowListData?
    @State var userFollowerList: UserFollowListData?
    @State var selectedFollowList = 0

    init (client: Client, userData: UserData?, userID: String?) {
        self.client = client
        self.userData = userData
        self.userID = userID
        self.profileData = ProfileViewClass(client: client, userData: userData, userID: userID)
    }
    
    var body: some View {
        VStack {
            if (self.profileData.doneLoading) {
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
                                PostPreView(client: client, feedData: $profileData.pinData[index], selectedProfile: $selectedProfile)
                                    .frame(maxWidth: .infinity, maxHeight: .infinity)
#if !os(tvOS)
                                    .listRowSeparator(.hidden)
#endif
                                    .listRowInsets(EdgeInsets())
                                    .padding(10)
                            }
                            EmptyView()
                                .padding(.bottom, 20)
                        }
                        .listStyle(.plain)
#if !os(tvOS)
                        .listRowSeparator(.hidden)
#endif

                    }
                    .frame(maxWidth: .infinity, maxHeight: .infinity)

                    VStack {
                        Text("User Posts")

                        List {
                            ForEach(self.profileData.postData.indices, id: \.self) { index in
                                PostPreView(client: client, feedData: $profileData.postData[index], selectedProfile: $selectedProfile)
                                    .frame(maxWidth: .infinity, maxHeight: .infinity)
#if !os(tvOS)
                                    .listRowSeparator(.hidden)
#endif
                                    .listRowInsets(EdgeInsets())
                                    .padding(10)
                                
                                    .onAppear(){
                                        if (self.profileData.postData.last?.id == profileData.postData[index].id) {
                                            print("showing bottom")
                                            self.profileData.nextUserPostsIndex()
                                        }
                                    }
                            }
                            VStack {
                                
                            }
                            .padding(50)
                        }
                        .listStyle(.plain)
#if !os(tvOS)
                        .listRowSeparator(.hidden)
#endif
                    }
                    .frame(maxWidth: .infinity, maxHeight: .infinity)

                    ProfileMentionView(client: client, profileData: profileData)
                    FollowingFollowerView(client: client, userID: userID ?? "", userFollowingList: $userFollowingList,  userFollowerList: $userFollowerList, selectedFollowList: $selectedFollowList)
                    
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
//#endif

        }
        .navigationTitle("Profile of @" + (profileData.userData?.username ?? "unknown"))
        .onAppear() {
            if (self.userData != nil) {
                profileData.provBasic(userData: userData!)
            }

            Task {
                do {
                    userFollowingList = try await client.api.users.followingFollowerList(userID: userID ?? "", type: 0)
                } catch {
                    print("Failed to get following list: \(error.localizedDescription)")
                }
                // omg had to seperate cause it fails when missing a list
                do {
                    userFollowerList = try await client.api.users.followingFollowerList(userID: userID ?? "", type: 1)

                } catch {
                    print("Failed get follower list: \(error.localizedDescription)")

                }
            }
            profileData.ready()
            print("showing)")
        }
    }
}

struct ProfileMentionView: View {
    @ObservedObject var client: Client
    @ObservedObject var profileData: ProfileViewClass
    @State var selectedProfile: SelectedProfileData = SelectedProfileData()

    init(client: Client, profileData: ProfileViewClass) {
        self.client = client
        self.profileData = profileData
        print(profileData)
    }

    var body: some View {
        VStack {
            Text("User Mentions")

            List {
                ForEach(self.profileData.mentionData.indices, id: \.self) { index in
                    PostPreView(client: client, feedData: $profileData.mentionData[index], selectedProfile: $selectedProfile)
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
#if !os(tvOS)
                        .listRowSeparator(.hidden)
#endif
                        .listRowInsets(EdgeInsets())
                        .padding(10)
                }
                EmptyView()
                    .padding(.bottom, 20)
            }
#if !os(tvOS)
            .listStyle(.plain)
            .listRowSeparator(.hidden)
#endif
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}

struct ProfileUserDataView: View {
    @ObservedObject var client: Client
    @ObservedObject var profileData: ProfileViewClass
    @State var editingProfile: Bool = false
    @State var editingResults: UserEditResponse?
    @State var showEditResults: Bool = false

    init(client: Client, profileData: ProfileViewClass) {
        self.client = client
        self.profileData = profileData
    }
    
    var body: some View {
        VStack {
            if (profileData.isClient == true && editingProfile == false && showEditResults == false) {
                HStack {
                    Button(action: {
                        client.hapticPress()
                        DispatchQueue.main.async {
                            editingProfile=true
                        }
                    }) {
                        HStack {
                            Text("Edit Profile")
                        }
                        .foregroundColor(.secondary)
                    }
                    .buttonStyle(PlainButtonStyle())
                }
            }
            else if (profileData.isClient == true && editingProfile == true) {
                EditProfileView(client: client, profileData: profileData, editingProfile: $editingProfile, editingResults: $editingResults, showEditResults: $showEditResults)
                
            }
            if (showEditResults) {
                EditProfileResults(client: client, profileData: profileData, editingResults: $editingResults, showEditResults: $showEditResults)
            }
            if (!editingProfile && !showEditResults) {
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
                HStack {
                    Text(String(profileData.userData?.followingCount ?? 0) + " Following")
                    Text("|")
                    Text(String(profileData.userData?.followerCount ?? 0) + " Followers")
                    
                    if (profileData.userData?._id ?? "" != self.client.userTokens.userID) {
                        Button(action: {
                            client.hapticPress()
                            print(profileData.followed)
                            DispatchQueue.main.async {
                                Task {
                                    if (profileData.followed == true) {
                                        do {
                                            _ = try await client.api.users.unFollowUser(userID: self.profileData.userData?._id ?? "")
                                            profileData.followed = false
                                        } catch let error as ErrorData {
                                            print("ErrorData: \(error.code), \(error.msg)")
                                        } catch {
                                            print("Unexpected error: \(error)")
                                        }
                                    } else {
                                        do {
                                            //self.profileData.userDataFull?.extraData?.followed
                                            _ = try await client.api.users.followUser(userID: self.profileData.userData?._id ?? "")
                                            profileData.followed = true
                                        } catch {
                                            print("failed true" )
                                            print(error as! ErrorData)
                                        }
                                    }
                                }
                            }
                        }) {
                            Text("|")
                            if (profileData.followed == true) {
                                Text("Unfollow User")
                            } else {
                                Text("Follow User")
                            }
                        }
                        .buttonStyle(PlainButtonStyle())
                    }
                    Spacer()
                }
                if (profileData.userData!.likeCount != nil) {
                    HStack {
                        Text(String(profileData.userData!.likeCount!) + " Likes")
                        Spacer()
                    }
                }
                if (profileData.userData!.likedCount != nil) {
                    HStack {
                        Text(String(profileData.userData!.likedCount!) + " Liked Posts")
                        Spacer()
                    }
                }
                if (profileData.userData!.statusTitle != nil) {
                    HStack {
                        Text("Activity Status: " + profileData.userData!.statusTitle!)
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
        }
        // update for confirming cancel or complete
        /*
        .confirmationDialog("Delete Post", isPresented: $deletePostConfirm) {
                Button("Delete") {
                    client.hapticPress()
                    print("pretend delete")
                    self.deletePostConfirm = false
                    
    //                client.api.posts.deletePost(postID: feedData.postData._id) { result in
    //                    print("api rquest login:")
    //                    switch result {
    //                    case .success(let res):
    //                        if (res.deleted) {
    //                            DispatchQueue.main.async {
    //                                self.feedData.postLiveData.deleted = true
    //                            }
    //                        }
    //                    case .failure(let error):
    //                        DispatchQueue.main.async {
    //                            self.feedData.postLiveData.deleted = false
    //                        }
    //                        print("Error: \(error.localizedDescription)")
    //                    }
    //                }

                    DispatchQueue.main.async {
                        self.feedData.postLiveData.deleted = true;
                    }
                }
                .foregroundColor(.red)
                Button("Cancel", role: .cancel) {
                    client.hapticPress()
                    self.feedData.postLiveData.deleted = false
                }
            } message: {
                Text("Confirm Post Deletion")
            }
        }*/
        Spacer()
    }
}

struct EditChange: View {
    @ObservedObject var client: Client
    @Binding var change: UserEditChangeResponse;
    @State var fakeString: String = ""
    @State var fakeDate: Int64 = 0

    var body: some View {
        VStack {
            HStack {
                Spacer()
                VStack {
                    HStack {
                        Text(change.title)
                            .font(.headline)
                        Spacer()
                    }
                    
                    HStack {
                        Text(change.description)
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                        Spacer()
                    }
                    if (change.type == "String") {
                        HStack {
                            Text("Current: \(String(describing: change.currentValueString ?? ""))")
                            Spacer()
                        }
                        TextField("Update", text: $change.newValueString)

                    } else if (change.type == "Date") {
                        HStack {
                            if (change.currentValueDate == nil) {
                                Text("Current:")
                            } else {
                                Text("Current: \(int64TimeFormatter(timestamp: change.currentValueDate ?? 0))")
                            }
                            Spacer()
                        }
#if !os(tvOS)
                        DatePicker(selection: $change.newValueDate, in: ...Date.now, displayedComponents: .date) {
                            Text("Select a date (must be older than 13)")
                        }
#endif
                    }
                    Spacer()
                }
                .padding(10)
                .background(client.themeData.mainBackground)
                .cornerRadius(20)
                .overlay(
                    RoundedRectangle(cornerRadius: 20)
                        .stroke(Color.gray, lineWidth: 3)
                )
            }
        }
        .onChange(of: change.newValueString) { newValue in
            change.updated = true;
        }

        .onChange(of: change.newValueDate) { newValue in
            change.updated = true;
        }
    }
}

struct EditProfileResults : View {
    @ObservedObject var client: Client
    @ObservedObject var profileData: ProfileViewClass
    @Binding var editingResults: UserEditResponse?
    @Binding var showEditResults: Bool

    var body: some View {
        VStack {
            HStack {
                Text("Editing Result")
                    .foregroundColor(.secondary)
            }
            Divider()
            HStack {
                HStack {
                    Button(action: {
                        client.hapticPress()
                        DispatchQueue.main.async {
                            showEditResults=false
                        }
                    }) {
                        HStack {
                            Text("Close")
                        }
                        .foregroundColor(.secondary)
                    }
                    .buttonStyle(PlainButtonStyle())
                }
            }
            // editor
            VStack {
                ScrollView {
                    Text("Will show errors and successes here at a later date. Until then, close and reopen the profile page to see changes.")
                    // invalid fields, fails, acceptedChanges
                    
//                    ForEach(editingResults?.invalidFields ?? []) { invalid in
//                        //
//                    }
//                    ForEach(editingResults?.fails ?? []) { invalid in
//                        VStack {
//                            Text("Field Failed: \(invalid.field)")
//                            Text("Code: \(invalid.code)")
//                            Text("Message: \(invalid.msg)")
//                        }
//                        Divider()
//                    }
                    
//                    ForEach($editingResults.acceptedChanges) { accepted in
//                        
//                    }
                    
//                    ForEach($possibleEdits) { change in
//                        EditChange(client: client, change: change)
//                    }
//                    .padding(10)
                }
            }
        }
    }
}
struct EditProfileView : View {
    @ObservedObject var client: Client
    @ObservedObject var profileData: ProfileViewClass
    
    @Binding var editingProfile: Bool
    @Binding var editingResults: UserEditResponse?
    @Binding var showEditResults: Bool

    @State var doneLoading: Bool = false
    @State var possibleEdits: [UserEditChangeResponse] = [];
    
    @State var userEdited:Bool = false
    
    var body: some View {
        VStack {
            HStack {
                Text("Editing Profile")
                    .foregroundColor(.secondary)
            }
            Divider()
            HStack {
                Spacer()
                HStack {
                    Button(action: {
                        client.hapticPress()
                        DispatchQueue.main.async {
                            editingProfile=false
                        }
                    }) {
                        HStack {
                            Text("Cancel Changes")
                        }
                        .foregroundColor(.secondary)
                    }
                    .buttonStyle(PlainButtonStyle())
                }
                Spacer()
                HStack {
                    Spacer()

                    Button(action: {
                        client.hapticPress()
                        DispatchQueue.main.async {
                            // get all possible edits
                            // pass it
                            var userEditReq: [HttpReqKeyValue] = []
                            for edit in possibleEdits {
                                if (edit.updated == true) {
                                    if (edit.type == "String") {
                                        userEditReq.append(HttpReqKeyValue(key: edit.dbName, value: edit.newValueString))
                                    } else if (edit.type == "Date") {
                                        userEditReq.append(HttpReqKeyValue(key: edit.dbName, value: String(dateTimeFormatterInt64(date: edit.newValueDate))))
                                    }
                                }
                            }
                            
                            print(userEditReq)
                            Task {
                                let responseEdit = try await client.api.users.userEdit(userEditReq: userEditReq)
                                
                                self.editingResults = responseEdit
                                print(editingResults ?? "none edit profile view")
                                

                            }
                            editingProfile=false
                            showEditResults=true

//                            editingProfile=false
                        }
                    }) {
                        HStack {
                            Text("Publish Changes")
                        }
                        .foregroundColor(.primary)
                    }
                    .buttonStyle(PlainButtonStyle())
                }
                
                Spacer()
                
            }
            // editor
            VStack {
                if (doneLoading == true) {
                    ScrollView {
                        ForEach($possibleEdits) { change in
                            EditChange(client: client, change: change)
                        }
                        .padding(10)
                    }
                }
            }
        }
        .onAppear() {
            DispatchQueue.main.async {
                Task {
                    do {
                        possibleEdits = try await client.api.users.getUserEdit()
                        doneLoading = true;
                    } catch {
                        let foundError = error as! ErrorData
                        print("failed true" )
                        print(foundError)
                        if (foundError.code == "C022") {
                            print("already following")
                        }
                    }
                }
            }
        }
    }
}

struct BadgeCardView : View {
    @ObservedObject var client: Client
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
        .background(client.themeData.mainBackground)
        .cornerRadius(20)
        .overlay(
            RoundedRectangle(cornerRadius: 20)
                .stroke(Color.gray, lineWidth: 3)
        )
    }
}


struct FollowingFollowerView: View {
    @ObservedObject var client: Client
    @State var userID: String? = ""
    
    @Binding var userFollowingList: UserFollowListData?
    @Binding var userFollowerList: UserFollowListData?
    @Binding var selectedFollowList: Int
    @State var isLoading: Bool = true
    @State var failed: Bool = false
    
    var body: some View {
        VStack {
            VStack {
                VStack {
                    Text("\(selectedFollowList == 0 ? "Following" : "Followers") List")
                    Button(action: {
                        client.hapticPress()
                        if (selectedFollowList==0) {
                            selectedFollowList=1
                        } else if (selectedFollowList==1) {
                            selectedFollowList=0
                        }
                    }) {
                        Text("Switch to \(selectedFollowList == 0 ? "Followers" : "Following") List")
                            .foregroundColor(.primary)
                            .padding(15)
                            .cornerRadius(20)
                            .overlay(
                                RoundedRectangle(cornerRadius: 20)
                                    .stroke(Color.accentColor, lineWidth: 3)
                            )
                            .padding(5)
                    }
                    
                }
                if (selectedFollowList == 0) {
                    FollowingFollowerListView(client: client, userList: $userFollowingList, selectedFollowList: $selectedFollowList)
                } else if (selectedFollowList == 1) {
                    FollowingFollowerListView(client: client, userList: $userFollowerList, selectedFollowList: $selectedFollowList)
                }
            }
        }
    }
}

struct FollowingFollowerProfilePreview: View {
    @ObservedObject var client: Client
    @State var followDataPoint: UserFollowListDataPoint
    
    var body: some View {
        VStack {
            HStack {
                Text(followDataPoint.userData.displayName ?? "")
                    .foregroundColor(.secondary)
                Text("@" + (followDataPoint.userData.username ?? "unknown"))
                    .foregroundColor(.secondary)
                Spacer()
            }
            
            HStack {
                Text("Joined " + int64TimeFormatter(timestamp: followDataPoint.userData.creationTimestamp ?? 0))
                    .foregroundColor(.secondary)

                Spacer()
            }
            
            if ((followDataPoint.userData.description) != nil) {
                HStack {
                    Text(followDataPoint.userData.description ?? "no description")
                        .foregroundColor(.secondary)
                    Spacer()
                }
            }
            
            HStack {
                Text(String(followDataPoint.userData.followingCount ?? 0) + " following |")
                Text(String(followDataPoint.userData.followerCount ?? 0) + " followers")
                Spacer()
            }
            
            HStack {
                Text("Followed: " + int64TimeFormatter(timestamp: followDataPoint.followData.timestamp))
                Spacer()
            }
            
            if (client.userTokens.userID != followDataPoint.userData._id) {
                Button(action: {
                    client.hapticPress()
                    DispatchQueue.main.async {
                        Task {
                            if (followDataPoint.userData.followed == true) {
                                do {
                                    _ = try await client.api.users.unFollowUser(userID: self.followDataPoint.userData._id ?? "")
                                    followDataPoint.userData.followed = false
                                } catch let error as ErrorData {
                                    print("ErrorData: \(error.code), \(error.msg)")
                                } catch {
                                    print("Unexpected error: \(error)")
                                }
                            } else {
                                do {
                                    _ = try await client.api.users.followUser(userID: self.followDataPoint.userData._id ?? "")
                                    followDataPoint.userData.followed = true
                                } catch {
                                    print("failed true" )
                                    print(error as! ErrorData)
                                }
                            }
                        }
                    }
                }) {
                    HStack {
                        if (followDataPoint.userData.followed == true) {
                            Text("Unfollow User")
                        } else {
                            Text("Follow User")
                        }
                        Spacer()
                    }
                }
                .buttonStyle(PlainButtonStyle())
                
            }
        }
        .padding(15)
        .background(client.themeData.mainBackground)
        .cornerRadius(20)
        .overlay(
            RoundedRectangle(cornerRadius: 20)
                .stroke(Color.gray, lineWidth: 3)
        )

    }
}
struct FollowingFollowerListView: View {
    @ObservedObject var client: Client
    @Binding var userList: UserFollowListData?
    @Binding var selectedFollowList: Int

    var body: some View {
        VStack {
            if (self.userList?.data != nil) {
                List {
                    ForEach(self.userList!.data!.indices, id: \.self) { index in
                        FollowingFollowerProfilePreview(client: client, followDataPoint: self.userList!.data![index])
#if !os(tvOS)
                            .listRowSeparator(.hidden)
#endif
                            .listRowInsets(EdgeInsets())
                            .padding(10)
                            .onAppear(){
                                client.hapticPress()
                            }

                    }
                    EmptyView()
                        .padding(.bottom, 40)

                }
                .listStyle(.plain)
#if !os(tvOS)
                .listRowSeparator(.hidden)
#endif
                .refreshable {
                    client.hapticPress()
                    DispatchQueue.main.async {
                        print("refreshing")
                    }
                }
            } else {
                VStack {
                    HStack {
                        Text("No " + (selectedFollowList == 0 ? "following" : "followers") + " found")
                        Spacer()
                    }
                    Spacer()
                }
            }
        }
        .onAppear() {
            print("onAppear, selectedFollowList: \(selectedFollowList)")
            print("if found and type is \(String(userList?.type ?? 3)) \(String(userList?.found ?? false))")
        }
    }
}

