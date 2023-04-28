//
//  PostView.swift
//  social-apple
//
//  Created by Daniel Kravec on 2023-04-20.
//

import SwiftUI

struct PostPreView: View {
    @Binding var userTokenData: UserTokenData?
    @Binding var devMode: DevModeData?
    @State var feedDataIn: AllPosts
    @State var feedData: AllPosts?
    @State var showData: Bool = false
    @State private var isActive:Bool = false
    
    var body: some View {
        VStack {
            if showData {
                VStack {
                    Spacer()
                    HStack {
                        Spacer()
                            Button(action: {
                                isActive=true
                                print ("showing usuer?")
                                // go to user
                            }) {
                                HStack {
                                    Text(feedData!.userData?.displayName ?? "")
                                    Text("@\(feedData!.userData?.username ?? "")")
                                    if (feedData!.userData?.verified != nil) {
                                        Image(systemName: "checkmark.seal.fill")
                                    }
                                }
                            }
                            .buttonStyle(PlainButtonStyle())
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
                    
                    HStack {
                        Spacer()
                        HStack {
                            Button(action: {
                                print("like button")
                            }) {
                                HStack {
                                    if (feedData?.postData.totalLikes != nil && feedData?.postData.totalLikes != 0) {
                                        if (feedData?.postData.totalLikes == 1) {
                                            Text ("\(self.feedData?.postData.totalLikes ?? 0) Like")
                                        }
                                        else {
                                            Text ("\(self.feedData?.postData.totalLikes ?? 0) Likes")
                                        }
                                    }
                                    else {
                                        Text("Like")
                                           
                                    }
                                }
                                .padding(5)
                                .foregroundColor(.white)
                                .background(Color.blue)
                                .cornerRadius(10)
                            }
                            .buttonStyle(PlainButtonStyle())

                            Button(action: {
                                print("quote button")
                            }) {
                                HStack {
                                    if (feedData?.postData.totalQuotes != nil && feedData?.postData.totalQuotes != 0) {
                                        if (feedData?.postData.totalLikes == 1) {
                                            Text ("\(self.feedData?.postData.totalQuotes ?? 0) Quote")
                                        }
                                        else {
                                            Text ("\(self.feedData?.postData.totalQuotes ?? 0) Quotes")
                                        }
                                    }
                                    else {
                                        Text("Quote")
                                    }
                                }
                                .padding(5)
                                .foregroundColor(.white)
                                .background(Color.blue)
                                .cornerRadius(10)
                            }
                            .buttonStyle(PlainButtonStyle())

                            Button(action: {
                                print("reply button")
                            }) {
                                HStack {
                                    if (feedData?.postData.totalReplies != nil && feedData?.postData.totalReplies != 0) {
                                        if (feedData?.postData.totalLikes == 1) {
                                            Text ("\(self.feedData?.postData.totalReplies ?? 0) Reply")
                                        }
                                        else {
                                            Text ("\(self.feedData?.postData.totalReplies ?? 0) Replies")
                                        }
                                    }
                                    else {
                                        Text("Reply")
                                    }
                                }
                                .padding(5)
                                .foregroundColor(.white)
                                .background(Color.blue)
                                .cornerRadius(10)
                            }
                            .buttonStyle(PlainButtonStyle())

                            Spacer()
                        }
                        Spacer()
                    }
                    Spacer()
                    
                    if (devMode?.isEnabled == true) {
                        VStack {
                            Text("PostID: \(feedData?.postData._id ?? "xx")")
                            Text("UserID: \(feedData?.userData?._id ?? "xx")")
                        }
                        Spacer()
                    }
                    
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
