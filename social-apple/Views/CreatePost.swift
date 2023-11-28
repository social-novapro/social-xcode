//
//  CreatePost.swift
//  social-apple
//
//  Created by Daniel Kravec on 2023-04-26.
//

import SwiftUI

struct CreatePost: View {
    @ObservedObject var client: ApiClient
    let api_requests = API_Rquests()    
    @State private var content: String = ""
    @State var newPost:PostData?
    
    var body: some View {
        VStack {
            Form {
                TextField("Content", text: $content)
                
                Button(action: {
                    print("button pressed")
                    print("createPost")
                    let postCreateContent = PostCreateContent(userID: client.userTokens.userID, content: self.content)
                    api_requests.createPost(postCreateContent: postCreateContent) { result in
                        print("api rquest login:")
                        switch result {
                        case .success(let newPost):
                            self.newPost = newPost
                            self.content = ""
                        case .failure(let error):
                            print("Error: \(error.localizedDescription)")
                        }
                    }
                }) {
                    Text("Publish Post")
                }
            }
        }
        .navigationTitle("Create")
    }
}
