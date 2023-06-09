//
//  Begin.swift
//  social-apple
//
//  Created by Daniel Kravec on 2023-04-19.
//

import SwiftUI
import CoreData

struct BeginPage: View {
    @Binding var userTokenData: UserTokenData?
    @Binding var devMode: DevModeData?
    @Binding var userTokensLoaded: Bool

    @State var userTokenManager = UserTokenHandler()
    @State var userData: UserData?
    @State var userLoginResponse: UserLoginResponse?
    @State var userDataLoaded:Bool = false;
    @State var userTokens:UserTokenData?
    @State var pageLoading:Bool = true;

    var body: some View {
        VStack {
            if (pageLoading) {
                Text("Page loading! ")
            }
            if (!userDataLoaded && !pageLoading) {
                Text("Login" )

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
                    userTokensLoaded = true
                    print("userresponsein")
                })
            } else {
                UserView(
                    userTokenData: $userTokens//,
//                    userID: $userTokens.userID
                )
                FeedPage(userTokenData: $userTokens, devMode: $devMode)
    
            }
        }
        .onAppear {
            userTokens = userTokenManager.getUserTokens()
            if (userTokens == nil) {
                print ("tokens NOT loaded at begin")
                self.pageLoading = false
            }
            else {
                print ("tokens loaded at begin")
                userDataLoaded = true
                print("userTokens: .onAppear, else, BeginPage()")
                self.pageLoading = false
            }
       }
        .navigationTitle("Begin")
    }
}
