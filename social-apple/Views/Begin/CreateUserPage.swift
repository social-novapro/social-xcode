//
//  CreateUserPage.swift
//  social-apple
//
//  Created by Daniel Kravec on 2023-12-03.
//

import SwiftUI

struct CreateUserPage: View {
    @Environment(\.managedObjectContext) private var viewContext
    @ObservedObject var client: ApiClient
    @State private var userLoginData: UserLoginResponse?
    
    
    var onDone: (UserLoginResponse) -> Void
    
    @State private var email: String = ""
    @State private var username: String = ""
    @State private var password: String = ""
    @State private var displayName: String = ""
    @State private var description: String = ""
    @State private var pronouns: String = ""
    @State private var status: String = ""
    @State private var userAge: Date = Date()
    @State private var shouldNavigate: Bool = false;
    
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
                    DatePicker(selection: $userAge, in: ...Date.now, displayedComponents: .date) {
                        Text("Select a date (must be older than 13)")
                    }
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
                    client.auth.userCreateRequest(userCreate: userLogin) { result in
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
