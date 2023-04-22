//
//  LogoutView.swift
//  social-apple
//
//  Created by Daniel Kravec on 2023-04-21.
//

import SwiftUI

struct LogoutView: View {
    @State var userTokenManager = UserTokenHandler()
    @State private var isLoggingOut = false

    var body: some View {
        VStack {
            if (isLoggingOut) {
                BeginPage()
            }
            else {
                Text("Are you sure you want to logout?")
                Button(action: {
                    print("deleting pressed")
                    userTokenManager.deleteUserToken()
                    isLoggingOut = true
                }) {
                    Text("Log out")
                }
            }
        }
    }
}

struct LogoutView_Previews: PreviewProvider {
    static var previews: some View {
        LogoutView()
    }
}
