//
//  CreatePost.swift
//  social-apple
//
//  Created by Daniel Kravec on 2023-04-26.
//

import SwiftUI

struct CreatePost: View {
    @ObservedObject var client: ApiClient
    @ObservedObject var postCreation: PostCreation
    @Binding var feedData: AllPosts?

//    init (client: ApiClient) {
//        self.client = client
//        self.postCreation = PostCreation(client: client)
//    }
//    
    init (client: ApiClient, feedData: Binding<AllPosts?> = .constant(nil)) {
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
//                    VStack {
//                        TagSuggestionsView(client: client, postCreation: postCreation)
//                    }
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
                            /*
                            Spacer()
                            Button(action: {
                                postCreation.coposterAdded.toggle()
                            }) {
                                HStack {
                                    Image(systemName: "person.2")
                                    Text("\(postCreation.coposterAdded==true ? "Remove" : "Add") Coposters")
                                }
                            }
                             */
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
                            PollCreatorView(client: client, tempPollCreator: $postCreation.tempPollCreator)
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
    @ObservedObject var client: ApiClient
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
    @ObservedObject var client: ApiClient
    @ObservedObject var postCreation: PostCreation
    @State var suggestion: String
    
    var body: some View {
        VStack {
            FancyText(text: suggestion)
            .onTapGesture {
                postCreation.replaceTag(tag: suggestion)
            }
        }
    }
}

struct CoposterCreatorView: View {
    @ObservedObject var client: ApiClient
    @Binding var coposters: [String]
    
    var body: some View {
        VStack {
            Text("Adding")
        }
        .padding(15)
        .cornerRadius(20)
        .overlay(
            RoundedRectangle(cornerRadius: 20)
                .stroke(Color.accentColor, lineWidth: 3)
        )
    }
}
