//
//  LogoutView.swift
//  social-apple
//
//  Created by Daniel Kravec on 2023-04-21.
//

import SwiftUI

struct LogoutView: View {
    @ObservedObject var client: Client
    var feedPosts: FeedPosts? = nil
    @Environment(\.dismiss) private var dismiss
    @State private var logoutMessage = ""

    var body: some View {
        VStack(spacing: 16) {
            if (!client.loggedIn) {
                BeginPage(client: client)
            }
            else {
                Text("Choose how you want to log out.")
                
                Button(action: {
                    client.hapticPress()
                    client.logoutCurrentAccount {
                        refreshFeedForCurrentAccount()
                        logoutMessage = "Logged out of the current account."
                    }
                }) {
                    Text("Log out current account")
                        .padding(15)
                        .cornerRadius(20)
                        .overlay(
                            RoundedRectangle(cornerRadius: 20)
                                .stroke(Color.accentColor, lineWidth: 3)
                        )
                }
                
                Button(role: .destructive, action: {
                    client.hapticPress()
                    client.logoutAllAccounts {
                        feedPosts?.resetForAccountChange()
                        logoutMessage = "Logged out of all accounts."
                    }
                }) {
                    Text("Log out all accounts")
                        .padding(15)
                        .cornerRadius(20)
                        .overlay(
                            RoundedRectangle(cornerRadius: 20)
                                .stroke(Color.red, lineWidth: 3)
                        )
                }
                
                Button("Cancel") {
                    client.hapticPress()
                    dismiss()
                }
                
                if !logoutMessage.isEmpty {
                    Text(logoutMessage)
                        .font(.caption)
                }
                
                Spacer()
            }
            
        }
        .navigationTitle("Logout")

    }
    
    private func refreshFeedForCurrentAccount() {
        guard let feedPosts else {
            return
        }
        
        feedPosts.newClient(client: client)
        if client.loggedIn {
            feedPosts.refreshFeed(resetFeed: true)
        } else {
            feedPosts.resetForAccountChange()
        }
    }
}
