//
//  Begin.swift
//  social-apple
//
//  Created by Daniel Kravec on 2023-04-19.
//

import SwiftUI
import CoreData

struct BeginPage: View {
    @State var userTokenManager = UserTokenHandler()
    @State var userData: UserData?
    @State var userLoginResponse: UserLoginResponse?
    @State var userDataLoaded:Bool = false;
    @State var userTokens:UserTokenData?
    
    init() {
        userTokens = userTokenManager.getUserTokens()
        if (userTokens != nil) {
            userDataLoaded = true
        }
        print("userTokens first: \(String(describing: userTokens))")
    }


    var body: some View {
//        NavigationView {

            VStack {
                Text("Hello, world!")
               
                if (!userDataLoaded) {
                    LoginPage(onDone: { userLoginResponseIn in
                        
                        self.userLoginResponse = userLoginResponseIn;
                        self.userData = userLoginResponseIn.publicData;
                        userDataLoaded = true;
                        self.userTokens = UserTokenData(
                            accessToken: userLoginResponseIn.accessToken,
                            userToken: userLoginResponseIn.userToken,
                            userID: userLoginResponseIn.userID
                         )
                        userTokenManager.saveUserTokens(userTokenData: self.userTokens!)

                        print(userLoginResponseIn)
                    })
                } else {
                    UserView(
//                        userData: $userData,
                        userTokenData: $userTokens
                    )
                }
            }
            .onAppear {
                userDataLoaded = true
                userTokens = userTokenManager.getUserTokens()
                print("userTokens: \(String(describing: userTokens))")

                
           }
            .navigationTitle("Begin")
//        }
    }
}
