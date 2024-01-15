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
    @State var newPost:PostData?
    @State var sending: Bool = false
    @State var sent: Bool = false
    @State var failed: Bool = false
    
    var body: some View {
        VStack {
//            Spacer()
            if sending==true {
                HStack {
                    Text("Status: ")
                    if sent==true {
                        Text("Sent!")
                    } else {
                        if failed==true {
                            Text("Failed to send!")
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
                    let postCreateContent = PostCreateContent(userID: client.userTokens.userID, content: self.content)
                    
                    self.content = ""
                    self.sending = true
                    
                    client.posts.createPost(postCreateContent: postCreateContent) { result in
                        print("api request login:")
                        switch result {
                        case .success(let newPost):
                            self.newPost = newPost
                            self.sent = true
                            client.hapticPress()
                            
                        case .failure(let error):
                            self.failed = true
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
            Spacer()
        }
        .padding(10)
        .navigationTitle("Create")
//        .navigationBarTitleDisplayMode(.large)
    }
}
