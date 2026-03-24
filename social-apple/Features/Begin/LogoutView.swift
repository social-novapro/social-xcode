//
//  LogoutView.swift
//  social-apple
//
//  Created by Daniel Kravec on 2023-04-21.
//

import SwiftUI

struct LogoutView: View {
    @ObservedObject var client: Client
    @State private var isLoggingOut = false

    var body: some View {
        VStack {
            if (isLoggingOut) {
                BeginPage(client: client)
            }
            else {
                Text("Are you sure you want to logout?")
                Button(action: {
                    client.hapticPress()
                    print("deleting pressed")
                    client.logout()
                    isLoggingOut = true
                }) {
                    Text("Log out")
                        .padding(15)
                        .cornerRadius(20)
                        .overlay(
                            RoundedRectangle(cornerRadius: 20)
                                .stroke(Color.accentColor, lineWidth: 3)
                        )
                }
                Spacer()
            }
            
        }
        .navigationTitle("Logout")

    }
}
