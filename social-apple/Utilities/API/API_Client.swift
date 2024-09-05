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
    
//    var feedPosts: FeedPosts
    // will only initilize when first used
//    lazy var feedPosts: FeedPosts = {
//        return FeedPosts(client: self)
//    }()
//    @Published var feedPosts: FeedPosts

    @Published var loggedIn:Bool = false
    @Published var serverOffline: Bool = false
    
    @Published var devMode: DevModeData? = DevModeData(isEnabled: false)
    @Published var navigation: CurrentNavigationData? = CurrentNavigationData(selectedTab: 0, expanded: false, hidden: false)
    @Published var haptic: HapticModeData? = HapticModeData(isEnabled: true)
    @Published var beginPageMode:Int = 0
    @Published var loginUser:Bool = false;
    @Published var createUser:Bool = false;
    /*
     * 0= none / loggedin
     * 1= begin
     * 2= login
     * 3= create
     * 4= logout
     */

    var userTokenManager = UserTokenHandler()
    var devModeManager = DevModeHandler()
    var navigationManager = CurrentNavigationHandler()
    var hapticModeManager = HapticModeHandler()

    var userTokens: UserTokenData
    
    var errorShow:Bool = false
    var errorFound:ErrorData?
    var userData: UserData?
    var themeData: ThemeData = ThemeData(devMode: DevModeData(isEnabled: false))
    
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
        self.apiHelper = API_Helper(userTokensProv: userTokens)

        self.auth = AuthApi(apiHelper: apiHelper)
        self.notifications = NotificationsApi(apiHelper: apiHelper)
        self.posts = PostsApi(apiHelper: apiHelper)
        self.users = UsersApi(apiHelper: apiHelper)
        self.get = GetApi(apiHelper: apiHelper)
        self.developer = DeveloperApi(apiHelper: apiHelper)
        self.polls = PollsApi(apiHelper: apiHelper)
        self.anaytics = AnalyticsApi(apiHelper: apiHelper)
        self.search = SearchApi(apiHelper: apiHelper)
        self.admin = AdminApi(apiHelper: apiHelper)

        self.livechatWS = LiveChatWebSocket(baseURL: self.apiHelper.baseAPIurl, userTokensProv: userTokens)

//        self.feedPosts = FeedPosts(client: self)
        
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
        } else {
            self.changeBeginSetting(value: 1)
        }
        self.themeData.updateThemes(devMode: self.devMode ?? DevModeData(isEnabled: false))
        self.checkServerStatus()
    }
    
    func changeBeginSetting(value: Int) {
        DispatchQueue.main.async {
            print("changing \(self.beginPageMode) to \(value)")

            self.beginPageMode = value
            print("changing to \(value)")
            if (value == 2) {
                self.loginUser = true
                self.createUser = false
            } else if (value == 3) {
                self.loginUser = false
                self.createUser = true
            } else if (value == 0) {
                self.loggedIn = true
                self.loginUser = false
                self.createUser = false

//            } else if (value == 1) {
//                self.loggedIn = false
            }
        }
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
            
            self.userData = userLoginResponse.publicData
            
            self.userTokenManager.saveUserTokens(userTokenData: self.userTokens)
            self.apiHelper = API_Helper(userTokensProv: self.userTokens)
            self.auth = AuthApi(apiHelper: self.apiHelper)
            self.notifications = NotificationsApi(apiHelper: self.apiHelper)
            self.posts = PostsApi(apiHelper: self.apiHelper)
            self.users = UsersApi(apiHelper: self.apiHelper)
            self.get = GetApi(apiHelper: self.apiHelper)
            self.developer = DeveloperApi(apiHelper: self.apiHelper)
            self.polls = PollsApi(apiHelper: self.apiHelper)
            self.anaytics = AnalyticsApi(apiHelper: self.apiHelper)
            self.search = SearchApi(apiHelper: self.apiHelper)
            self.admin = AdminApi(apiHelper: self.apiHelper)
            
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
