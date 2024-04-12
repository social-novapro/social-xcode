//
//  PushNotifications.swift
//  social-apple
//
//  Created by Daniel Kravec on 2023-12-18.
//

import SwiftUI

struct PushNotifications: View {
    @ObservedObject var client: ApiClient
    #if os(iOS)
    @UIApplicationDelegateAdaptor private var appDelegate: MyAppDelegate
    #endif
    @State var deviceSettings: [NotificationDeviceSetting]? = []
    @State var isLoading: Bool = true

    @State var changed: Bool = false
    @State var registered: Bool = false
//    @State var possibleSettings: [NotificationPossibleOptions]
    
    var body: some View {
        #if os(iOS)

        VStack {
            Text("Welcome to Notification Panel")
            Text("Press register to sign up for notifications! You will be able to deregister, and change what notifications to recieve!")
            Button(action: {
                
                appDelegate.registerPushNotifications()
                self.registered = true
            }, label: {
                Text("Register")
            })
            if (self.registered == true && self.isLoading == true) {
                Button(action: {
                    getDeviceSettings()
                }, label: {
                    Text("Click here to show settings")
                })
            }
            Button(action: {
                client.notifications.deregisterDevice() { result in
                    print (result)
                    self.isLoading = true
                    self.registered = false
                }
            }, label: {
                Text("Deregister")
            })
            if (!isLoading) {
                if changed == true {
                    Text("this was changed")
                }
                ScrollView {
                    ForEach(deviceSettings!) { deviceSetting in
                        VStack {
                            ChildNotificationDevice(client: client, deviceSettingIn: deviceSetting)
                        }
                        .listRowSeparator(.hidden)
                        .listRowInsets(EdgeInsets())
                        .padding(10)
                    }
                    EmptyView()
                        .frame(height: 200, alignment: .bottom)
                    VStack {
                        
                    }
                    .padding(50)
                }
                .listStyle(.plain)
                .listRowSeparator(.hidden)
            }
        }
        .onAppear {
            getDeviceSettings()
        }
        .navigationTitle("Notifications")
        #else
        VStack {
            Text("Can't sign up for notifications on macOS")
        }
        #endif
        
    }
    
    func getDeviceSettings() {
        client.notifications.getDeviceSettings() { result in
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
    @ObservedObject var client: ApiClient
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
        .background(client.devMode?.isEnabled == true ? Color.red : Color.clear)
        .cornerRadius(20)
        .overlay(
            RoundedRectangle(cornerRadius: 20)
                .stroke(Color.accentColor, lineWidth: 3)
        )
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
            
            client.notifications.putDeviceSettings(notificationSettingChange: newSetting) { result in
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
