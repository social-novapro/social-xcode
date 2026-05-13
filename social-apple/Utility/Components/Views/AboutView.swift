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
                        HStack(spacing: 10) {
                            Image(systemName: "bubble.left.and.bubble.right.fill")
                                .font(.title3)
                                .foregroundStyle(.secondary)

                            VStack(alignment: .leading, spacing: 2) {
                                Text("Interact")
                                    .font(.headline)
                                Text("Social Network")
                                    .font(.subheadline)
                                    .foregroundStyle(.secondary)
                            }

                            Spacer(minLength: 8)
                        }
                    }
                }

                InteractSectionHeader(title: "App")
                InteractConnectedCardSection {
                    aboutRow(title: "Version", value: appVersion)
                    InteractConnectedCardDivider()
                    aboutRow(title: "Build", value: buildNumber)
                }

                InteractSectionHeader(title: "Website")
                InteractConnectedCardSection {
                    InteractConnectedCardRow {
                        if let websiteURL {
                            Link(destination: websiteURL) {
                                HStack {
                                    Label("novapro.net", systemImage: "globe")
                                        .font(.subheadline.weight(.semibold))

                                    Spacer(minLength: 8)

                                    Image(systemName: "arrow.up.right")
                                        .font(.caption.weight(.semibold))
                                        .foregroundStyle(.secondary)
                                }
                            }
                            .buttonStyle(.plain)
                        } else {
                            Text("novapro.net")
                        }
                    }
                }

                InteractSectionHeader(title: "Project")
                InteractConnectedCardSection {
                    InteractConnectedCardRow {
                        InteractSettingsRowLabel(
                            title: "Nova Productions",
                            subtitle: "Developed by Daniel Kravec. Interact started in July 2021 and supports an open API for developers.",
                            systemImage: "network",
                            showsChevron: false
                        )
                    }

                    InteractConnectedCardDivider()

                    InteractConnectedCardRow {
                        InteractSettingsRowLabel(
                            title: "Platforms",
                            subtitle: "iOS, iPadOS, and macOS",
                            systemImage: "ipad.and.iphone",
                            showsChevron: false
                        )
                    }
                }

                InteractSectionHeader(title: "Developer")
                InteractConnectedCardSection(tone: client.devMode?.isEnabled == true ? .selected : .normal) {
                    InteractActionRow(
                        title: client.devMode?.isEnabled == true ? "Disable Dev Mode" : "Enable Dev Mode",
                        subtitle: "Toggle local developer-only tools.",
                        systemImage: "hammer"
                    ) {
                        client.devMode = client.devModeManager.swapMode()
                        client.themeData.updateThemes(devMode: client.devMode ?? DevModeData(isEnabled: false))
                    }
                }
            }
            .interactScreenPadding()
        }
        .interactAppBackground()
        .navigationTitle("About")
        #if os(iOS)
        .navigationBarTitleDisplayMode(.inline)
        #endif
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

    private var websiteURL: URL? {
        URL(string: "https://novapro.net")
    }

    private func aboutRow(title: String, value: String) -> some View {
        InteractConnectedCardRow {
            HStack {
                Text(title)
                    .font(.subheadline)
                    .foregroundStyle(.secondary)

                Spacer(minLength: 8)

                Text(value)
                    .font(.subheadline.weight(.semibold))
            }
        }
    }
}
