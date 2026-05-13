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
    @State private var isSwitchingAccount: Bool = false
    @State private var switchingUserID: String?
    @State private var accountStatus: String = ""
    @State private var accountStatusIsError: Bool = false
    @State private var savedAccounts: [UserTokenData] = []
    @State private var accountProfiles: [String: UserData] = [:]
    @State private var accountProfileErrors: [String: String] = [:]
    @State private var loadingProfileIDs: Set<String> = []
    @State private var profileRequestIDs: [String: UUID] = [:]
    
    private var accountOperationInProgress: Bool {
        isAddingAccount || isSwitchingAccount
    }
    
    private var currentAccount: UserTokenData? {
        if let savedAccount = savedAccounts.first(where: { $0.userID == client.userTokens.userID }) {
            return savedAccount
        }
        
        if !client.userTokens.userID.isEmpty {
            return client.userTokens
        }
        
        return nil
    }
    
    private var otherAccounts: [UserTokenData] {
        savedAccounts.filter { $0.userID != client.userTokens.userID }
    }
    
    var body: some View {
        ScrollView {
            if client.designPreference == .new {
                newAccountContent
                    .interactScreenPadding(design: client.designPreference)
            } else {
                originalAccountContent
                    .padding(10)
            }
        }
        .interactAppBackground(design: client.designPreference)
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
    
    private var originalAccountContent: some View {
        VStack(spacing: 12) {
            VStack {
                LeftText(text: "Current Account")
                
                if let currentAccount {
                    accountRow(currentAccount, showSwitchAction: false)
                } else {
                    LeftText(text: "No active account found.")
                        .padding(.top, 8)
                }
            }
            .padding(15)
            .cornerRadius(20)
            .overlay(
                RoundedRectangle(cornerRadius: 20)
                    .stroke(Color.accentColor, lineWidth: 3)
            )
            
            VStack {
                LeftText(text: "Other Accounts")
                LeftText(text: "Switch between accounts saved on this device.")
                
                if otherAccounts.isEmpty {
                    LeftText(text: "No other saved accounts.")
                        .padding(.top, 8)
                } else {
                    ForEach(otherAccounts, id: \.userID) { account in
                        accountRow(account, showSwitchAction: true)
                    }
                }
            }
            .padding(15)
            .cornerRadius(20)
            .overlay(
                RoundedRectangle(cornerRadius: 20)
                    .stroke(Color.accentColor, lineWidth: 3)
            )
            
            originalAddAccountView
            originalSignOutSection
        }
    }
    
    private var newAccountContent: some View {
        VStack(alignment: .leading, spacing: 12) {
            currentAccountSection
            otherAccountsSection
            addAccountView
            signOutSection
        }
    }
    
    private var currentAccountSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            InteractSectionHeader(title: "Current Account")
            
            InteractConnectedCardSection(design: client.designPreference, tone: .current) {
                InteractConnectedCardRow(design: client.designPreference) {
                    if let currentAccount {
                        accountRow(currentAccount, showSwitchAction: false)
                    } else {
                        Text("No active account found.")
                            .foregroundStyle(.secondary)
                            .frame(maxWidth: .infinity, alignment: .leading)
                    }
                }
            }
        }
    }
    
    private var otherAccountsSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            InteractSectionHeader(
                title: "Other Accounts",
                subtitle: "Switch between accounts saved on this device."
            )
            
            InteractConnectedCardSection(design: client.designPreference) {
                if otherAccounts.isEmpty {
                    InteractConnectedCardRow(design: client.designPreference) {
                        Text("No other saved accounts.")
                            .foregroundStyle(.secondary)
                    }
                } else {
                    ForEach(Array(otherAccounts.enumerated()), id: \.element.userID) { index, account in
                        InteractConnectedCardRow(design: client.designPreference) {
                            accountRow(account, showSwitchAction: true)
                        }
                        
                        if index < otherAccounts.count - 1 {
                            InteractConnectedCardDivider(design: client.designPreference, leadingInset: 56)
                        }
                    }
                }
            }
        }
    }
    
    private var addAccountView: some View {
        VStack(alignment: .leading, spacing: 8) {
            InteractSectionHeader(title: "Add Account", subtitle: "Sign into another account.")
            
            InteractConnectedCardSection(design: client.designPreference, tone: .selected) {
                InteractConnectedCardRow(design: client.designPreference) {
                    VStack(alignment: .leading, spacing: 8) {
                        HStack {
                            Image(systemName: "person.circle")
                            TextField("Username", text: $username)
                                .textInputAutocapitalization(.never)
                                .autocorrectionDisabled()
                        }
                        
                        HStack {
                            Image(systemName: "lock.circle")
                            SecureField("Password", text: $password)
                        }
                        
                        Button(action: addAccount) {
                            Text(isAddingAccount ? "Adding..." : "Add & Switch Account")
                        }
                        .buttonStyle(.borderedProminent)
                        .disabled(accountOperationInProgress || username.isEmpty || password.isEmpty)
                        
                        if !accountStatus.isEmpty {
                            if accountStatusIsError {
                                AuthInlineErrorView(message: accountStatus)
                            } else {
                                Text(accountStatus)
                                    .foregroundStyle(.secondary)
                                    .frame(maxWidth: .infinity, alignment: .leading)
                            }
                        }
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                }
            }
        }
    }
    
    private var originalAddAccountView: some View {
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
            .disabled(accountOperationInProgress || username.isEmpty || password.isEmpty)
            
            if !accountStatus.isEmpty {
                if accountStatusIsError {
                    AuthInlineErrorView(message: accountStatus)
                } else {
                    LeftText(text: accountStatus)
                        .foregroundStyle(.secondary)
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
    
    private var signOutSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            InteractSectionHeader(
                title: "Sign Out",
                subtitle: "Choose whether to log out of the current account or every saved account."
            )
            
            InteractConnectedCardSection(design: client.designPreference, tone: .destructive) {
                NavigationLink {
                    LogoutView(client: client, feedPosts: feedPosts)
                } label: {
                    InteractConnectedCardRow(design: client.designPreference) {
                        HStack {
                            Image(systemName: "x.circle")
                            Text("Open Logout Options")
                            Spacer()
                            Image(systemName: "chevron.right")
                                .font(.footnote.weight(.semibold))
                                .foregroundStyle(.tertiary)
                        }
                    }
                }
                .buttonStyle(.plain)
            }
        }
    }
    
    private var originalSignOutSection: some View {
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
    
    private func accountRow(_ account: UserTokenData, showSwitchAction: Bool) -> some View {
        let profile = accountProfiles[account.userID]
        let isCurrent = account.userID == client.userTokens.userID
        let isSwitchingThisAccount = isSwitchingAccount && switchingUserID == account.userID
        
        return HStack {
            VStack {
                HStack {
                    Text(profile?.displayName ?? "Saved Account")
                    Spacer()
                }
                HStack {
                    Text(accountSubtitle(for: account))
                        .font(.caption)
                        .foregroundStyle(.secondary)
                    Spacer()
                }
                if profile == nil && loadingProfileIDs.contains(account.userID) {
                    HStack {
                        Text("Loading profile...")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                        Spacer()
                    }
                } else if let profileError = accountProfileErrors[account.userID] {
                    HStack {
                        Text(profileError)
                            .font(.caption)
                            .foregroundStyle(.red)
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
            } else if showSwitchAction {
                Button(isSwitchingThisAccount ? "Switching..." : "Switch") {
                    switchToAccount(account)
                }
                .disabled(accountOperationInProgress)
            }
        }
        .padding(.vertical, 8)
    }
    
    private func addAccount() {
        if accountOperationInProgress || username.isEmpty || password.isEmpty {
            return
        }
        
        isAddingAccount = true
        accountStatus = ""
        accountStatusIsError = false
        client.hapticPress()
        
        let loginData = UserLoginData(
            username: username.trimmingCharacters(in: .whitespacesAndNewlines),
            password: password
        )
        
        client.api.auth.userLoginRequest(userLogin: loginData) { result in
            DispatchQueue.main.async {
                switch result {
                case .success(let userLoginData):
                    self.accountProfiles[userLoginData.userID] = userLoginData.publicData
                    self.accountProfileErrors[userLoginData.userID] = nil
                    client.provideTokens(userLoginResponse: userLoginData) {
                        isAddingAccount = false
                        feedPosts.newClient(client: client)
                        feedPosts.refreshFeed(resetFeed: true)
                        refreshAccounts()
                        accountStatusIsError = false
                        accountStatus = "Switched to @\(userLoginData.publicData.username ?? "unknown")"
                        username = ""
                        password = ""
                    }
                case .failure(let error):
                    isAddingAccount = false
                    accountStatusIsError = true
                    accountStatus = userFacingErrorMessage(
                        error,
                        fallback: "We couldn't add that account. Check the username and password, then try again."
                    )
                }
            }
        }
    }
    
    private func switchToAccount(_ account: UserTokenData) {
        guard account.userID != client.userTokens.userID else {
            return
        }
        guard !accountOperationInProgress else {
            return
        }
        
        client.hapticPress()
        isSwitchingAccount = true
        switchingUserID = account.userID
        accountStatus = ""
        accountStatusIsError = false
        
        let switched = client.switchAccount(userID: account.userID) {
            isSwitchingAccount = false
            switchingUserID = nil
            feedPosts.newClient(client: client)
            feedPosts.refreshFeed(resetFeed: true)
            refreshAccounts()
            
            if let username = accountProfiles[account.userID]?.username {
                accountStatus = "Switched to @\(username)"
            } else {
                accountStatus = "Switched accounts"
            }
            accountStatusIsError = false
        }
        
        if !switched {
            isSwitchingAccount = false
            switchingUserID = nil
            accountStatusIsError = true
            accountStatus = "That saved account is no longer available on this device."
            refreshAccounts()
        }
    }
    
    private func refreshAccounts() {
        let accounts = client.userTokenManager.getAllUserTokens()
        let accountIDs = Set(accounts.map(\.userID))
        
        savedAccounts = accounts
        accountProfiles = accountProfiles.filter { accountIDs.contains($0.key) }
        accountProfileErrors = accountProfileErrors.filter { accountIDs.contains($0.key) }
        loadingProfileIDs = loadingProfileIDs.intersection(accountIDs)
        
        for account in accounts {
            let userID = account.userID
            if accountProfiles[userID] != nil || loadingProfileIDs.contains(userID) {
                continue
            }
            
            let requestID = UUID()
            profileRequestIDs[userID] = requestID
            loadingProfileIDs.insert(userID)
            accountProfileErrors[userID] = nil
            
            client.api.users.getByID(userID: userID) { result in
                DispatchQueue.main.async {
                    guard profileRequestIDs[userID] == requestID else {
                        return
                    }
                    
                    profileRequestIDs[userID] = nil
                    loadingProfileIDs.remove(userID)
                    
                    guard savedAccounts.contains(where: { $0.userID == userID }) else {
                        accountProfiles[userID] = nil
                        accountProfileErrors[userID] = nil
                        return
                    }
                    
                    switch result {
                    case .success(let userData):
                        accountProfiles[userID] = userData
                        accountProfileErrors[userID] = nil
                    case .failure:
                        accountProfileErrors[userID] = "Couldn't load profile details."
                        if userID == client.userTokens.userID {
                            accountStatusIsError = true
                            accountStatus = "Switched accounts, but couldn't refresh profile details."
                        }
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
