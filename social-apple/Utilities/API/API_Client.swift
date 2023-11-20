//
//  API_Client.swift
//  social-apple
//
//  Created by Daniel Kravec on 2023-11-19.
//

import Foundation

class ApiClient {
    var auth: AuthApi
    var posts: PostsApi
    var users: UsersApi
    
    private var userTokenManager = UserTokenHandler()
    private var userTokens: UserTokenData
    private var loggedIn:Bool
    
    init() {
        let tokensFound = userTokenManager.getUserTokens()
        if (tokensFound != nil) {
            self.userTokens = tokensFound!
            self.loggedIn = true
        } else {
            self.userTokens = UserTokenData(accessToken: "", userToken: "", userID: "")
            self.loggedIn = false
        }
        
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
