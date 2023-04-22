//
//  LoginPage.swift
//  social-apple
//
//  Created by Daniel Kravec on 2023-04-19.
//

import SwiftUI
import CoreData

struct LoginPage: View {
    @Environment(\.managedObjectContext) private var viewContext

    @State private var userLoginData: UserLoginResponse?
    var onDone: (UserLoginResponse) -> Void

    let api_requests = API_Rquests()
    
    @State private var username: String = ""
    @State private var password: String = ""
    @State private var shouldNavigate: Bool = false;
    
    var body: some View {
        VStack {
            Form {
                TextField("Username", text: $username)
                SecureField("Password", text: $password)
                
                Button(action: {
                    print("button pressed")
                    let userLogin = UserLoginData(username: username, password: password)
                    print("userlogin : \(userLogin)")
                    api_requests.userLoginRequest(userLogin: userLogin) { result in
                        print("api rquest login: \(result)")
                        switch result {
                        case .success(let userLoginData):
                            self.userLoginData = userLoginData
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
