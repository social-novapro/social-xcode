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
    let api_requests = API_Rquests()
    
    @State private var email: String = ""
    @State private var username: String = ""
    @State private var password: String = ""
    @State private var displayName: String = ""
    @State private var description: String = ""
    @State private var pronouns: String = ""
    @State private var status: String = ""
    @State private var shouldNavigate: Bool = false;
    
    var body: some View {
        VStack {
            Form {
                TextField("Email (optional)", text: $email)
                TextField("Username", text: $username)
                TextField("Display Name", text: $displayName)
                SecureField("Password", text: $password)
                TextField("Description", text: $description)
                TextField("Pronouns", text: $pronouns)
                TextField("Status", text: $status)
                
                Button(action: {
                    print("button pressed")
                    let userLogin = UserCreateData(email: email, username: username, password: password, displayName: displayName, description: description, pronouns: pronouns, status: status)
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
                    Text("Log in")
                }
            }
        }
        .navigationTitle("Log in")
    }
}
