//
//  CreatePost.swift
//  social-apple
//
//  Created by Daniel Kravec on 2023-04-26.
//

import SwiftUI

struct CreatePost: View {
    @ObservedObject var client: ApiClient
    @State private var content: String = ""
    @State var newPost: PostData?
    @State var newPoll: PollData?
    @State var sending: Bool = false
    @State var sent: Bool = false
    @State var errorMsg: String = "Unknown error."
    @State var failed: Bool = false
    @State var pollAdded: Bool = false
    @State var tempPollCreator: TempPollCreator = TempPollCreator()

    var body: some View {
        VStack {
            if sending==true {
                HStack {
                    Text("Status: ")
                    if sent==true {
                        Text("Sent!")
                    } else {
                        if failed==true {
                            Text("Failed: " + errorMsg)
                        } else {
                            Text("Sending")
                        }
                    }
                }
            }
            
            VStack {
                TextField("Content", text: $content)
                
                Button(action: {
                    client.hapticPress()
                    self.sending = true

                    var postCreateContent = PostCreateContent(userID: client.userTokens.userID, content: self.content)
                    if (self.content == "" ) {
                        self.failed = true
                        self.errorMsg = "Please enter post content."
                        return
                    }

                    self.content = ""
                    let dispatchGroup = DispatchGroup()

                    // create poll vist
                    var pollID:String? = nil
                    if (pollAdded) {
                        if (tempPollCreator.amountOptions>1) {
                            dispatchGroup.enter()

                            client.polls.create(pollInput: tempPollCreator) { result in
                                print("api request create poll:")

                                switch result {
                                case .success(let newPoll):
                                    print(newPoll)
                                    self.newPoll = newPoll.pollData
                                    pollID = self.newPoll?._id
                                    client.hapticPress()
                                    do {
                                        dispatchGroup.leave()
                                    }
                                    
                                case .failure(let error):
                                    self.failed = true
                                    self.errorMsg = "Poll failed to be created"
                                    print("Error: \(error.localizedDescription)")
                                    do {
                                        dispatchGroup.leave()
                                    }
                                }
                            }
                        }
                    }
                    
                    dispatchGroup.wait()
                    if (self.failed == true) {
                        return
                    }
                    if (pollID != nil) {
                        postCreateContent.linkedPollID = pollID
                    }
                    print(pollID ?? "")
                    print(newPoll ?? "")
                    
                    // send out post
                    client.posts.createPost(postCreateContent: postCreateContent) { result in
                        print("api request create post:")
                        switch result {
                        case .success(let newPost):
                            self.newPost = newPost
                            self.sent = true
                            client.hapticPress()
                        case .failure(let error):
                            self.failed = true
                            self.errorMsg = "Post failed to send"
                            print("Error: \(error.localizedDescription)")
                        }
                    }
                }) {
                    Text("Publish Post")
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
                        pollAdded.toggle()
                    }) {
                        HStack {
                            Image(systemName: "checklist")
                            Text("\(pollAdded==true ? "Remove" : "Add") Poll")
                        }
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
            if (pollAdded) {
                PollCreatorView(client: client, tempPollCreator: $tempPollCreator)
            }
            Spacer()
        }
        .padding(10)
        .navigationTitle("Create")
//        .navigationBarTitleDisplayMode(.large)
    }
}
