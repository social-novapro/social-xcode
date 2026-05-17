//
//  DeveloperSettingsView.swift
//  social-apple
//
//  Created by Daniel Kravec on 2024-01-16.
//

import SwiftUI

struct DeveloperSettingsView: View {
    @ObservedObject var client: Client
    @State var developerData: DeveloperResponseData?
    @State var loading: Bool = true
    @State var newApplications: [AppTokenData] = []
    @State var createdNewDev: Bool = false
    
    var body: some View {
        ScrollView {
            LazyVStack(alignment: .leading, spacing: 12) {
                if loading {
                    InteractConnectedCardSection {
                        InteractConnectedCardRow {
                            HStack(spacing: 10) {
                                ProgressView()
                                Text("Loading developer settings...")
                                    .foregroundStyle(.secondary)
                            }
                        }
                    }
                } else {
                    InteractSectionHeader(
                        title: "Developer Account",
                        subtitle: "Review your developer status and Interact application access."
                    )
                    InteractConnectedCardSection {
                        AccountStatusView(client: client, developerData: $developerData)
                    }

                    if let developerData {
                        if let developerToken = developerData.DeveloperToken {
                            InteractSectionHeader(title: "Developer Token")
                            DeveloperTokenView(client: client, developerToken: developerToken)
                        }

                        if developerData.AppTokens.isEmpty == false {
                            InteractSectionHeader(title: "Approved Applications")
                            ForEach(developerData.AppTokens) { appToken in
                                AppTokenView(client: client, appToken: appToken)
                            }
                        }

                        InteractSectionHeader(title: "Generate Application")
                        GenerateAppView(
                            client: client,
                            newApplications: $newApplications,
                            developerToken: developerTokenID(from: developerData)
                        )

                        if newApplications.isEmpty == false {
                            InteractSectionHeader(title: "New Applications")
                            ForEach(newApplications) { appToken in
                                AppTokenView(client: client, appToken: appToken)
                            }
                        }

                        if developerData.AppAccesses.isEmpty == false {
                            InteractSectionHeader(title: "Connected Applications")
                            ForEach(developerData.AppAccesses) { accessToken in
                                AccessTokenView(client: client, accessToken: accessToken)
                            }
                        }
                    }
                }
            }
            .interactScreenPadding()
        }
        .interactAppBackground()
        .navigationTitle("Developer Settings")
        .onAppear {
            client.api.developer.getDeveloperData() { result in
                print("api rquest login:")
                switch result {
                case .success(let newData):
                    self.developerData = newData
                    self.loading = false;
                case .failure(let error):
                    print("Error: \(error.localizedDescription)")
                    self.loading = false
                }
            }
        }
    }

    private func developerTokenID(from data: DeveloperResponseData) -> String {
        data.DeveloperToken?._id ?? ""
    }
}


struct GenerateAppView: View {
    @ObservedObject var client: Client
    @Binding var newApplications: [AppTokenData]
    @State var newApplicationName: String = ""
    @State var developerToken: String
    @State var created: Bool = false
    @State var failed: Bool = false
    
    var body: some View {
        InteractConnectedCardSection(tone: created ? .selected : failed ? .destructive : .normal) {
            if failed || created {
                InteractConnectedCardRow {
                    InteractSettingsRowLabel(
                        title: created ? "Created new application" : "Could not create application",
                        subtitle: created ? "The new app token is listed below." : "Check the application name and try again.",
                        systemImage: created ? "checkmark.circle" : "exclamationmark.triangle",
                        showsChevron: false
                    )
                }

                InteractConnectedCardDivider(leadingInset: 56)
            }

            InteractConnectedCardRow {
                InteractSettingsRowLabel(
                    title: "Generate New App Token",
                    subtitle: "Create an application token for an approved integration.",
                    systemImage: "key",
                    showsChevron: false
                )
            }

            InteractConnectedCardDivider(leadingInset: 56)

            InteractConnectedCardRow {
                TextField("Application Name", text: $newApplicationName)
                    .interactInputSurface()
            }

            InteractConnectedCardDivider(leadingInset: 56)

            InteractActionRow(
                title: "Generate Token",
                subtitle: newApplicationName.isEmpty ? "Enter an application name first." : newApplicationName,
                systemImage: "plus.circle"
            ) {
                guard newApplicationName.isEmpty == false else {
                    return
                }

                client.hapticPress()
                let newTokenReq = NewAppTokenReq(userdevtoken: developerToken, appname: newApplicationName)

                newApplicationName = ""

                client.api.developer.newAppToken(newAppToken: newTokenReq) { result in
                    switch result {
                    case .success(let appData):
                        print("Generated Token")
                        newApplications.append(appData)
                        created = true
                        failed = false

                    case .failure(let error):
                        print("Error: \(error)")
                        failed = true
                        created = false
                        }
                }
            }
        }
    }
}

struct DeveloperTokenView: View {
    @ObservedObject var client: Client
    @State var developerToken: DeveloperTokenData
    @State var copied: Bool = false

    var body: some View {
        InteractConnectedCardSection(tone: copied ? .selected : .normal) {
            InteractConnectedCardRow {
                HStack {
                    InteractSettingsRowLabel(
                        title: "Developer Token",
                        subtitle: copied ? "Copied token" : "Tap token text to reveal or copy.",
                        systemImage: "key.horizontal",
                        showsChevron: false
                    )
                    HiddenText(text: developerToken._id ?? "")
                }
            }

            InteractConnectedCardDivider(leadingInset: 56)

            InteractConnectedCardRow {
                InteractSettingsRowLabel(
                    title: developerToken.premium == true ? "Premium Developer Account" : "Regular Developer Account",
                    subtitle: developerToken.creationTimestamp.map { "Created " + int64TimeFormatter(timestamp: $0) } ?? "Unknown creation date",
                    systemImage: "person.badge.key",
                    showsChevron: false
                )
            }

            InteractConnectedCardDivider(leadingInset: 56)

            InteractActionRow(
                title: copied ? "Copied Token" : "Copy Developer Token",
                subtitle: "Copy the developer token to the clipboard.",
                systemImage: copied ? "checkmark.circle" : "doc.on.doc"
            ) {
                #if os(iOS)
                UIPasteboard.general.string = self.developerToken._id ?? "failed"
                self.copied = true
                #endif
            }
        }
    }
}

struct AccountStatusView: View {
    @ObservedObject var client: Client
    @Binding var developerData: DeveloperResponseData?


    var body: some View {
        VStack(spacing: 0) {
            if developerData?.developer != true {
                InteractConnectedCardRow {
                    InteractSettingsRowLabel(
                        title: "Not a developer",
                        subtitle: "Developer signup is not available here yet.",
                        systemImage: "person.crop.circle.badge.questionmark",
                        showsChevron: false
                    )
                }

                InteractConnectedCardDivider(leadingInset: 56)
            } else {
                InteractConnectedCardRow {
                    InteractSettingsRowLabel(
                        title: "Developer Account",
                        subtitle: "You have an Interact Developer Account.",
                        systemImage: "checkmark.seal",
                        showsChevron: false
                    )
                }

                InteractConnectedCardDivider(leadingInset: 56)
            }

            InteractConnectedCardRow {
                InteractSettingsRowLabel(
                    title: "\(developerData?.AppTokens.count ?? 0) Approved Applications",
                    subtitle: "\(developerData?.AppAccesses.count ?? 0) connected applications",
                    systemImage: "app.connected.to.app.below.fill",
                    showsChevron: false
                )
            }
        }
    }
}

struct AppTokenView: View {
    @ObservedObject var client: Client
    @State var appToken: AppTokenData
    @State var copied: Bool = false
    
    var body: some View {
        InteractConnectedCardSection(tone: copied ? .selected : .normal) {
            InteractConnectedCardRow {
                InteractSettingsRowLabel(
                    title: appToken.appName ?? "Unknown App Name",
                    subtitle: appToken.creationTimestamp.map { "Created " + int64TimeFormatter(timestamp: $0) } ?? "Unknown creation date",
                    systemImage: "app.badge",
                    showsChevron: false
                )
            }

            InteractConnectedCardDivider(leadingInset: 56)

            InteractConnectedCardRow {
                HStack {
                    InteractSettingsRowLabel(
                        title: "\(appToken.APIUses ?? 0) API Uses",
                        subtitle: "Tap token text to reveal.",
                        systemImage: "chart.bar",
                        showsChevron: false
                    )
                    HiddenText(text: self.appToken._id)
                }
            }

            InteractConnectedCardDivider(leadingInset: 56)

            InteractActionRow(
                title: copied ? "Copied Token" : "Copy App Token",
                subtitle: "Copy this application token to the clipboard.",
                systemImage: copied ? "checkmark.circle" : "doc.on.doc"
            ) {
                #if os(iOS)
                UIPasteboard.general.string = self.appToken._id
                self.copied = true
                #endif
            }
        }
    }
}

struct AccessTokenView: View {
    @ObservedObject var client: Client
    @State var accessToken: AppAccessesData

    var body: some View {
        InteractConnectedCardSection {
            InteractConnectedCardRow {
                InteractSettingsRowLabel(
                    title: "Connected Application",
                    subtitle: accessToken.creationTimestamp.map { "Connected " + int64TimeFormatter(timestamp: $0) } ?? "Unknown connection date",
                    systemImage: "link",
                    showsChevron: false
                )
            }

            InteractConnectedCardDivider(leadingInset: 56)

            InteractConnectedCardRow {
                HStack {
                    InteractSettingsRowLabel(
                        title: "Access Token",
                        subtitle: "Tap token text to reveal.",
                        systemImage: "lock.open",
                        showsChevron: false
                    )
                    HiddenText(text: self.accessToken._id ?? "Unknown")
                }
            }

            InteractConnectedCardDivider(leadingInset: 56)

            InteractConnectedCardRow {
                HStack {
                    InteractSettingsRowLabel(
                        title: "Using App Token",
                        subtitle: "Tap token text to reveal.",
                        systemImage: "key",
                        showsChevron: false
                    )
                    HiddenText(text: self.accessToken.appToken ?? "Unknown")
                }
            }
       }
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
