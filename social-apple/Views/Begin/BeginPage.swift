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
    @State var gotoother = false
    @State var login = false;
    @State var signup = false;
    
    var body: some View {
        VStack {
            if (!client.loggedIn) {
                Text("Welcome to Interact.")
                Text("You can login, or create a new account.")

                Button(action: {
                    self.login = true
                }, label: {
                    Text("Login")
                        .padding(15)
                        .cornerRadius(20)
                        .overlay(
                            RoundedRectangle(cornerRadius: 20)
                                .stroke(Color.accentColor, lineWidth: 3)
                        )
                })
                .navigationDestination(isPresented: $login) {
                    LoginPage(client: client, onDone: { userLoginResponseIn in
                        print("userresponsein")
                    })
                }
                
                Button(action: {
                    self.signup = true
                }, label: {
                    Text("Sign up")
                        .padding(15)
                        .cornerRadius(20)
                        .overlay(
                            RoundedRectangle(cornerRadius: 20)
                                .stroke(Color.accentColor, lineWidth: 3)
                        )
                })
                .navigationDestination(isPresented: $signup) {
                    CreateUserPage(client: client, onDone: { userLoginResponseIn in
                        print("userresponsein")
                    })
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
