//
//  API_Client.swift
//  social-apple
//
//  Created by Daniel Kravec on 2023-11-19.
//

import Foundation

class ApiClient: ObservableObject {
    var auth: AuthApi
    var posts: PostsApi
    var users: UsersApi
    
    @Published var loggedIn:Bool = false
    @Published var devMode: DevModeData? = DevModeData(isEnabled: false)
    @Published var navigation: CurrentNavigationData? = CurrentNavigationData(selectedTab: 0)
    
    var userTokenManager = UserTokenHandler()
    var devModeManager = DevModeHandler()
    var navigationManager = CurrentNavigationHandler()

    var userTokens: UserTokenData
    
    init() {
        let tokensFound = userTokenManager.getUserTokens()
        if (tokensFound != nil) {
            self.userTokens = tokensFound!
            self.loggedIn = true
        } else {
            self.userTokens = UserTokenData(accessToken: "", userToken: "", userID: "")
            self.loggedIn = false
        }
        
        self.devMode = self.devModeManager.getDevMode()
        self.auth = AuthApi(userTokensProv: userTokens)
        self.posts = PostsApi(userTokensProv: userTokens)
        self.users = UsersApi(userTokensProv: userTokens)
    }
    
    func hasTokens() {
        
    }
    
    func provideTokens(userLoginResponse: UserLoginResponse) {
        /* sets up tokens */
        print("Providing tokens")
        self.userTokens = UserTokenData(
            accessToken: userLoginResponse.accessToken,
            userToken: userLoginResponse.userToken,
            userID: userLoginResponse.userID
        )
        
        userTokenManager.saveUserTokens(userTokenData: userTokens)
        self.auth = AuthApi(userTokensProv: self.userTokens)
        self.posts = PostsApi(userTokensProv: self.userTokens)
        self.users = UsersApi(userTokensProv: self.userTokens)
        self.loggedIn = true
    }
}
