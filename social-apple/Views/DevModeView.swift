//
//  DevModeView.swift
//  social-apple
//
//  Created by Daniel Kravec on 2023-04-28.
//

import SwiftUI

struct DevModeView: View {
    @Binding var userTokenData: UserTokenData?
    @Binding var devMode: DevModeData?
    @State private var fullScreen = false
    @State private var hideTokens = true

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
                    Text("userID: \(userTokenData?.userID ?? "not logged")")
                    Text("userToken: \(userTokenData?.userToken ?? "not logged")")
                    Text("accessToken: \(userTokenData?.accessToken ?? "not logged")")
                }

                Button(action: {
                    withAnimation {
                        hideTokens.toggle() // Toggle the censorship state
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
            
            Button("Toggle Full Screen") {
                self.fullScreen.toggle()
            }
        }
        .navigationTitle("Dev Mode")
        #if os(iOS)
        .navigationBarHidden(fullScreen)
        #endif

    }
}

