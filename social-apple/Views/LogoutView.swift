//
//  LogoutView.swift
//  social-apple
//
//  Created by Daniel Kravec on 2023-04-21.
//

import SwiftUI

struct LogoutView: View {
    @Binding var client: ApiClient
    @Binding var userTokenData: UserTokenData?
    @Binding var devMode: DevModeData?
    @Binding var userTokensLoaded: Bool
    @State var userTokenManager = UserTokenHandler()
    @State private var isLoggingOut = false


    var body: some View {
        VStack {
            if (isLoggingOut) {
                BeginPage(client: $client, userTokenData: $userTokenData, devMode: $devMode, userTokensLoaded: $userTokensLoaded)
            }
            else {
                Text("Are you sure you want to logout?")
                Button(action: {
                    print("deleting pressed")
                    userTokenManager.deleteUserToken()
                    isLoggingOut = true
                    userTokensLoaded=false
                }) {
                    Text("Log out")
                }
            }
        }
    }
}
