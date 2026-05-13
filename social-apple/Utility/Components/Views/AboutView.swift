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
            LazyVStack(alignment: .leading, spacing: 12) {
                InteractConnectedCardSection {
                    InteractConnectedCardRow {
                        InteractSettingsRowLabel(
                            title: "Nova Productions Project",
                            subtitle: "https://novapro.net",
                            systemImage: "network",
                            showsChevron: false
                        )
                    }
                    
                    InteractConnectedCardDivider(leadingInset: 56)
                    
                    InteractConnectedCardRow {
                        VStack(alignment: .leading, spacing: 6) {
                            Text("About Interact")
                                .font(.headline)
                            Text("The project was developed by Daniel Kravec at Nova Productions. Interact is a social network, started in July 2021. Interact has an open API, letting anyone develop for it.")
                                .font(.subheadline)
                                .foregroundStyle(.secondary)
                        }
                    }
                    
                    InteractConnectedCardDivider()
                    
                    InteractConnectedCardRow {
                        VStack(alignment: .leading, spacing: 6) {
                            Text("Interact Mobile Project")
                                .font(.headline)
                            Text("Thank you for downloading the mobile version of Interact! This version of the application works on macOS, iOS, and iPadOS.")
                                .font(.subheadline)
                                .foregroundStyle(.secondary)
                        }
                    }
                    
                    InteractConnectedCardDivider()
                    
                    InteractConnectedCardRow {
                        InteractSettingsRowLabel(
                            title: "Version",
                            subtitle: "\(appVersion) b\(buildNumber)",
                            systemImage: "number",
                            showsChevron: false
                        )
                    }
                }
                
                InteractActionRow(
                    title: client.devMode?.isEnabled == true ? "Disable Dev Mode" : "Enable Dev Mode",
                    subtitle: "Toggle local developer-only tools.",
                    systemImage: "hammer"
                ) {
                    client.devMode = client.devModeManager.swapMode()
                    client.themeData.updateThemes(devMode: client.devMode ?? DevModeData(isEnabled: false))
                }
            }
            .interactScreenPadding()
        }
        .interactAppBackground()
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
