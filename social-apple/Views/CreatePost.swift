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

    init (client: ApiClient) {
        self.client = client
        self.postCreation = PostCreation(client: client)
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
                    VStack {
                        ZStack {
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
