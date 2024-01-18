//
//  DeveloperSettingsView.swift
//  social-apple
//
//  Created by Daniel Kravec on 2024-01-16.
//

import SwiftUI

struct DeveloperSettingsView: View {
    @ObservedObject var client: ApiClient
    @State var developerData: DeveloperResponseData?
    @State var loading: Bool = true
    @State var newApplications: [AppTokenData] = []
    @State var createdNewDev: Bool = false
    
    var body: some View {
        VStack {
            if (loading == false) {
                ScrollView {
                    VStack {
                        AccountStatusView(client: client, developerData: $developerData)
                        
                        if (developerData != nil && loading==false ) {
                            if (developerData?.DeveloperToken != nil) {
                                DeveloperTokenView(client: client, developerToken: (developerData?.DeveloperToken!)!)
                            }
                            
                            if (developerData?.AppTokens.isEmpty != true) {
                                Text("Your Approved Developer Applications:")
                                ForEach(developerData?.AppTokens ?? []) { appToken in
                                    AppTokenView(client: client, appToken: appToken)
                                        .padding(10)
                                }
                            }
                            GenerateAppView(
                                client: client,
                                newApplications: $newApplications,
                                developerToken: developerData?.DeveloperToken?._id ?? ""
                            )
                            
                            if (newApplications.isEmpty != true) {
                                Text("Your new Developer Applications:")
                                ForEach(newApplications) { appToken in
                                    AppTokenView(client: client, appToken: appToken)
                                        .padding(10)
                                }
                            }
                            
                            if (developerData?.AppAccesses.isEmpty != true) {
                                Text("Connected Applications:")
                                
                                ForEach(developerData?.AppAccesses ?? []) { accessToken in
                                    AccessTokenView(client: client, accessToken: accessToken)
                                        .padding(10)
                                }
                            }
                        }
                    }
                }
            }
        }
        .navigationTitle("Developer Settings")
        .onAppear {
            client.developer.getDeveloperData() { result in
                print("api rquest login:")
                switch result {
                case .success(let newData):
                    self.developerData = newData
                    self.loading = false;
                case .failure(let error):
                    print("Error: \(error.localizedDescription)")
                }
            }
        }
    }
}


struct GenerateAppView: View {
    @ObservedObject var client: ApiClient
    @Binding var newApplications: [AppTokenData]
    @State var newApplicationName: String = ""
    @State var developerToken: String
    @State var created: Bool = false
    @State var failed: Bool = false
    
    var body: some View {
        VStack {
            HStack {
                if (failed==true) {
                    Text("Could not create new application.")
                } else if (created==true) {
                    Text("Created new application!")
                }
                Spacer()
            }
            HStack {
                Text("Generate New App Token")
                Spacer()
            }
            HStack {
                Text("Please input an application name")
                Spacer()
            }
            HStack{
                TextField("Application Name", text: $newApplicationName)
                    .padding(15)
                    .cornerRadius(20)
                    .overlay(
                        RoundedRectangle(cornerRadius: 20)
                            .stroke(Color.accentColor, lineWidth: 3)
                    )
                    .padding(10)
            }
            
            HStack{
                if (newApplicationName != "") {
                    Button(action: {
                        client.hapticPress()
                        let newTokenReq = NewAppTokenReq(userdevtoken: developerToken, appname: newApplicationName)
                        
                        newApplicationName=""
                        
                        client.developer.newAppToken(newAppToken: newTokenReq) { result in
                            switch result {
                            case .success(let appData):
                                print("Generated Token")
                                newApplications.append(appData)
                                created=true
                                
                            case .failure(let error):
                                print("Error: \(error)")
                                failed=true
                            }
                        }
                    }, label: {
                        Text("Generate Token")
                            .padding(15)
                            .cornerRadius(20)
                            .overlay(
                                RoundedRectangle(cornerRadius: 20)
                                    .stroke(Color.accentColor, lineWidth: 3)
                            )
                            .padding(10)
                    })
                }
            }
        }
        .padding(15)
        .cornerRadius(20)
        .overlay(
            RoundedRectangle(cornerRadius: 20)
                .stroke(Color.accentColor, lineWidth: 3)
        )
        .padding(10)
    }
}

struct DeveloperTokenView: View {
    @ObservedObject var client: ApiClient
    @State var developerToken: DeveloperTokenData
    @State var copied: Bool = false

    var body: some View {
        VStack {
            HStack {
                Text("devToken: ")
                HiddenText(text: developerToken._id ?? "")
                Spacer()
            }
            HStack {
                if (developerToken.premium ?? false) {
                    Text("Premium Developer Account")
                } else {
                    Text("Regular Developer Account")
                }
                Spacer()
            }
            HStack {
                if (developerToken.creationTimestamp != nil) {
                    Text("Created " + int64TimeFormatter(timestamp: developerToken.creationTimestamp ?? 0))
                } else {
                    Text("Unknown Creation Date")
                }
                Spacer()
            }
            HStack {
                if (copied == true) {
                    Text("Copied Token!")
                        .onTapGesture(count: 1) {
                            self.copied=false
                        }
                } else {
                    Text("Click to Copy devToken")
                        .onTapGesture(count: 1) {
                            UIPasteboard.general.string = self.developerToken._id ?? "failed"
                            self.copied=true
                        }
                }
                Spacer()
            }
        }
        .padding(15)
        .cornerRadius(20)
        .overlay(
            RoundedRectangle(cornerRadius: 20)
                .stroke(Color.accentColor, lineWidth: 3)
        )
        .padding(10)
    }
}

struct AccountStatusView: View {
    @ObservedObject var client: ApiClient
    @Binding var developerData: DeveloperResponseData?


    var body: some View {
        VStack {
            Text("Account Status")
            VStack {
                if (developerData?.developer != true) {
                    Text("You are not a developer.")
                    Text("Click below to sign up as a developer.")
                    Button(action: {
                        client.hapticPress()
                    }, label: {
                        Text("not real button yet")
                            .padding(15)
                            .cornerRadius(20)
                            .overlay(
                                RoundedRectangle(cornerRadius: 20)
                                    .stroke(Color.accentColor, lineWidth: 3)
                            )
                            .padding(10)
                    })

                } else {
                    Text("You have an Interact Developer Account")
                    Text("You have " + String(developerData?.AppTokens.count ?? 0) + " Approved Applications")
                }
                Text(String(developerData?.AppAccesses.count ?? 0 ) + " Connected Appliactions")
            }
            .padding(15)
            .cornerRadius(20)
            .overlay(
                RoundedRectangle(cornerRadius: 20)
                    .stroke(Color.accentColor, lineWidth: 3)
            )
            .padding(10)
        }
    }
}

struct AppTokenView: View {
    @ObservedObject var client: ApiClient
    @State var appToken: AppTokenData
    @State var copied: Bool = false
    
    var body: some View {
        VStack {
            HStack {
                if (appToken.appName != nil) {
                    Text(appToken.appName ?? "")
                } else {
                    Text("Unknown App Name")
                }
                Spacer()
            }
            HStack {
                if (appToken.creationTimestamp != nil) {
                    Text("Created " + int64TimeFormatter(timestamp: appToken.creationTimestamp ?? 0))
                } else {
                    Text("Unknown Creation Date")
                }
                Spacer()
            }
            HStack {
                Text("API Uses: " + String(appToken.APIUses ?? 0))
                Spacer()
            }
            HStack {
                Text("appToken: " )
                HiddenText(text: self.appToken._id)
                Spacer()
            }
            HStack {
                if (copied == true) {
                    Text("Copied Token!")
                        .onTapGesture(count: 1) {
                            self.copied=false
                        }
                 } else {
                    Text("Click to Copy appToken")
                    .onTapGesture(count: 1) {
                            UIPasteboard.general.string = self.appToken._id
                            self.copied=true
                        }
                }
                Spacer()
            }
        }
        .padding(15)
        .cornerRadius(20)
        .overlay(
            RoundedRectangle(cornerRadius: 20)
                .stroke(Color.accentColor, lineWidth: 3)
        )
    }
}

struct AccessTokenView: View {
    @ObservedObject var client: ApiClient
    @State var accessToken: AppAccessesData

    var body: some View {
        VStack {
            HStack {
                if (accessToken.creationTimestamp != nil) {
                    Text("Connected " + int64TimeFormatter(timestamp: accessToken.creationTimestamp ?? 0))
                } else {
                    Text("Unknown Connection Date")
                }
                Spacer()
            }
            HStack {
                Text("accessToken: ")
                HiddenText(text: self.accessToken._id ?? "Unknown")
                Spacer()
            }
            HStack {
                Text("Using appToken: ")
                HiddenText(text: self.accessToken.appToken ?? "Unknown")
                Spacer()
            }
            
        }
        .padding(15)
        .cornerRadius(20)
        .overlay(
            RoundedRectangle(cornerRadius: 20)
                .stroke(Color.accentColor, lineWidth: 3)
        )
    }
}

struct HiddenText: View {
    @State var text: String
    @State var isHidden = true
    
    var body: some View {
        HStack {
            VStack {
                Text(isHidden == true ? "Click to unhide." : text)
                    .foregroundStyle(isHidden == true ? Color.red : .primary )
                    .onTapGesture(count: 1) {
                        isHidden.toggle()
                }
            }
        }
    }
}
