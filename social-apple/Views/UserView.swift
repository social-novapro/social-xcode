//
//  UserView.swift
//  social-apple
//
//  Created by Daniel Kravec on 2023-04-19.
//

import SwiftUI

struct UserView: View {
    @Binding var userData: UserData?
    @Binding var userTokenData: UserTokenData?
    
    let api_requests = API_Rquests()

    var body: some View {
        Text(userData?.username ?? "Username")
        Text(userData?.displayName ?? "displayname")
        
        Button(action: {
//            let userLogin = UserLoginData(username: username, password: password)
            api_requests.getAllPosts(userTokens: userTokenData ?? UserTokenData(accessToken: "", userToken: "", userID: "")) { result in
                print(result)
                switch result {
                case .success(let userLoginData):
                    print(userLoginData)
                    print("Done")
//                    self.userLoginData = userLoginData
//                    self.shouldNavigate = true
//                    onDone(userLoginData)
                case .failure(let error):
                    print("Error: \(error.localizedDescription)")
                }
            }
        }) {
            Text("Log in")
        }
    }
}

//struct UserView_Previews: PreviewProvider {
//    let userData: UserData = {
//        _id: "1",
//        __v: "2",
//        username: "dan"
//    }
//
//    static var previews: some View {
//        UserView(userData: userData)
//    }
//}
