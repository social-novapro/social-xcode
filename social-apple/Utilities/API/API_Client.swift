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
    var media: FilesAPI

    var livechatWS: LiveChatWebSocket
    @Published var apiHelper: API_Helper
    var userTokens: UserTokenData

//    @Published var errorShow:Bool = false
//    @Published var errorFound:ErrorData?
    
    convenience init() {
//        self.userTokens = userTokens
        let userTokenManager = UserTokenHandler()
        let tokensFound = userTokenManager.getUserTokens()
        
        var provideTokens = UserTokenData(accessToken: "", userToken: "", userID: "")

        if (tokensFound != nil) {
            provideTokens = tokensFound!
        }
        
        let apiHelper = API_Helper(userTokensProv: provideTokens)

        self.init(apiHelper: apiHelper)
    }
    
    init(apiHelper: API_Helper) {
//        self.userTokens = userTokens
        self.apiHelper = apiHelper
        
        // routes
//        let apiHelper = API_Helper(userTokensProv: userTokens)

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
        self.media = FilesAPI(apiHelper: apiHelper)
        self.userTokens = apiHelper.userTokens

        self.livechatWS = LiveChatWebSocket(baseURL: apiHelper.baseAPIurl, userTokensProv: userTokens)
//        self.apiHelper.errorShow = true
//        self.apiHelper.provideError(error: ErrorData(code: "Z00677", msg: "wtf", error: true))
    }
    
    func updateUserTokens(userTokens: UserTokenData) {
        /* sets up tokens */
        print("Providing tokens")
        DispatchQueue.main.async {
            self.userTokens = userTokens
            
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
            self.admin = AdminApi(apiHelper: self.apiHelper)
        }
    }
}
