//
//  CreatePost.swift
//  social-apple
//
//  Created by Daniel Kravec on 2023-04-26.
//

import SwiftUI

struct CreatePost: View {
    @ObservedObject var client: Client
    @ObservedObject var postCreation: PostCreation
    @Binding var feedData: AllPosts?

    init (client: Client, feedData: Binding<AllPosts?> = .constant(nil)) {
        self.client = client
        _feedData = feedData
        self.postCreation = PostCreation(client: client, feedData: feedData.wrappedValue)
    }
    
    var body: some View {
        VStack {
            if postCreation.sent==true {
                Text("Status: Sent!")
            }
            if postCreation.sending==true {
                HStack {
                    Text("Status: ")
                    if postCreation.sent==false {
                        if postCreation.failed==true {
                            Text("Failed: " + postCreation.errorMsg)
                        } else {
                            Text("Sending")
                        }
                    }
                }
            }
            
            ScrollView {
                VStack {
                    if (self.feedData != nil) {
                        VStack {
                            HStack {
                                if (self.feedData?.postLiveData.popoverAction==1) {
                                    Text("Relplying to Post")
                                } else if (self.feedData?.postLiveData.popoverAction==2) {
                                    Text("Quoting Post")
                                }
                                Spacer()
                            }
                            Divider()
                            HStack {
                                Text(feedData?.userData?.displayName ?? "")
                                Text("@\(feedData?.userData?.username ?? "")")
                                if (feedData?.userData?.verified == true) {
                                    Image(systemName: "checkmark.seal.fill")
                                }
                                Spacer()
                            }
                            HStack {
                                Text(feedData?.postData.content ?? "")
                                Spacer()
                            }
                        }
                        .padding(15)
                        .background(client.themeData.mainBackground)
                        .cornerRadius(20)
                        .overlay(
                            RoundedRectangle(cornerRadius: 20)
                                .stroke(Color.accentColor, lineWidth: 3)
                        )
                    }
                    
                    VStack {
                        if (postCreation.remainingCharacters < 100) {
                            HStack {
                                Text("Remaining Characters \(postCreation.remainingCharacters) of \(postCreation.maxCharacters)")
                                Spacer()
                                ZStack {
                                    Circle()
                                        .stroke(lineWidth: 4)
                                        .opacity(0.1)
                                        .foregroundStyle(Color.accentColor)

                                    Circle()
                                        .trim(from: 0.0, to: abs(postCreation.remainingCharactersCG))
                                        .stroke(style: StrokeStyle(lineWidth: 4, lineCap: .round))
                                        .foregroundStyle(Color.red)
                                }
                                .frame(width: 20, height: 20)

                            }
                        }
                        
                        ZStack {
                            #if os(tvOS)
                            TextField("content", text: $postCreation.content)
                                .onChange(of: postCreation.content) { newValue in
                                    postCreation.typePost(newValue: newValue)
                                }

                            #else

                            TextEditor(text: $postCreation.content)
                                .onChange(of: postCreation.content) { newValue in
                                    postCreation.typePost(newValue: newValue)
                                    postCreation.calcRemainingCharacters();
                                }
                            
                            if postCreation.content.isEmpty {
                                VStack {
                                    HStack {
                                        Text("Content")
                                            .foregroundStyle(.tertiary)
                                            .padding(.top, 8)
                                            .padding(.leading, 5)
                                        
                                        Spacer()
                                    }
                                    Spacer()
                                }
                            }
                            #endif
                        }
                        
                        Button(action: {
                            DispatchQueue.main.async {
                                Task{
                                    do {
                                        let result = try await postCreation.sendPost()
                                        print(result) // Handle successful result
                                    } catch {
                                        // Handle error
                                        postCreation.recoverPostFromFail()
                                        print("Failed to send post: \(error.localizedDescription)")
                                    }
                                }
                            }
                            
                        }) {
                            FancyText(text: "Publish Post")
                                .padding(10)
                        }
                    }
                    .padding(15)
                    .cornerRadius(20)
                    .overlay(
                        RoundedRectangle(cornerRadius: 20)
                            .stroke(Color.accentColor, lineWidth: 3)
                    )
                    VStack {
                        HStack {
                            Text("Options")
                            Spacer()
                        }
                        Divider()
                        HStack {
                            Button(action: {
                                postCreation.pollAdded.toggle()
                            }) {
                                HStack {
                                    Image(systemName: "checklist")
                                    Text("\(postCreation.pollAdded==true ? "Remove" : "Add") Poll")
                                }
                            }
                        }
                        Divider()
                        HStack {
                            Button(action: {
                                postCreation.mediaAdded.toggle()
                            }) {
                                HStack {
                                    Image(systemName: "photo.artframe")
                                    Text("\(postCreation.mediaAdded==true ? "Remove" : "Add") Media")
                                }
                            }
                        }
                        Divider()
                        HStack {
                            Button(action: {
                                postCreation.coposterAdded.toggle()
                            }) {
                                HStack {
                                    Image(systemName: "person.2")
                                    Text("\(postCreation.coposterAdded==true ? "Remove" : "Add") Coposters")
                                }
                            }
                        }
                    }
                    .padding(15)
                    .cornerRadius(20)
                    .overlay(
                        RoundedRectangle(cornerRadius: 20)
                            .stroke(Color.accentColor, lineWidth: 3)
                    )
                    
                    if (postCreation.possibleTags != nil) {
                        TagSuggestionsView(client: client, postCreation: postCreation)
                    }
                    
                    if (postCreation.mediaAdded) {
                        MediaUploadView(client: client, postCreation: postCreation)
                    }

                    if (postCreation.pollAdded) {
                        if (postCreation.content == "") {
                            HStack {
                                Text("Please add text to content before creating a poll.")
                                Spacer()
                            }
                            .padding(15)
                            .cornerRadius(20)
                            .overlay(
                                RoundedRectangle(cornerRadius: 20)
                                    .stroke(Color.accentColor, lineWidth: 3)
                            )
                        } else {
                            PollCreatorView(client: client, tempPollCreator: $postCreation.tempPollCreator)
                        }
                    }
                    
                    if (postCreation.coposterAdded) {
                        if (postCreation.content == "") {
                            HStack {
                                Text("Please add text to content before adding coposters.")
                                Spacer()
                            }
                            .padding(15)
                            .cornerRadius(20)
                            .overlay(
                                RoundedRectangle(cornerRadius: 20)
                                    .stroke(Color.accentColor, lineWidth: 3)
                            )
                        } else {
                            CoposterCreatorView(client: client, postCreation: postCreation)
//                            PollCreatorView(client: client, tempPollCreator: $postCreation.tempPollCreator)
                        }
                    }
                }
                .padding(10)
            }
        }
        .navigationTitle("Create Post")
    }
}

struct TagSuggestionsView: View {
    @ObservedObject var client: Client
    @ObservedObject var postCreation: PostCreation
    
    var body: some View {
        VStack {
            if let possibleTags = postCreation.possibleTags {
                if let hashtags = possibleTags.hashtags {
                    if (hashtags.count > 0) {
                        FancyText(text: "Suggested Hashtags:")

                        ForEach(hashtags) { hashtag in
                            TagSuggestionView(client: client, postCreation: postCreation, suggestion: hashtag.tag)
                        }
                    }
                }
                
                if let users = possibleTags.users {
                    if (users.count > 0) {
                        FancyText(text: "Suggested User Tags:")

                        ForEach(users) { user in
                            TagSuggestionView(client: client, postCreation: postCreation, suggestion: "@\( user.user.username ?? "")")
                        }
                    }
                }
            }
        }
    }
}

struct FancyText : View {
    @State var text: String
    
    var body: some View {
        VStack {
            HStack {
                Spacer()
                VStack {
                    Text(text)
                }
                Spacer()
            }
        }
        .padding(15)
        .cornerRadius(20)
        .overlay(
            RoundedRectangle(cornerRadius: 20)
                .stroke(Color.accentColor, lineWidth: 3)
        )

    }
}

struct TagSuggestionView: View {
    @ObservedObject var client: Client
    @ObservedObject var postCreation: PostCreation
    @State var suggestion: String
    @State var provUserId: String = ""
    @State var suggestType: Int = 0
    /*
     0=hastags/usertag
     1=coposter
     */
    
    var body: some View {
        VStack {
            FancyText(text: suggestion)
            .onTapGesture {
                if (suggestType == 0) {
                    postCreation.replaceTag(tag: suggestion)
                } else if (suggestType == 1) {
                    postCreation.addCoposter(username: suggestion, userID: provUserId);
                }
            }
        }
    }
}

struct AddedCopostersSuggestionView: View {
    @ObservedObject var client: Client
    @ObservedObject var postCreation: PostCreation

    var body: some View {
        VStack {
            ForEach(postCreation.coposters) { coposter in
//                FancyText(text: coposter.username)
                VStack {
                    HStack {
                        Spacer()
                        VStack {
                            Text(coposter.username)
                        }
                        Spacer()
                        Image(systemName: "person.badge.minus")
                        .onTapGesture {
                            postCreation.removeCoposter(coposterRemove: coposter)
                        }

                    }
                }
                .padding(15)
                .cornerRadius(20)
                .overlay(
                    RoundedRectangle(cornerRadius: 20)
                        .stroke(Color.accentColor, lineWidth: 3)
                )
            }
            if (postCreation.coposters.isEmpty) {
                VStack {
                    HStack {
                        Spacer()
                        VStack {
                            Text("No Coposters Added")
                        }
                        Spacer()
                    }
                }
                .padding(15)
                .cornerRadius(20)
                .overlay(
                    RoundedRectangle(cornerRadius: 20)
                        .stroke(Color.accentColor, lineWidth: 3)
                )
            }
        }
    }
}

struct CoposterCreatorView: View {
    @ObservedObject var client: Client
    @ObservedObject var postCreation: PostCreation
    
    var body: some View {
        VStack {
            VStack {
                ZStack {
//                    #if os(tvOS)
//                    TextField("Coposter", text: $coposterSearch)
//                        .onChange(of: postCreation.content) { newValue in
//                            postCreation.typePost(newValue: newValue)
//                        }
//
//                    #else

                    TextField("Coposter", text: $postCreation.coposterSearch)
                        .onChange(of: postCreation.coposterSearch) { newValue in
                            postCreation.typeCopost(text: newValue)
                        }
                    
//                    if postCreation.coposterSearch.isEmpty {
//                        VStack {
//                            HStack {
//                                Text("Coposter")
//                                    .foregroundStyle(.tertiary)
//                                    .padding(.top, 8)
//                                    .padding(.leading, 5)
//                                
//                                Spacer()
//                            }
//                            Spacer()
//                        }
//                    }
//                    #endif
                }
            }
            .padding(15)
            .cornerRadius(20)
            .overlay(
                RoundedRectangle(cornerRadius: 20)
                    .stroke(Color.accentColor, lineWidth: 3)
            )
            
        }
        
        CoposterSuggestionViewArea(client: client, postCreation: postCreation)
    }
}

struct CoposterSuggestionViewArea: View {
    @ObservedObject var client: Client
    @ObservedObject var postCreation: PostCreation

    var body: some View {
        VStack {
            AddedCopostersSuggestionView(client: client, postCreation: postCreation)
            
            if let possibleCoposters = postCreation.possibleCoposters {
                if let users = possibleCoposters.users {
                    if (users.count > 0) {
                        VStack {
                            FancyText(text: "Suggested Coposters:")
                            ForEach(users) { user in
                                TagSuggestionView(client: client, postCreation: postCreation, suggestion: "@\( user.user.username ?? "")", provUserId: user.user._id ?? "", suggestType: 1)
                            }
                        }
                        .padding(15)
                        .cornerRadius(20)
                        .overlay(
                            RoundedRectangle(cornerRadius: 20)
                                .stroke(Color.accentColor, lineWidth: 3)
                        )
                    }
                }
            }
        }
    }
}
