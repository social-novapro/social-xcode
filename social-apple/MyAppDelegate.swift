//
//  MyAppDelegate.swift
//  social-apple
//
//  Created by Daniel Kravec on 2023-12-18.
//

import UIKit
import UserNotifications

class MyAppDelegate: UIResponder, UIApplicationDelegate {
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil) -> Bool {
        print("didFinishLaunchingWithOptions")

        return true;
    }
    
    // PUSH NOTIFICATIONS
    func registerPushNotifications() {
        UNUserNotificationCenter.current().delegate = self
        let authOptions: UNAuthorizationOptions = [.alert, .badge, .sound]
        
        UNUserNotificationCenter.current()
            .requestAuthorization(options: authOptions) { granted, error in
                print("permission granted: \(granted)")
                
                if let error = error {
                    print("Error: \(error.localizedDescription)")
                } else {
                    DispatchQueue.main.async {
                        UIApplication.shared.registerForRemoteNotifications()
                        
                    }
                }
            }
    }
    
    func application(_ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
        
        print("Successfully registered notificaiton")
        let tokenParts = deviceToken.map{ data in String(format: "%02.2hhx", data) }
        let token = tokenParts.joined()
//        client.notifications
        print(token)

        let userTokenManager = UserTokenHandler()
        let tokensFound = userTokenManager.getUserTokens()
        let userTokens = (tokensFound != nil) ? tokensFound : UserTokenData(accessToken: "", userToken: "", userID: "")
       
        let sendData = PushNotificationSend(deviceToken: token, deviceType: "iPhone", userID: userTokens?.userID ?? "empty")
        let notificationsApi = NotificationsApi(userTokensProv: userTokens!)
        notificationsApi.registerDevice(notificationRegister: sendData) { result in
                print("done registering")
        }
        
    }
    
    func application(_ application: UIApplication, didFailToRegisterForRemoteNotificationsWithError error: Error) {
        print("Failed to register notifications")
    }
    
    
    func application(_ application: UIApplication, didReceiveRemoteNotification userInfo: [AnyHashable : Any], fetchCompletionHandler completionHandler: @escaping (UIBackgroundFetchResult) -> Void) {
        print("didReceiveRemoteNotification")
        print(userInfo)
        
    }
}

extension MyAppDelegate : UNUserNotificationCenterDelegate {
    func userNotificationCenter(_ center: UNUserNotificationCenter, didReceive response: UNNotificationResponse, withCompletionHandler completionHandler: @escaping () -> Void) {
        print("userNotificationCenter didReceive")
    }
    
    func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification, withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        print("userNotificationCenter willPresent")
        
        completionHandler(UNNotificationPresentationOptions(rawValue: 0))
    }
}
