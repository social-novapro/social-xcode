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
    @State private var registrationMessage: String?
    
    var body: some View {
        #if os(iOS)

        ScrollView {
            LazyVStack(alignment: .leading, spacing: 12) {
                InteractSectionHeader(
                    title: "Push Notifications",
                    subtitle: "Register this device and choose which notifications it receives."
                )
                
                InteractConnectedCardSection(tone: registered ? .selected : .normal) {
                    if isLoading {
                        InteractConnectedCardRow {
                            HStack(spacing: 10) {
                                ProgressView()
                                InteractSettingsRowLabel(
                                    title: "Checking Device",
                                    subtitle: "Looking for notification registration and settings.",
                                    systemImage: "bell",
                                    showsChevron: false
                                )
                            }
                        }
                    } else if registered {
                        InteractActionRow(
                            title: "Deregister Device",
                            subtitle: "Stop this device from receiving push notifications.",
                            systemImage: "bell.slash",
                            role: .destructive
                        ) {
                            deregisterDevice()
                        }
                    } else {
                        InteractActionRow(
                            title: "Register Device",
                            subtitle: "Sign this device up for notifications.",
                            systemImage: "bell.badge"
                        ) {
                            registerDevice()
                        }
                    }
                }

                if let registrationMessage {
                    InteractStatusBanner(tone: registered ? .selected : .normal) {
                        Text(registrationMessage)
                    }
                }
                
                if registered && !isLoading {
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
        isLoading = true
        client.api.notifications.refreshDeviceToken()

        guard client.api.notifications.getDeviceToken()?.isEmpty == false else {
            self.deviceSettings = []
            self.registered = false
            self.registrationMessage = nil
            self.isLoading = false
            return
        }

        client.api.notifications.getDeviceSettings() { result in
            print("get device settings")
            
            DispatchQueue.main.async {
                switch result {
                case .success(let foundResults):
                    self.deviceSettings = foundResults
                    self.registered = true
                    self.registrationMessage = nil
                    print("Done")
                    self.isLoading = false
                case .failure(let error):
                    print("Error: \(error.localizedDescription)")
                    self.deviceSettings = []
                    self.registered = false
                    self.registrationMessage = nil
                    self.isLoading = false
                }
            }
        }
    }

    private func registerDevice() {
        #if os(iOS)
        registrationMessage = "Registration requested."
        isLoading = true

        if let appDelegate = MyAppDelegate.shared ?? (UIApplication.shared.delegate as? MyAppDelegate) {
            appDelegate.registerPushNotifications(client: client)
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
                getDeviceSettings()
            }
        } else {
            registrationMessage = "Unable to access notification registration."
            isLoading = false
        }
        #endif
    }

    private func deregisterDevice() {
        isLoading = true
        client.api.notifications.deregisterDevice() { result in
            DispatchQueue.main.async {
                switch result {
                case .success:
                    self.deviceSettings = []
                    self.registered = false
                    self.registrationMessage = "Device deregistered."
                case .failure(let error):
                    self.deviceSettings = []
                    self.registered = false
                    self.registrationMessage = error.localizedDescription
                }
                self.isLoading = false
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
