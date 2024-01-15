//
//  DevModeView.swift
//  social-apple
//
//  Created by Daniel Kravec on 2023-04-28.
//

import SwiftUI

struct DevModeView: View {
    @ObservedObject var client: ApiClient

    @State var userTokenManager = UserTokenHandler()
    @State var devModeManager = DevModeHandler()
    @State var currentNavigationManager = CurrentNavigationHandler()
    
    @State private var fullScreen = false
    @State private var hideTokens = true
    @State private var verifyDelete = false

    var body: some View {
        VStack {
            HStack {
                Text("Developer Mode is enabled, to disable go to About page")
            }
            .padding(20)
            VStack {
                Text("Your Tokens:")
                if hideTokens {
                    Text("Tokens are censored. Click the button to reveal.")
                } else {
                    Text("userID: \(client.userTokens.userID)")
                    Text("userToken: \(client.userTokens.userToken)")
                    Text("accessToken: \(client.userTokens.accessToken)")
                }

                Button(action: {
                    client.hapticPress()
                    withAnimation {
                        hideTokens.toggle() 
                    }
                }) {
                    if hideTokens {
                        Text("Reveal Tokens")
                    }
                    else {
                        Text("Hide Tokens")
                    }
                }
               
            }
            Spacer()
            Text("You may delete all local data with this button, there will be a confirmation")
           
            if verifyDelete == false {
                Button("Delete All Data") {
                    client.hapticPress()
                    self.verifyDelete.toggle()
                }
            } else {

                Text("Delete Data, you will need to resign into the application")
                Text("You will need to relaunch the app to resign in")
                Button("Are you sure?") {
                    HapticPress.shared.play()
                    client.devModeManager.deleteDevMode()
                    client.navigationManager.deleteCurrentNavigation()
                    client.devMode = client.devModeManager.getDevMode()
                    client.logout()
                }
                .padding(15)
                .background(Color.red)
            }
            Spacer()
            Button("Toggle Full Screen") {
                client.hapticPress()
                self.fullScreen.toggle()
            }
            Spacer()
            
        }
        .navigationTitle("Dev Mode")
        #if os(iOS)
        .navigationBarHidden(fullScreen)
        #endif
    }
}

