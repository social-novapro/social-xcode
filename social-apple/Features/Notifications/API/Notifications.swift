//
//  Notifications.swift
//  social-apple
//
//  Created by Daniel Kravec on 2023-12-18.
//

import Foundation

class NotificationsApi: API_Base {
    private enum Route {
        static let register = "/notifications/push/register"
        static let deregister = "/notifications/push/deregister"
        static let deviceSettings = "/notifications/push/deviceSettings"
        static let update = "/notifications/push/update"
    }

    private var deviceToken:String? = UserDefaults.standard.string(forKey: "deviceToken")

    private func deviceTokenError() -> NSError {
        NSError(
            domain: "NotificationsApi",
            code: -1,
            userInfo: [NSLocalizedDescriptionKey: "No device token is registered on this device."]
        )
    }

    func refreshDeviceToken() {
        self.deviceToken = UserDefaults.standard.string(forKey: "deviceToken")
    }
    
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
        let APIUrl = baseAPIurl + Route.register

        saveDeviceToken(deviceToken: notificationRegister.deviceToken)

        self.apiHelper.requestDataWithBody(urlString: APIUrl, httpMethod: "POST", httpBody: notificationRegister) { (result: Result<PushNotificationRes, Error>) in
            switch result {
            case .success(let response):
                print("Registered device")
                self.refreshDeviceToken()
                completion(.success(response))
            case .failure(let error):
                print("Error: \(error)")
                completion(.failure(error))
            }
        }
    }

    func registerDeviceTokenFromAPNs(
        deviceToken: String,
        completion: @escaping (Result<PushNotificationRes, Error>) -> Void
    ) {
        let sendData = PushNotificationSend(
            deviceToken: deviceToken,
            deviceType: "iPhone",
            userID: self.apiHelper.userTokens.userID
        )

        self.registerDevice(notificationRegister: sendData, completion: completion)
    }
    
    func deregisterDevice(completion: @escaping (Result<PushNotificationRes, Error>) -> Void) {
        print("deregister device request")
        refreshDeviceToken()
        guard let deviceToken, deviceToken.isEmpty == false else {
            completion(.failure(deviceTokenError()))
            return
        }

        let APIUrl = baseAPIurl + Route.deregister
        let depushNotifications = DePushNotificationSend(deviceToken: deviceToken, userID: self.apiHelper.userTokens.userID)
        
        
        self.apiHelper.requestDataWithBody(urlString: APIUrl, httpMethod: "DELETE", httpBody: depushNotifications) { (result: Result<PushNotificationRes, Error>) in
            switch result {
            case .success(let response):
                print("Deregistered device")
                UserDefaults.standard.removeObject(forKey: "deviceToken")
                self.refreshDeviceToken()
                completion(.success(response))
            case .failure(let error):
                print("Error: \(error)")
                completion(.failure(error))
            }
        }
    }
    
    func getDeviceSettings(completion: @escaping (Result<[NotificationDeviceSetting], Error>) -> Void) {
        refreshDeviceToken()
        guard let deviceToken, deviceToken.isEmpty == false else {
            completion(.failure(deviceTokenError()))
            return
        }
        let APIUrl = baseAPIurl + Route.deviceSettings

        self.apiHelper.requestDataWithBody(urlString: APIUrl, httpMethod: "POST", httpBody: NotificationDataDeviceTokenSend(deviceToken: deviceToken)) { (result: Result<[NotificationDeviceSetting], Error>) in
            switch result {
            case .success(let response):
                print("got device settings")
                completion(.success(response))
            case .failure(let error):
                print("Error: \(error)")
                completion(.failure(error))
            }
        }
    }
    
    func putDeviceSettings(notificationSettingChange: SubmitPushNotificationNewSetting, completion: @escaping (Result<[NotificationDeviceSetting], Error>) -> Void) {
        refreshDeviceToken()
        guard let deviceToken, deviceToken.isEmpty == false else {
            completion(.failure(deviceTokenError()))
            return
        }
        let APIUrl = baseAPIurl + Route.update
        let sendBody = SubmitPushNotificationSendSetting(newSettings: [notificationSettingChange], deviceToken: deviceToken)

        self.apiHelper.requestDataWithBody(urlString: APIUrl, httpMethod: "PUT", httpBody: sendBody) { (result: Result<[NotificationDeviceSetting], Error>) in
            switch result {
            case .success(let response):
                print("put device settings")
                completion(.success(response))
            case .failure(let error):
                print("Error: \(error)")
                completion(.failure(error))
            }
        }
    }
}
