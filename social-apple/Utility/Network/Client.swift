//
//  Client.swift
//  social-apple
//
//  Created by Daniel Kravec on 2024-09-05.
//

import Foundation
import CoreHaptics
import SwiftUI

class Client: ObservableObject {
    @Published var loggedIn:Bool = false
    @Published var serverOffline: Bool = false
    
    @Published var devMode: DevModeData? = DevModeData(isEnabled: false)
    @Published var navigation: CurrentNavigationData? = CurrentNavigationData(selectedTab: 0, expanded: false, hidden: false)
    @Published var haptic: HapticModeData? = HapticModeData(isEnabled: true)
    @Published var beginPageMode:Int = 0
    @Published var loginUser:Bool = false;
    @Published var createUser:Bool = false;
    @Published var pendingSearchLookup: String? = nil
    /*
     * 0= none / loggedin
     * 1= begin
     * 2= login
     * 3= create
     * 4= logout
     */
    
    var userTokenManager = UserTokenHandler(persistentContainer: PersistenceController.shared.container)
    var devModeManager = DevModeHandler(persistentContainer: PersistenceController.shared.container)
    var navigationManager = CurrentNavigationHandler(persistentContainer: PersistenceController.shared.container)
    var hapticModeManager = HapticModeHandler(persistentContainer: PersistenceController.shared.container)

    @Published var userTokens: UserTokenData
    @Published var userData: UserData?
    @Published var savedUserTokens: [UserTokenData] = []
    var themeData: ThemeData = ThemeData(devMode: DevModeData(isEnabled: false))

    @Published var cache = CacheManager();
    
    @Published var api: ApiClient
//    @Published var apiHelper: API_Helper
    
    init() {
        let tokensFound = userTokenManager.getUserTokens()
        let initialUserTokens: UserTokenData
        if (tokensFound != nil) {
            initialUserTokens = tokensFound!
            self.loggedIn = true
        } else {
            initialUserTokens = UserTokenData(accessToken: "", userToken: "", userID: "")
            self.loggedIn = false
        }
        self.userTokens = initialUserTokens
        
        let apiHelper = API_Helper(userTokensProv: initialUserTokens)
        self.api = ApiClient(apiHelper: apiHelper)

        // other navigation
        self.devMode = self.devModeManager.getDevMode()
        self.navigation = self.navigationManager.getCurrentNavigation()
        self.haptic = self.hapticModeManager.getHapticMode()
        
//        self.api.apiHelper.provideError(error: ErrorData(code: "Z004", msg: "Testing error from client", error: true))
        
        if (self.loggedIn == true) {
            self.loadCurrentUserData()
        } else {
            self.changeBeginSetting(value: 1)
        }
        self.themeData.updateThemes(devMode: self.devMode ?? DevModeData(isEnabled: false))
        self.checkServerStatus()
    }
    
    func provideTokens(userLoginResponse: UserLoginResponse, completion: (() -> Void)? = nil) {
        /* sets up tokens */
        print("Providing tokens")
        DispatchQueue.main.async {
            let newTokens = UserTokenData(
                accessToken: userLoginResponse.accessToken,
                userToken: userLoginResponse.userToken,
                userID: userLoginResponse.userID
            )
            
            self.userTokens = newTokens
            self.userData = userLoginResponse.publicData
            self.userTokenManager.saveUserTokens(userTokenData: newTokens)
            self.savedUserTokens = self.userTokenManager.getAllUserTokens()
            self.api.updateUserTokens(userTokens: self.userTokens)
            self.loggedIn = true
            self.loginUser = false
            self.createUser = false
            self.beginPageMode = 0
            completion?()
        }
    }
    
    @discardableResult
    func switchAccount(userID: String, completion: (() -> Void)? = nil) -> Bool {
        guard let switchedTokens = userTokenManager.switchActiveUser(userID: userID) else {
            return false
        }
        
        DispatchQueue.main.async {
            self.applyUserTokens(switchedTokens)
            self.userData = nil
            self.savedUserTokens = self.userTokenManager.getAllUserTokens()
            self.loggedIn = true
            self.beginPageMode = 0
            self.loginUser = false
            self.createUser = false
            self.loadCurrentUserData()
            completion?()
        }
        return true
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
            }
        }
    }
    
    func logoutCurrentAccount(completion: (() -> Void)? = nil) {
        DispatchQueue.main.async {
            if let nextTokens = self.userTokenManager.deleteCurrentUserToken() {
                self.applyUserTokens(nextTokens)
                self.userData = nil
                self.savedUserTokens = self.userTokenManager.getAllUserTokens()
                self.loggedIn = true
                self.beginPageMode = 0
                self.loadCurrentUserData()
            } else {
                self.clearCurrentSession()
            }
            completion?()
        }
    }
    
    func logoutAllAccounts(completion: (() -> Void)? = nil) {
        DispatchQueue.main.async {
            self.userTokenManager.deleteAllUserTokens()
            self.clearCurrentSession()
            completion?()
        }
    }
    
    func logout() {
        logoutCurrentAccount()
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
        guard let url = URL(string: api.apiHelper.baseAPIurl + "/serverStatus") else {
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
    
    func triggerError() {
        self.api.apiHelper.provideError(error: ErrorData(code: "Z999", msg: "Triggered error from frontend", error: true))
    }
    
    func dismissError() {
        self.api.apiHelper.dismissError()
    }
    
    private func applyUserTokens(_ userTokens: UserTokenData) {
        self.userTokens = userTokens
        self.api.updateUserTokens(userTokens: userTokens)
    }
    
    private func clearCurrentSession() {
        let emptyTokens = UserTokenData(accessToken: "", userToken: "", userID: "")
        self.userTokens = emptyTokens
        self.userData = nil
        self.savedUserTokens = []
        self.api.updateUserTokens(userTokens: emptyTokens)
        self.loggedIn = false
        self.beginPageMode = 1
        self.loginUser = false
        self.createUser = false
    }
    
    private func loadCurrentUserData() {
        guard !self.userTokens.userID.isEmpty else {
            self.userData = nil
            return
        }
        
        let loadingUserID = self.userTokens.userID
        
        self.api.users.getByID(userID: loadingUserID) { result in
            DispatchQueue.main.async {
                guard self.userTokens.userID == loadingUserID else {
                    return
                }
                
                switch result {
                case .success(let results):
                    self.userData = results
                case .failure(let error):
                    print("Error: \(error.localizedDescription)")
                }
            }
        }
    }
}
