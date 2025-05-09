//
//  CreateUserPage.swift
//  social-apple
//
//  Created by Daniel Kravec on 2023-12-03.
//

import SwiftUI

struct CreateUserPage: View {
    @ObservedObject var client: Client
    
    @State private var email: String = ""
    @State private var username: String = ""
    @State private var password: String = ""
    @State private var displayName: String = ""
    @State private var description: String = ""
    @State private var pronouns: String = ""
    @State private var status: String = ""
    @State private var userAge: Date = Date()
    
    var body: some View {
        VStack {
            ScrollView {
                HStack {
                    Spacer()
                    Image(systemName: "envelope.circle")
                    TextField("Email (optional)", text: $email)
                        .padding(15)
                        .cornerRadius(20)
                        .overlay(
                            RoundedRectangle(cornerRadius: 20)
                                .stroke(Color.accentColor, lineWidth: 3)
                        )
                    Spacer()
                }
                .padding(5)
                
                HStack {
                    Spacer()
                    Image(systemName: "person.circle")
                    TextField("Username (required)", text: $username)
                        .padding(15)
                        .cornerRadius(20)
                        .overlay(
                            RoundedRectangle(cornerRadius: 20)
                                .stroke(Color.accentColor, lineWidth: 3)
                        )
                    Spacer()
                }
                .padding(5)
                
                HStack {
                    Spacer()
                    Image(systemName: "magnifyingglass.circle")
                    TextField("Display Name (required)", text: $displayName)
                        .padding(15)
                        .cornerRadius(20)
                        .overlay(
                            RoundedRectangle(cornerRadius: 20)
                                .stroke(Color.accentColor, lineWidth: 3)
                        )
                    Spacer()
                }
                .padding(5)
                
                HStack {
                    Spacer()
                    Image(systemName: "lock.circle")
                    SecureField("Password (required)", text: $password)
                        .padding(15)
                        .cornerRadius(20)
                        .overlay(
                            RoundedRectangle(cornerRadius: 20)
                                .stroke(Color.accentColor, lineWidth: 3)
                        )
                    Spacer()
                }
                .padding(5)
                
                HStack {
                    Spacer()
                    Image(systemName: "line.3.horizontal.decrease.circle")
                    TextField("Description (optional)", text: $description)
                        .padding(15)
                        .cornerRadius(20)
                        .overlay(
                            RoundedRectangle(cornerRadius: 20)
                                .stroke(Color.accentColor, lineWidth: 3)
                        )
                    Spacer()
                }
                .padding(5)
                
                HStack {
                    Spacer()
                    Image(systemName: "line.3.horizontal.decrease.circle")
#if !os(tvOS)
                    DatePicker(selection: $userAge, in: ...Date.now, displayedComponents: .date) {
                        Text("Select a date (must be older than 13)")
                    }
#endif
                    Spacer()

                }
                .padding(5)
                
                HStack {
                    Spacer()
                    Image(systemName: "pencil.tip.crop.circle")
                    TextField("Pronouns (optional)", text: $pronouns)
                        .padding(15)
                        .cornerRadius(20)
                        .overlay(
                            RoundedRectangle(cornerRadius: 20)
                                .stroke(Color.accentColor, lineWidth: 3)
                        )
                    Spacer()
                }
                .padding(5)
                
                HStack {
                    Spacer()
                    Image(systemName: "info.circle")
                    TextField("Activity Status (optional)", text: $status)
                        .padding(15)
                        .cornerRadius(20)
                        .overlay(
                            RoundedRectangle(cornerRadius: 20)
                                .stroke(Color.accentColor, lineWidth: 3)
                        )
                    Spacer()
                }
                .padding(5)
                
                Button(action: {
                    client.hapticPress()
                    print("button pressed")
                    let userLogin = UserCreateData(email: email, username: username, password: password, displayName: displayName, description: description, pronouns: pronouns, status: status, userAge: dateTimeFormatterInt64(date: userAge))
                    print("userlogin, LoginPage")
                    client.api.auth.userCreateRequest(userCreate: userLogin) { result in
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
                    Text("Sign up")
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
        .navigationTitle("Sign up")
    }
}
