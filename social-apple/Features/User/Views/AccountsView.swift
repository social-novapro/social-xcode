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
    @State private var isSwitching: Bool = false
    @State private var switchStatus: String = ""

    var body: some View {
        VStack {
            VStack {
                LeftText(text: "User Login")
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

                Button(action: {
                    if isSwitching || username.isEmpty || password.isEmpty {
                        return
                    }

                    isSwitching = true
                    switchStatus = ""
                    client.hapticPress()

                    let loginData = UserLoginData(username: username, password: password)
                    client.api.auth.userLoginRequest(userLogin: loginData) { result in
                        DispatchQueue.main.async {
                            self.isSwitching = false
                            switch result {
                            case .success(let userLoginData):
                                client.provideTokens(userLoginResponse: userLoginData)
                                feedPosts.newClient(client: client)
                                feedPosts.refreshFeed()
                                switchStatus = "Switched to @\(userLoginData.publicData.username ?? "unknown")"
                                password = ""
                            case .failure(let error):
                                switchStatus = "Switch failed: \(error.localizedDescription)"
                            }
                        }
                    }
                }, label: {
                    Text(isSwitching ? "Switching..." : "Switch Account")
                })
                .padding(.top, 8)
                .disabled(isSwitching || username.isEmpty || password.isEmpty)

                if !switchStatus.isEmpty {
                    LeftText(text: switchStatus)
                        .padding(.top, 4)
                }
            }
            .padding(15)
            .cornerRadius(20)
            .overlay(
                RoundedRectangle(cornerRadius: 20)
                    .stroke(Color.accentColor, lineWidth: 3)
            )
            
            VStack {
                LeftText(text: "Switch Login")
                LeftText(text: "Switch to another account.")
                LeftText(text: "Current userID: \(client.userTokens.userID)")
            }
            .padding(15)
            .cornerRadius(20)
            .overlay(
                RoundedRectangle(cornerRadius: 20)
                    .stroke(Color.accentColor, lineWidth: 3)
            )
            
            VStack {
                LeftText(text: "Sign Out")
                LeftText(text: "Open your sign out options.")
            }
            .padding(15)
            .cornerRadius(20)
            .overlay(
                RoundedRectangle(cornerRadius: 20)
                    .stroke(Color.accentColor, lineWidth: 3)
            )
        }
        .padding(10)
        .navigationTitle("Connected Accounts")
    }
}

struct LeftText: View {
    @State var text:String
    
    var body: some View {
        HStack {
            Text(text)
            Spacer()
        }
    }
}
