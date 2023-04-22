//
//  PostView.swift
//  social-apple
//
//  Created by Daniel Kravec on 2023-04-20.
//

import SwiftUI

struct PostPreView: View {
    @State var feedDataIn: AllPosts
    @State var feedData: AllPosts?
    @State var showData: Bool = false
    
    var body: some View {
        VStack {
            if showData {
                VStack {
                    Spacer()
                    HStack {
                        Spacer()
                        HStack {
                            Text(feedData!.userData?.displayName ?? "")
                            Text("@\(feedData!.userData?.username ?? "")")
                        }
                        .background(.blue)
                        
                        Spacer()
                        HStack {
                            Text(feedData!.postData.content!)
                            Spacer()
                        }
                        .background(.green)
                        .foregroundColor(.black)
                        
                        Spacer()
                    }
                    Spacer()
                }
            }
            else {
                EmptyView()
            }
        }
        .onAppear {
            feedData = self.feedDataIn
            if (feedData != nil) {
                showData = true;
                print ("showing")
            }

        }
        .background(.red)
        Spacer()
    }
}

struct PostContentArea: View {
    @Binding var postData: PostData?
    var body: some View {
        Text("hi")
    }
}

struct PostUserArea: View {
    @Binding var userData: UserData?

    var body: some View {
        Text("hi")
    }
}
