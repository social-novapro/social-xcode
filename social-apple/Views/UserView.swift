//
//  UserView.swift
//  social-apple
//
//  Created by Daniel Kravec on 2023-04-19.
//

import SwiftUI

struct UserView: View {
    @Binding var userTokenData: UserTokenData?
//^ turn to state when using init
    //    @Binding var userID: String?
    let api_requests = API_Rquests()

    @State var userData: UserData?
    @State var isLoading:Bool = true


  /*
   init(userTokenData: UserTokenData){
       self.userTokenData = userTokenData
       self.userData = nil
       
       api_requests.getUserData(userID: userTokenData.userID) { [weak self] result in
           guard let self = self else { return }

           print(result)
           switch result {
           case .success(let userData):
               print(userData)
               print("Done")
               self.userData = userData
               self.isLoading = false
           case .failure(let error):
               print("Error: \(error.localizedDescription)")
           }
       }
   }
   */
    
    var body: some View {
        VStack {
            if !isLoading {
                VStack {
                    Text("Your user")
                    Text(userData?.username ?? "Username")
                    Text(userData?.displayName ?? "displayname")
                }
                .background(.indigo)
            } else {
                Text("Loading")
            }
            
            /*
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
             */
        }
        .onAppear {
            api_requests.getUserData(userID: userTokenData?.userID) { result in
                print(result)
                switch result {
                case .success(let userData):
                    print(userData)
                    print("Done")
                    self.userData = userData
                    self.isLoading = false
                case .failure(let error):
                    print("Error: \(error.localizedDescription)")
                }
            }
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
