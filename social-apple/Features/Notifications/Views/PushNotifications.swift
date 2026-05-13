//
//  PushNotifications.swift
//  social-apple
//
//  Created by Daniel Kravec on 2023-12-18.
//

import SwiftUI

struct PushNotifications: View {
    @ObservedObject var client: Client
    @State var deviceSettings: [NotificationDeviceSetting]? = []
    @State var isLoading: Bool = true

    @State var changed: Bool = false
    @State var registered: Bool = false
    
    var body: some View {
        #if os(iOS)

        ScrollView {
            LazyVStack(alignment: .leading, spacing: 12) {
                InteractSectionHeader(
                    title: "Push Notifications",
                    subtitle: "Register this device and choose which notifications it receives."
                )
                
                InteractConnectedCardSection(tone: registered ? .selected : .normal) {
                    InteractActionRow(
                        title: "Register Device",
                        subtitle: "Sign this device up for notifications.",
                        systemImage: "bell.badge"
                    ) {
                        #if os(iOS)
                        if let appDelegate = MyAppDelegate.shared ?? (UIApplication.shared.delegate as? MyAppDelegate) {
                            appDelegate.registerPushNotifications(client: client)
                            self.registered = true
                        } else {
                            print("Unable to access shared MyAppDelegate for push registration")
                        }
                        #endif
                    }
                    
                    if (self.registered == true && self.isLoading == true) {
                        InteractConnectedCardDivider(leadingInset: 56)
                        
                        InteractActionRow(
                            title: "Show Settings",
                            subtitle: "Refresh this device token and load notification options.",
                            systemImage: "arrow.clockwise"
                        ) {
                            client.api.notifications.refreshDeviceToken()
                            getDeviceSettings()
                        }
                        .onAppear() {
                            self.client.api.notifications.refreshDeviceToken()
                            self.getDeviceSettings()
                        }
                    }
                    
                    InteractConnectedCardDivider(leadingInset: 56)
                    
                    InteractActionRow(
                        title: "Deregister Device",
                        subtitle: "Stop this device from receiving push notifications.",
                        systemImage: "bell.slash",
                        role: .destructive
                    ) {
                        client.api.notifications.deregisterDevice() { result in
                            print (result)
                            self.isLoading = true
                            self.registered = false
                        }
                    }
                }
                
                if (!isLoading) {
                    if changed == true {
                        InteractStatusBanner(tone: .selected) {
                            Text("Notification setting changed.")
                        }
                    }
                    
                    ForEach(deviceSettings ?? []) { deviceSetting in
                            ChildNotificationDevice(client: client, deviceSettingIn: deviceSetting)
                    }
                }
            }
            .interactScreenPadding()
        }
        .interactAppBackground()
        .onAppear {
            #if os(iOS)
            if let appDelegate = MyAppDelegate.shared ?? (UIApplication.shared.delegate as? MyAppDelegate) {
                appDelegate.client = client
            }
            #endif
            getDeviceSettings()
        }
        .navigationTitle("Notifications")
        #else
        VStack {
            Text("Can't sign up for notifications on macOS")
        }
        .interactAppBackground()
        #endif
        
    }
    
    func getDeviceSettings() {
        client.api.notifications.getDeviceSettings() { result in
            print("get device settings")
            
            switch result {
            case .success(let foundResults):
                self.deviceSettings = foundResults
                self.registered = true
                print("Done")
                self.isLoading = false
            case .failure(let error):
                print("Error: \(error.localizedDescription)")
            }
        }
    }
}

struct ChildNotificationDevice: View {
    @ObservedObject var client: Client
    @State var deviceSettingIn: NotificationDeviceSetting
    @State var isActive: Bool = false
    @State var loading: Bool = false
    @State var saved: Bool = false
    @State var failed: Bool = false
    @State var doneIntialLoad: Bool = false
    
    var body: some View {
        VStack {
            Toggle("\(deviceSettingIn.displayName)", isOn: $isActive)
            Divider()
            HStack {
                Text("\(deviceSettingIn.description)")
                Spacer()
            }
            HStack {
                if (loading == true) {
                    if (saved != true) {
                        if (failed) {
                            Text("Failed to save")
                        } else {
                            Text("Loading")
                        }
                    } else {
                        Text("Saved")
                    }
                }
            }
        }
        .padding(15)
        .interactCardSurface(cornerRadius: 20, lineWidth: 3, originalBackground: client.themeData.mainBackground, originalBorder: .accentColor)
        .onAppear {
            self.isActive = deviceSettingIn.value ? deviceSettingIn.value : false
        }
        .onChange(of: isActive) { newValue in
            if (doneIntialLoad == false && newValue == deviceSettingIn.value)  {
                self.doneIntialLoad = true
                return
            }
            self.loading = true
            self.saved = false
            let newSetting = SubmitPushNotificationNewSetting(value: newValue, name: deviceSettingIn.name)
            
            client.api.notifications.putDeviceSettings(notificationSettingChange: newSetting) { result in
                switch result {
                case .success(_):
                    self.saved = true
                case .failure(let error):
                    print("Error: \(error.localizedDescription)")
                    self.failed = true
                }
            }
        }
    }
}
