//
//  LoginPage.swift
//  social-apple
//
//  Created by Daniel Kravec on 2023-04-19.
//

import SwiftUI

struct LoginPage: View {
    @State private var userLoginData: UserLoginResponse?
    var onDone: (UserData) -> Void

    let api_requests = API_Rquests()
    @State private var username: String = ""
    @State private var password: String = ""
    @State private var shouldNavigate: Bool = false;
    
//    var body: some View {
//        Form {
//           TextField("Username", text: $username)
//           SecureField("Password", text: $password)
//           Button(action: {
//               let userLogin = UserLoginData(username: username, password: password)
//
//               api_requests.userLoginRequest(userLogin: userLogin) { result in
//                   switch result {
//                   case .success(let data):
//                       self.data = data
//                       self.shouldNavigate = true
//                       break;
//                   case .failure(let error):
//                       print("Error: \(error.localizedDescription)")
//                       break;
//                   }
//               }
//           }) {
//               Text("Log in")
//           }
//       }
//       .navigationTitle("Log in")
//        NavigationLink(destination:  UserView(userData: data?.userData), isActive: $shouldNavigate) {
//            EmptyView()
//        }
//    }
    var body: some View {
//        if (userLoginData) {
//            Text("logged in")
//        }
        VStack {
            Form {
                TextField("Username", text: $username)
                SecureField("Password", text: $password)
                
                Button(action: {
                    let userLogin = UserLoginData(username: username, password: password)
                    api_requests.userLoginRequest(userLogin: userLogin) { result in
                        print(result)
                        switch result {
                        case .success(let userLoginData):
                            self.userLoginData = userLoginData
                            self.shouldNavigate = true
                            onDone(userLoginData.publicData)
                        case .failure(let error):
                            print("Error: \(error.localizedDescription)")
                        }
                    }
                }) {
                    Text("Log in")
                }
            }
               
            /*
             Text("Hello, world!")
             NavigationLink(destination: UserView(userData: userLoginData?.publicData)) {
                 Text("Go to another view")
             }
             */
//            NavigationLink(destination: Text("Success!"),isActive: $shouldNavigate) { //<- This will take it to rest
//               EmptyView()
//           }
       
            
        }
        .navigationTitle("Log in")
    }
}

//struct Login_Previews: PreviewProvider {
//    static var previews: some View {
//        LoginPage()
//    }
//}
