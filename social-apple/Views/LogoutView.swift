//
//  LogoutView.swift
//  social-apple
//
//  Created by Daniel Kravec on 2023-04-21.
//

import SwiftUI

struct LogoutView: View {
    @ObservedObject var client: ApiClient
    @State private var isLoggingOut = false

    var body: some View {
        VStack {
            if (isLoggingOut) {
                BeginPage(client: client)
            }
            else {
                Text("Are you sure you want to logout?")
                Button(action: {
                    print("deleting pressed")
                    client.userTokenManager.deleteUserToken()
                    client.loggedIn = false
                    isLoggingOut = true
                }) {
                    Text("Log out")
                }
            }
        }
    }
}
