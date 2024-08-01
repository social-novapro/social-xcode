//
//  API_Client.swift
//  social-apple
//
//  Created by Daniel Kravec on 2023-11-19.
//

import Foundation
import CoreHaptics
import SwiftUI

class ApiClient: ObservableObject {
    var auth: AuthApi
    var notifications: NotificationsApi
    var posts: PostsApi
    var users: UsersApi
    var get: GetApi
    var developer: DeveloperApi
    var polls: PollsApi
    var anaytics: AnalyticsApi
    var search: SearchApi
    var admin: AdminApi

    var livechatWS: LiveChatWebSocket
    var apiHelper: API_Helper
//    @Published var feedPosts: FeedPosts

    @Published var loggedIn:Bool = false
    @Published var serverOffline: Bool = false
    
    @Published var devMode: DevModeData? = DevModeData(isEnabled: false)
    @Published var navigation: CurrentNavigationData? = CurrentNavigationData(selectedTab: 0, expanded: false, hidden: false)
    @Published var haptic: HapticModeData? = HapticModeData(isEnabled: true)

    var userTokenManager = UserTokenHandler()
    var devModeManager = DevModeHandler()
    var navigationManager = CurrentNavigationHandler()
    var hapticModeManager = HapticModeHandler()

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
        
        // other navigation
        self.devMode = self.devModeManager.getDevMode()
        self.navigation = self.navigationManager.getCurrentNavigation()
        self.haptic = self.hapticModeManager.getHapticMode()
        
        // routes
        self.auth = AuthApi(userTokensProv: userTokens)
        self.notifications = NotificationsApi(userTokensProv: userTokens)
        self.posts = PostsApi(userTokensProv: userTokens)
        self.users = UsersApi(userTokensProv: userTokens)
        self.get = GetApi(userTokensProv: userTokens)
        self.developer = DeveloperApi(userTokensProv: userTokens)
        self.polls = PollsApi(userTokensProv: userTokens)
        self.anaytics = AnalyticsApi(userTokensProv: userTokens)
        self.search = SearchApi(userTokensProv: userTokens)
        self.admin = AdminApi(userTokensProv: userTokens)

        self.apiHelper = API_Helper(userTokensProv: userTokens)
        self.livechatWS = LiveChatWebSocket(baseURL: self.apiHelper.baseAPIurl, userTokensProv: userTokens)

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
        
        self.checkServerStatus()
    }
    
    func hasTokens() {
        
    }
    
    func logout() {
        DispatchQueue.main.async {
            self.userTokenManager.deleteUserToken()
            self.loggedIn = false
        }
    }
    
    func provideTokens(userLoginResponse: UserLoginResponse) {
        /* sets up tokens */
        print("Providing tokens")
        DispatchQueue.main.async {
                self.userTokens = UserTokenData(
                accessToken: userLoginResponse.accessToken,
                userToken: userLoginResponse.userToken,
                userID: userLoginResponse.userID
            )
            
            self.userTokenManager.saveUserTokens(userTokenData: self.userTokens)
            
            self.auth = AuthApi(userTokensProv: self.userTokens)
            self.notifications = NotificationsApi(userTokensProv: self.userTokens)
            self.posts = PostsApi(userTokensProv: self.userTokens)
            self.users = UsersApi(userTokensProv: self.userTokens)
            self.get = GetApi(userTokensProv: self.userTokens)
            self.developer = DeveloperApi(userTokensProv: self.userTokens)
            self.polls = PollsApi(userTokensProv: self.userTokens)
            self.search = SearchApi(userTokensProv: self.userTokens)
            self.admin = AdminApi(userTokensProv: self.userTokens)

            self.apiHelper = API_Helper(userTokensProv: self.userTokens)
            self.livechatWS = LiveChatWebSocket(baseURL: self.apiHelper.baseAPIurl, userTokensProv: self.userTokens)
            
            self.loggedIn = true
        }
    }
    
    func hapticPress() {
        if (self.haptic?.isEnabled == true) {
            #if os(iOS)
            UIImpactFeedbackGenerator(style: .medium).impactOccurred()
            #endif
        }
    }
    
    func checkServerStatus() {
        var isServerOffline = false;
        guard let url = URL(string: apiHelper.baseAPIurl + "/serverStatus") else {
            print("Invalid URL")
            DispatchQueue.main.async {
                self.serverOffline = true
            }
            return;
        }
        
        var request = URLRequest(url: url)
        request.timeoutInterval = 10 // Set your desired timeout value in seconds

        let task = URLSession.shared.dataTask(with: request) { (data, response, error) in
            DispatchQueue.main.async {
                if let error = error {
                    print("Error: \(error)")
                    isServerOffline = true
                } else if let httpResponse = response as? HTTPURLResponse {
                    // Check if the server responded with a success status code
                    print(httpResponse.statusCode)
                    isServerOffline = !(200...299).contains(httpResponse.statusCode)
                }
                
                self.serverOffline = isServerOffline
                print("server is \(isServerOffline) : \(self.serverOffline)")

            }
        }

        task.resume()
    }
}
