//
//  LoginPage.swift
//  social-apple
//
//  Created by Daniel Kravec on 2023-04-19.
//

import SwiftUI

struct LoginPage: View {
    @ObservedObject var client: ApiClient
    @State private var userLoginData: UserLoginResponse?
    
    
    var onDone: (UserLoginResponse) -> Void
    let api_requests = API_Rquests()
    
    @State private var username: String = ""
    @State private var password: String = ""
    @State private var shouldNavigate: Bool = false;
    
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
                    client.auth.userLoginRequest(userLogin: userLogin) { result in
                        print("api rquest login:")
                        switch result {
                        case .success(let userLoginData):
                            self.userLoginData = userLoginData
                            client.provideTokens(userLoginResponse: userLoginData)
                            self.shouldNavigate = true
                            onDone(userLoginData)
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
