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
    var userData: UserData?
    var themeData: ThemeData = ThemeData(devMode: DevModeData(isEnabled: false))

    
    var api: ApiClient
    
    init() {
        let tokensFound = userTokenManager.getUserTokens()
        if (tokensFound != nil) {
            self.userTokens = tokensFound!
            self.loggedIn = true
        } else {
            self.userTokens = UserTokenData(accessToken: "", userToken: "", userID: "")
            self.loggedIn = false
        }
        
        self.api = ApiClient(userTokens: self.userTokens)

        // other navigation
        self.devMode = self.devModeManager.getDevMode()
        self.navigation = self.navigationManager.getCurrentNavigation()
        self.haptic = self.hapticModeManager.getHapticMode()
        
        if (self.loggedIn == true) {
            self.api.users.getByID(userID: userTokens.userID) { result in
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
            self.api.updateUserTokens(userTokens: self.userTokens)
            self.loggedIn = true
        }
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
    
    func logout() {
        DispatchQueue.main.async {
            self.userTokenManager.deleteUserToken()
            self.loggedIn = false
            self.api.userTokens = UserTokenData(accessToken: "", userToken: "", userID: "");
            self.userTokens = UserTokenData(accessToken: "", userToken: "", userID: "");
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
}
