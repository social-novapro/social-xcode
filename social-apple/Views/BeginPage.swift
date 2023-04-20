//
//  Begin.swift
//  social-apple
//
//  Created by Daniel Kravec on 2023-04-19.
//

import SwiftUI

struct BeginPage: View {
    @State var userData: UserData?
    @State var userLoginResponse: UserLoginResponse?
    @State var userDataLoaded:Bool = false;
    @State var userTokens: UserTokenData?
    
    var body: some View {
        NavigationView {

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
                        print(userLoginResponseIn)
                    })
                } else {
                    UserView(
                        userData: $userData,
                         userTokenData: $userTokens
                    )
                }
            }
            .navigationTitle("Begin")
        }
    }
}
