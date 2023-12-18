//
//  PushNotifications.swift
//  social-apple
//
//  Created by Daniel Kravec on 2023-12-18.
//

import SwiftUI

struct PushNotifications: View {
    @ObservedObject var client: ApiClient
    @UIApplicationDelegateAdaptor private var appDelegate: MyAppDelegate

    var body: some View {
        Text("Welcome to Notification Panel")
        Text("To change notifications, im not sure, you cant just yet!")
        Button(action: {
            appDelegate.registerPushNotifications()
        }, label: {
            Text("Register")
        })
    }
}
