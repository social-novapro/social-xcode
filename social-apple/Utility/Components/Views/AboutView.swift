//
//  AboutView.swift
//  social-apple
//
//  Created by Daniel Kravec on 2023-04-22.
//

import SwiftUI


struct AboutView: View {
    @ObservedObject var client: Client

    var body: some View {
        ScrollView {
            VStack {
                HStack {
                    Text("Nova Productions Project")
                        .fontWeight(.heavy)
                    Spacer()
                }
                HStack {
                    Text("https://novapro.net")
                        .underline()
                    Spacer()
                }
            }
            .padding(20)
            
            VStack {
                HStack {
                    Text("About Interact")
                        .fontWeight(.heavy)
                    Spacer()
                }
                HStack {
                    Text("The project was developed by Daniel Kravec at Nova Productions. Interact is a social network, started in July 2021. Interact has an open API, letting anyone develop for it.")
                    Spacer()
                }
            }
            .padding(20)
            
            VStack {
                HStack {
                    Text("Interact Mobile Project")
                        .fontWeight(.heavy)
                    Spacer()
                }
                HStack {
                    Text("Thank you for downloading the mobile version of Interact!This version of the application works on macOS, iOS, and iPadOS.")
                    Spacer()
                }
            }
            .padding(20)

            VStack {
                HStack {
                    Text("Version")
                        .fontWeight(.heavy)
                    Spacer()
                }
                HStack {
                    Text("\(appVersion) b\(buildNumber)")
                    Spacer()
                }
            }
            .padding(20)


            VStack {
                HStack{
                    if (client.devMode?.isEnabled == true) {
                        Text("Disable DevMode")
                            .fontWeight(.heavy)
                    }
                    else {
                        Text("Enable DevMode")
                            .fontWeight(.heavy)
                    }

                    Spacer()
                }
                Button(action: {
                    client.devMode = client.devModeManager.swapMode()
                    client.themeData.updateThemes(devMode: client.devMode ?? DevModeData(isEnabled: false))
                }) {
                    HStack {
                        Text("Dev Mode")
                        Spacer()
                    }
                }
            }
            .padding(20)
            .background(client.themeData.greenBackground)

        }
        .padding(10)
        .navigationTitle("About Interact")
    }
    
    // Computed property to get the app version
    var appVersion: String {
        if let version = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String {
            return version
        }
        return "Unknown"
    }

    // Computed property to get the build number
    var buildNumber: String {
        if let build = Bundle.main.infoDictionary?["CFBundleVersion"] as? String {
            return build
        }
        return "Unknown"
    }
}
