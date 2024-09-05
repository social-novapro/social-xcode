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
        NavigationStack {
            VStack {
                if (client.loggedIn == false) {
                    if (client.beginPageMode == 2) {
                        LoginPage(client: client)
                    } else if (client.beginPageMode == 3) {
                        CreateUserPage(client: client)
                    } else {
                        Text("Welcome to Interact.")
                        Text("You can login, or create a new account.")
                        
                        Button(action: {
                            client.hapticPress()
                            client.changeBeginSetting(value: 2)
                        }, label: {
                            Text("Login")
                                .padding(15)
                                .cornerRadius(20)
                                .overlay(
                                    RoundedRectangle(cornerRadius: 20)
                                        .stroke(Color.accentColor, lineWidth: 3)
                                )
                        })
                        
                        Button(action: {
                            client.hapticPress()
                            client.changeBeginSetting(value: 3)
                        }, label: {
                            Text("Sign up")
                                .padding(15)
                                .cornerRadius(20)
                                .overlay(
                                    RoundedRectangle(cornerRadius: 20)
                                        .stroke(Color.accentColor, lineWidth: 3)
                                )
                        })
                    }
                } else {
                    LogoutView(client: client)
                }
            }
            .onChange(of: client.beginPageMode) { _ in
                    print("changed client.beginPageMode \(client.beginPageMode)")
            }
            .onChange(of: client.loginUser) { _ in
                print("changed client.loginUser \(client.loggedIn)")
            }
            .onChange(of: client.createUser) { _ in
                print("changed client.createUser \(client.createUser)")
            }
            .onChange(of: client.loggedIn) { _ in
                print("changed client.loggedin")
            }
        }
        .navigationTitle("Welcome")
    }
}
