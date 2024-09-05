//
//  Notifications.swift
//  social-apple
//
//  Created by Daniel Kravec on 2023-12-18.
//

import Foundation

class NotificationsApi: API_Base {
    private var deviceToken:String? = UserDefaults.standard.string(forKey: "deviceToken")

    func getDeviceToken() -> String? {
        self.deviceToken = UserDefaults.standard.string(forKey: "deviceToken")
        return deviceToken
    }
    
    func saveDeviceToken(deviceToken: String) {
        UserDefaults.standard.set(deviceToken, forKey: "deviceToken")
        let _ = getDeviceToken()
        print(self.deviceToken ?? "")
    }
    
    func registerDevice(notificationRegister: PushNotificationSend, completion: @escaping (Result<PushNotificationRes, Error>) -> Void) {
        print("register device request")
        let APIUrl = baseAPIurl + "/notifications/push/register"
        
        saveDeviceToken(deviceToken: notificationRegister.deviceToken)
        
        self.apiHelper.requestDataWithBody(urlString: APIUrl, httpMethod: "POST", httpBody: notificationRegister) { (result: Result<PushNotificationRes, Error>) in
            switch result {
            case .success(let response):
                print("Registered device")
                completion(.success(response))
            case .failure(let error):
                print("Error: \(error)")
            }
        }
    }
    
    func deregisterDevice(completion: @escaping (Result<PushNotificationRes, Error>) -> Void) {
        print("deregister device request")
        let APIUrl = baseAPIurl + "/notifications/push/deregister"
        let depushNotifications = DePushNotificationSend(deviceToken: self.deviceToken ?? "", userID: self.apiHelper.userTokens.userID)
        
        
        self.apiHelper.requestDataWithBody(urlString: APIUrl, httpMethod: "DELETE", httpBody: depushNotifications) { (result: Result<PushNotificationRes, Error>) in
            switch result {
            case .success(let response):
                print("Deregistered device")
                completion(.success(response))
            case .failure(let error):
                print("Error: \(error)")
            }
        }
    }
    
    func getDeviceSettings(completion: @escaping (Result<[NotificationDeviceSetting], Error>) -> Void) {
        if ((self.deviceToken == nil)){
            return
        }
        let APIUrl = baseAPIurl + "/notifications/push/deviceSettings"
//        let APIUrl = "baseAPIurl" + "/notifications/push/deviceSettings"

        self.apiHelper.requestDataWithBody(urlString: APIUrl, httpMethod: "POST", httpBody: NotificationDataDeviceTokenSend(deviceToken: self.deviceToken ?? "")) { (result: Result<[NotificationDeviceSetting], Error>) in
            switch result {
            case .success(let response):
                print("got device settings")
                completion(.success(response))
            case .failure(let error):
                print("Error: \(error)")
            }
        }
    }
    
    func putDeviceSettings(notificationSettingChange: SubmitPushNotificationNewSetting, completion: @escaping (Result<[NotificationDeviceSetting], Error>) -> Void) {
        if ((self.deviceToken == nil)){
            return
        }
        let APIUrl = baseAPIurl + "/notifications/push/update"
        let sendBody = SubmitPushNotificationSendSetting(newSettings: [notificationSettingChange], deviceToken: self.deviceToken ?? "")

        self.apiHelper.requestDataWithBody(urlString: APIUrl, httpMethod: "PUT", httpBody: sendBody) { (result: Result<[NotificationDeviceSetting], Error>) in
            switch result {
            case .success(let response):
                print("put device settings")
                completion(.success(response))
            case .failure(let error):
                print("Error: \(error)")
            }
        }
    }
}
