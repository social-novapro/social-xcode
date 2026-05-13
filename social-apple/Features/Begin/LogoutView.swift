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
                InteractConnectedCardSection(tone: .destructive) {
                    InteractConnectedCardRow {
                        Text("Choose how you want to log out.")
                            .foregroundStyle(.secondary)
                    }
                    
                    InteractConnectedCardDivider()
                    
                    InteractActionRow(
                        title: "Log out current account",
                        subtitle: "Remove only the active account from this device.",
                        systemImage: "person.crop.circle.badge.minus"
                    ) {
                        client.hapticPress()
                        client.logoutCurrentAccount {
                            refreshFeedForCurrentAccount()
                            logoutMessage = "Logged out of the current account."
                        }
                    }
                    
                    InteractConnectedCardDivider(leadingInset: 56)
                    
                    InteractActionRow(
                        title: "Log out all accounts",
                        subtitle: "Remove every saved account and return to Begin.",
                        systemImage: "x.circle",
                        role: .destructive
                    ) {
                        client.hapticPress()
                        client.logoutAllAccounts {
                            feedPosts?.resetForAccountChange()
                            logoutMessage = "Logged out of all accounts."
                        }
                    }
                    
                    InteractConnectedCardDivider(leadingInset: 56)
                    
                    InteractActionRow(
                        title: "Cancel",
                        subtitle: nil,
                        systemImage: "arrow.uturn.backward"
                    ) {
                        client.hapticPress()
                        dismiss()
                    }
                    
                    if !logoutMessage.isEmpty {
                        InteractConnectedCardDivider()
                        InteractConnectedCardRow {
                            Text(logoutMessage)
                                .font(.caption)
                                .foregroundStyle(.secondary)
                        }
                    }
                }
                
                Spacer()
            }
            
        }
        .interactScreenPadding()
        .interactAppBackground()
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
