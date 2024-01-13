//
//  API_Client.swift
//  social-apple
//
//  Created by Daniel Kravec on 2023-11-19.
//

import Foundation

class ApiClient: ObservableObject {
    var auth: AuthApi
    var notifications: NotificationsApi
    var posts: PostsApi
    var users: UsersApi
    var get: GetApi

    @Published var loggedIn:Bool = false
    @Published var devMode: DevModeData? = DevModeData(isEnabled: false)
    @Published var navigation: CurrentNavigationData? = CurrentNavigationData(selectedTab: 0)
    
    var userTokenManager = UserTokenHandler()
    var devModeManager = DevModeHandler()
    var navigationManager = CurrentNavigationHandler()

    var userTokens: UserTokenData
    
    var errorShow:Bool = false
    var errorFound:ErrorData?
    var userData: UserData?
    
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
        self.navigation = self.navigationManager.getCurrentNavigation()
        self.auth = AuthApi(userTokensProv: userTokens)
        self.notifications = NotificationsApi(userTokensProv: userTokens)
        self.posts = PostsApi(userTokensProv: userTokens)
        self.users = UsersApi(userTokensProv: userTokens)
        self.get = GetApi(userTokensProv: userTokens)
        
        if (self.loggedIn == true) {
            self.users.getByID(userID: userTokens.userID) { result in
                print("Done")
                switch result {
                    case .success(let results):
                        self.userData = results;
                    case .failure(let error):
                        print("Error: \(error.localizedDescription)")
                }
            }
        }
    }
    
    func hasTokens() {
        
    }
    
    func logout() {
        self.userTokenManager.deleteUserToken()
        self.loggedIn = false
        DispatchQueue.main.async {
            self.loggedIn = false
        }
    }
    
    func provideTokens(userLoginResponse: UserLoginResponse) {
        /* sets up tokens */
        print("Providing tokens")
        self.userTokens = UserTokenData(
            accessToken: userLoginResponse.accessToken,
            userToken: userLoginResponse.userToken,
            userID: userLoginResponse.userID
        )
        
        self.userTokenManager.saveUserTokens(userTokenData: userTokens)
        self.auth = AuthApi(userTokensProv: self.userTokens)
        self.posts = PostsApi(userTokensProv: self.userTokens)
        self.users = UsersApi(userTokensProv: self.userTokens)
        DispatchQueue.main.async {
            self.loggedIn = true
        }
    }
}
