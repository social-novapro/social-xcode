//
//  AccountsView.swift
//  social-apple
//
//  Created by Daniel Kravec on 2024-01-17.
//

import SwiftUI

struct AccountsView: View {
    @ObservedObject var client: Client
    @ObservedObject var feedPosts: FeedPosts
    @State private var username: String = ""
    @State private var password: String = ""
    @State private var isAddingAccount: Bool = false
    @State private var accountStatus: String = ""
    @State private var savedAccounts: [UserTokenData] = []
    @State private var accountProfiles: [String: UserData] = [:]
    @State private var loadingProfileIDs: Set<String> = []

    var body: some View {
        ScrollView {
            VStack(spacing: 12) {
                VStack {
                    LeftText(text: "Saved Accounts")
                    LeftText(text: "Switch between accounts saved on this device.")
                    
                    if savedAccounts.isEmpty {
                        LeftText(text: "No saved accounts found.")
                            .padding(.top, 8)
                    } else {
                        ForEach(savedAccounts, id: \.userID) { account in
                            accountRow(account)
                        }
                    }
                }
                .padding(15)
                .cornerRadius(20)
                .overlay(
                    RoundedRectangle(cornerRadius: 20)
                        .stroke(Color.accentColor, lineWidth: 3)
                )
                
                addAccountView
                
                VStack {
                    LeftText(text: "Sign Out")
                    LeftText(text: "Choose whether to log out of the current account or every saved account.")
                    
                    NavigationLink {
                        LogoutView(client: client, feedPosts: feedPosts)
                    } label: {
                        HStack {
                            Image(systemName: "x.circle")
                            Text("Open Logout Options")
                            Spacer()
                        }
                        .padding(.top, 8)
                    }
                }
                .padding(15)
                .cornerRadius(20)
                .overlay(
                    RoundedRectangle(cornerRadius: 20)
                        .stroke(Color.accentColor, lineWidth: 3)
                )
            }
            .padding(10)
        }
        .navigationTitle("Connected Accounts")
        .onAppear {
            refreshAccounts()
        }
        .onChange(of: client.userTokens.userID) { _ in
            refreshAccounts()
        }
        .onChange(of: client.savedUserTokens.count) { _ in
            refreshAccounts()
        }
    }
    
    private var addAccountView: some View {
        VStack {
            LeftText(text: "Add Account")
            LeftText(text: "Sign into another account.")
            HStack {
                Image(systemName: "person.circle")
                TextField("Username", text: $username)
                    .textInputAutocapitalization(.never)
                    .autocorrectionDisabled()
            }
            .padding(.top, 8)
            
            HStack {
                Image(systemName: "lock.circle")
                SecureField("Password", text: $password)
            }
            .padding(.top, 4)
            
            Button(action: addAccount) {
                Text(isAddingAccount ? "Adding..." : "Add & Switch Account")
            }
            .padding(.top, 8)
            .disabled(isAddingAccount || username.isEmpty || password.isEmpty)
            
            if !accountStatus.isEmpty {
                LeftText(text: accountStatus)
                    .padding(.top, 4)
            }
        }
        .padding(15)
        .cornerRadius(20)
        .overlay(
            RoundedRectangle(cornerRadius: 20)
                .stroke(Color.accentColor, lineWidth: 3)
        )
    }
    
    private func accountRow(_ account: UserTokenData) -> some View {
        let profile = accountProfiles[account.userID]
        let isCurrent = account.userID == client.userTokens.userID
        
        return HStack {
            VStack {
                HStack {
                    Text(profile?.displayName ?? "Saved Account")
                    Spacer()
                }
                HStack {
                    Text(accountSubtitle(for: account))
                        .font(.caption)
                    Spacer()
                }
                if profile == nil && loadingProfileIDs.contains(account.userID) {
                    HStack {
                        Text("Loading profile...")
                            .font(.caption)
                        Spacer()
                    }
                }
            }
            
            Spacer()
            
            if isCurrent {
                Text("Current")
                    .font(.caption)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background(Color.accentColor.opacity(0.15))
                    .cornerRadius(20)
            } else {
                Button("Switch") {
                    switchToAccount(account)
                }
            }
        }
        .padding(.vertical, 8)
    }
    
    private func addAccount() {
        if isAddingAccount || username.isEmpty || password.isEmpty {
            return
        }
        
        isAddingAccount = true
        accountStatus = ""
        client.hapticPress()
        
        let loginData = UserLoginData(username: username, password: password)
        client.api.auth.userLoginRequest(userLogin: loginData) { result in
            DispatchQueue.main.async {
                self.isAddingAccount = false
                switch result {
                case .success(let userLoginData):
                    self.accountProfiles[userLoginData.userID] = userLoginData.publicData
                    client.provideTokens(userLoginResponse: userLoginData) {
                        feedPosts.newClient(client: client)
                        feedPosts.refreshFeed(resetFeed: true)
                        refreshAccounts()
                        accountStatus = "Switched to @\(userLoginData.publicData.username ?? "unknown")"
                        username = ""
                        password = ""
                    }
                case .failure(let error):
                    accountStatus = "Login failed: \(error.localizedDescription)"
                }
            }
        }
    }
    
    private func switchToAccount(_ account: UserTokenData) {
        guard account.userID != client.userTokens.userID else {
            return
        }
        
        client.hapticPress()
        accountStatus = ""
        client.switchAccount(userID: account.userID) {
            feedPosts.newClient(client: client)
            feedPosts.refreshFeed(resetFeed: true)
            refreshAccounts()
            
            if let username = accountProfiles[account.userID]?.username {
                accountStatus = "Switched to @\(username)"
            } else {
                accountStatus = "Switched accounts"
            }
        }
    }
    
    private func refreshAccounts() {
        savedAccounts = client.userTokenManager.getAllUserTokens()
        
        for account in savedAccounts {
            let userID = account.userID
            if accountProfiles[userID] != nil || loadingProfileIDs.contains(userID) {
                continue
            }
            
            loadingProfileIDs.insert(userID)
            client.api.users.getByID(userID: userID) { result in
                DispatchQueue.main.async {
                    loadingProfileIDs.remove(userID)
                    switch result {
                    case .success(let userData):
                        accountProfiles[userID] = userData
                    case .failure(let error):
                        print("Error loading account profile: \(error.localizedDescription)")
                    }
                }
            }
        }
    }
    
    private func accountSubtitle(for account: UserTokenData) -> String {
        if let username = accountProfiles[account.userID]?.username {
            return "@\(username)"
        }
        
        return account.userID
    }
}

struct LeftText: View {
    let text:String
    
    var body: some View {
        HStack {
            Text(text)
            Spacer()
        }
    }
}
