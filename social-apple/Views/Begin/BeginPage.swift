//
//  Begin.swift
//  social-apple
//
//  Created by Daniel Kravec on 2023-04-19.
//

import SwiftUI
import CoreData

struct BeginPage: View {
    @ObservedObject var client: ApiClient
    
    var body: some View {
        VStack {
            if (!client.loggedIn) {
                NavigationLink {
                    LoginPage(client: client, onDone: { userLoginResponseIn in
                        print("userresponsein")
                    })
                } label: {
                    Text("Login")
                }
                NavigationLink {
                    CreateUserPage(client: client, onDone: { userLoginResponseIn in
                        print("userresponsein")
                    })
                } label: {
                    Text("Sign Up")
                }
            } else {
                UserView(client: client)
                LogoutView(client: client)
                FeedPage(client: client)
    
            }
        }
        .navigationTitle("Welcome")
    }
}
