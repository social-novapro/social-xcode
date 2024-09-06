//
//  LoginPage.swift
//  social-apple
//
//  Created by Daniel Kravec on 2023-04-19.
//

import SwiftUI

struct LoginPage: View {
    @ObservedObject var client: Client
    
    @State private var username: String = ""
    @State private var password: String = ""
    
    var body: some View {
        VStack {
            ScrollView {
                VStack {
                    HStack {
                        Spacer()
                        Image(systemName: "person.circle")
                        TextField("Username", text: $username)
                            .padding(15)
                            .cornerRadius(20)
                            .overlay(
                                RoundedRectangle(cornerRadius: 20)
                                    .stroke(Color.accentColor, lineWidth: 3)
                            )
                        Spacer()
                    }
                }
                .padding(5)
                
                VStack {
                    HStack {
                        Spacer()
                        Image(systemName: "lock.circle")
                        
                        SecureField("Password", text: $password)
                            .padding(15)
                            .cornerRadius(20)
                            .overlay(
                                RoundedRectangle(cornerRadius: 20)
                                    .stroke(Color.accentColor, lineWidth: 3)
                            )
                        Spacer()
                    }
                }
                .padding(5)
                
                Button(action: {
                    client.hapticPress()
                    print("button pressed")
                    let userLogin = UserLoginData(username: username, password: password)
                    print("userlogin, LoginPage")
                    client.api.auth.userLoginRequest(userLogin: userLogin) { result in
                        print("api rquest login:")
                        switch result {
                        case .success(let userLoginData):
                            client.provideTokens(userLoginResponse: userLoginData)
                            client.changeBeginSetting(value: 0)
                        case .failure(let error):
                            print("Error: \(error.localizedDescription)")
                        }
                    }
                }) {
                    Text("Login")
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
        .navigationTitle("Login")
    }
}
