//
//  Notifications.swift
//  social-apple
//
//  Created by Daniel Kravec on 2023-12-18.
//

import Foundation

class NotificationsApi: API_Helper {
    func registerDevice(notificationRegister: PushNotificationSend, completion: @escaping (Result<PushNotificationRes, Error>) -> Void) {
        print("register device request")
        let APIUrl = baseAPIurl + "/notifications/push/register"
        
        self.requestDataWithBody(urlString: APIUrl, httpMethod: "POST", httpBody: notificationRegister) { (result: Result<PushNotificationRes, Error>) in
            switch result {
            case .success(let response):
                print("Registered device")
                completion(.success(response))
            case .failure(let error):
                print("Error: \(error)")
            }
        }
    }
}
