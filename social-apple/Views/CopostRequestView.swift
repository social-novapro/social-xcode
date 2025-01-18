//
//  CopostRequestView.swift
//  social-apple
//
//  Created by Daniel Kravec on 2025-01-18.
//

import SwiftUI

struct CopostRequestsHyper: View {
    @ObservedObject var client: Client
    @ObservedObject var feedPosts: FeedPosts
    @State var showCopostRequests: Bool = false
    
    var body: some View {
        VStack {
            VStack {
                HStack {
                    Text("Copost Requests: \(self.feedPosts.copostRequests.count)")
                    Spacer()
                    Image(systemName: "arrow.right.circle")
                    
                    //                    Button(action: {
                    //                        DispatchQueue.main.async {
                    //                            Task {
                    //                                self.feedPosts.copostsFound = false;
                    //                            }
                    //                        }
                    //                    }) {
                    //                        HStack {
                    //                            Text("Hide")
                    //                            Image(systemName: "x.circle")
                    //                        }
                    //                    }
                }
            }
            .padding(15)
            .cornerRadius(20)
            .overlay(
                RoundedRectangle(cornerRadius: 20)
                    .stroke(Color.accentColor, lineWidth: 3)
            )
        }
        .onTapGesture {
            client.hapticPress()
            self.showCopostRequests.toggle()
        }
        .sheet(isPresented: $showCopostRequests) {
            NavigationView {
                CopostRequestView(client: client, feedPosts: feedPosts, showCopostRequests: $showCopostRequests)
            }
        }
    }
}

struct CopostRequestView: View {
    @ObservedObject var client: Client
    @ObservedObject var feedPosts: FeedPosts
    @Binding var showCopostRequests: Bool

    var body: some View {
        ScrollView {
            VStack {
                HStack {
                    Text("Copost Requests: \(self.feedPosts.copostRequests.count)")
                    Spacer()
                    
//                    Button(action: {
//                        DispatchQueue.main.async {
//                            Task {
//                                self.feedPosts.copostsFound = false;
//                            }
//                        }
//                    }) {
//                        HStack {
//                            Text("Hide")
//                            Image(systemName: "x.circle")
//                        }
//                    }
                }
                .padding(15)
                .cornerRadius(20)
                .overlay(
                    RoundedRectangle(cornerRadius: 20)
                        .stroke(Color.accentColor, lineWidth: 3)
                )
            }
            .padding(10)

            
            VStack {
                ForEach(self.feedPosts.copostRequests.indices, id: \.self) { index in
                    // preview
                    
                    // request from: user.username
                    // post: post.content
                    // accept, decline
                    if (self.feedPosts.copostRequests[index].dismissed == false) {
                        VStack {
                            HStack {
                                Text("Request from: \(self.feedPosts.copostRequests[index].user?.username ?? "Unknown User")")
                                Spacer()
                            }
                            HStack {
                                Text("Post: \(self.feedPosts.copostRequests[index].post.content ?? "Unknown Post")")
                                Spacer()
                            }
                            
                            HStack {
                                Button(action: {
                                    DispatchQueue.main.async {
                                        client.hapticPress()
                                        
                                        Task {
                                            _ = try await client.api.posts.copostsApprove(requestID: self.feedPosts.copostRequests[index].request._id)
                                            self.feedPosts.copostRequests[index].dismissed = true;
                                        }
                                    }
                                }) {
                                    HStack {
                                        Text("Accept")
                                        Image(systemName: "checkmark.circle")
                                    }
                                }
                                Spacer()
                                Button(action: {
                                    DispatchQueue.main.async {
                                        client.hapticPress()

                                        Task {
                                            _ = try await client.api.posts.copostsDecline(requestID: self.feedPosts.copostRequests[index].request._id)
                                            self.feedPosts.copostRequests[index].dismissed = true;
                                        }
                                    }
                                }) {
                                    HStack {
                                        Text("Deny")
                                        Image(systemName: "x.circle")
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
                    }
                }
            }
            .padding(10)
        }
        .navigationTitle("Copost Requests")
    }
}
