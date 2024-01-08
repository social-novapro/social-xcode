//
//  MyAppDelegate.swift
//  social-apple
//
//  Created by Daniel Kravec on 2023-12-18.
//

#if os(iOS)
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

        // Check if the app is in the foreground or background
         if application.applicationState == .active {
             // App is in the foreground, handle the notification             
             handleForegroundNotification(userInfo: userInfo)
         }

         // Call the completion handler when done processing the notification
         completionHandler(UIBackgroundFetchResult.newData)
    }
    
    func handleForegroundNotification(userInfo: [AnyHashable: Any]) {
        // Handle the notification when the app is in the foreground
        // You might want to update the UI or show an alert
        print("Handling notification in the foreground")
        guard let apsDict = userInfo["aps"] as? [String: Any] else {
            return
        }

        // Extract the alert dictionary
        guard let alertDict = apsDict["alert"] as? [String: Any] else {
            return
        }

        var newMessage:String = ""
        // Extract the title, body, and subtitle
        
        if let title = alertDict["title"] as? String,
           let body = alertDict["body"] as? String,
           let subtitle = alertDict["subtitle"] as? String {
            // Update the data manager or handle the data as needed
            print(title)
            if (title == "Interact") {
                newMessage = "\(subtitle.replacing("New Post from ", with: "")): \(body)"
            } else if (title == "Interact Live Chat") {
                newMessage = "\(subtitle.replacing("New Message from ", with: "")): \(body)"
            } else if (title == "Interact Like") {
                newMessage = "\(subtitle.replacing(" liked your post!", with: " liked")): \(body)"
            } else if (title == "Interact Reply") {
                newMessage = "\(subtitle.replacing(" replied to your post!", with: " replied")): \(body)"
            } else if (title == "Interact Quote") {
                newMessage = "\(subtitle.replacing(" quoted your post!", with: " quoted")): \(body)"
            } else if (title == "Interact Copost") {
                newMessage = "\(subtitle.replacing(" wants to copost with you!", with: " requested to copost")): \(body)"

            } else {
                newMessage = "\(subtitle) : \(body)"
            }
        }
        
        print(newMessage)
        NotificationCenter.default.post(name: NSNotification.Name("NotificationReceived"), object: newMessage)
    }
}


extension MyAppDelegate : UNUserNotificationCenterDelegate {
    func userNotificationCenter(_ center: UNUserNotificationCenter, didReceive response: UNNotificationResponse, withCompletionHandler completionHandler: @escaping () -> Void) {
        print("userNotificationCenter didReceive")
    }
    
    func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification, withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        print("userNotificationCenter willPresent")
        completionHandler([.banner, .sound, .badge])
    }
    
}
#endif 
