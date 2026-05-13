//
//  BasicSettings.swift
//  social-apple
//
//  Created by Daniel Kravec on 2024-01-14.
//

import SwiftUI

struct BasicSettings: View {
    @ObservedObject var client: Client
    @ObservedObject var feedPosts: FeedPosts
    @State var adminErrorFeed: AdminErrorFeed = AdminErrorFeed(client: Client())

    @State var enabledDevMode:Bool
    @State var enabledHaptic:Bool
    @State var runningDebugChecks: Bool = false
    @State var debugReport: DebugContractCheckReport?
    
    init(client: Client, feedPosts: FeedPosts) {
        self.client = client;
        self.feedPosts = feedPosts
        self.enabledDevMode = client.devMode?.isEnabled ?? false;
        self.enabledHaptic = client.haptic?.isEnabled ?? true;
    }
    
    var body: some View {
        ScrollView {
            LazyVStack(alignment: .leading, spacing: 12) {
                preferencesSection
                appSection
                developerSection
            }
            .interactScreenPadding()
        }
        .interactAppBackground()
        .onChange(of: enabledDevMode) { newValue in
            client.devMode = client.devModeManager.swapMode()
            client.themeData.updateThemes(devMode: client.devMode ?? DevModeData(isEnabled: false))
        }
        #if os(iOS)
        .onChange(of: enabledHaptic) { newValue in
            client.haptic = client.hapticModeManager.swapMode()
        }
        #endif
        .navigationTitle("Settings")
    }
    
    private var preferencesSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            InteractSectionHeader(
                title: "Preferences",
                subtitle: "Local display options for this account."
            )
            
            InteractConnectedCardSection(tone: .selected) {
                InteractConnectedCardRow {
                    appearancePickerRow
                }
                
                InteractConnectedCardDivider(leadingInset: 56)
                
                InteractConnectedCardRow {
                    designPickerRow
                }
            }
        }
    }
    
    private var appSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            InteractSectionHeader(title: "App", subtitle: "Common app navigation and device preferences.")
            
            InteractConnectedCardSection {
                #if os(iOS)
                InteractConnectedCardRow {
                    Toggle(isOn: $enabledHaptic) {
                        InteractSettingsRowLabel(
                            title: "Haptics",
                            subtitle: "Currently \(client.haptic?.isEnabled == true ? "enabled" : "disabled").",
                            systemImage: "hand.tap",
                            showsChevron: false
                        )
                    }
                }
                
                InteractConnectedCardDivider(leadingInset: 56)
                #endif
                
                InteractNavigationRow(
                    title: "Search",
                    subtitle: "Change your default search algorithm.",
                    systemImage: "magnifyingglass"
                ) {
                    SearchSettingPage(client: client)
                }
                
                InteractConnectedCardDivider(leadingInset: 56)
                
                InteractNavigationRow(
                    title: "Connected Accounts",
                    subtitle: "Add, switch, and log out of saved accounts.",
                    systemImage: "person.2"
                ) {
                    AccountsView(client: client, feedPosts: feedPosts)
                }
                
                InteractConnectedCardDivider(leadingInset: 56)
                
                InteractNavigationRow(
                    title: "Notifications",
                    subtitle: "Register this device and manage push settings.",
                    systemImage: "bell.badge"
                ) {
                    PushNotifications(client: client)
                }
            }
        }
    }
    
    private var developerSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            InteractSectionHeader(
                title: "Developer",
                subtitle: "Debug tools and developer-only account options."
            )
            
            InteractConnectedCardSection(tone: client.devMode?.isEnabled == true ? .destructive : .normal) {
                InteractConnectedCardRow {
                    Toggle(isOn: $enabledDevMode) {
                        InteractSettingsRowLabel(
                            title: "Dev Mode",
                            subtitle: "Currently \(client.devMode?.isEnabled == true ? "enabled" : "disabled").",
                            systemImage: "hammer",
                            showsChevron: false
                        )
                    }
                }
                
                InteractConnectedCardDivider(leadingInset: 56)
                
                InteractActionRow(
                    title: runningDebugChecks ? "Running Contract Debug Tests..." : "Run Contract Debug Tests",
                    subtitle: "Check local request and response contracts.",
                    systemImage: "play.circle"
                ) {
                    runContractChecks()
                }
                .disabled(runningDebugChecks)
                
                if let debugReport {
                    InteractConnectedCardDivider(leadingInset: 56)
                    
                    InteractConnectedCardRow {
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Contract checks: \(debugReport.passedCount)/\(debugReport.results.count) passed")
                                .font(.headline)
                            
                            ForEach(debugReport.results) { result in
                                HStack(spacing: 8) {
                                    Text(result.passed ? "PASS" : "FAIL")
                                        .font(.caption.weight(.semibold))
                                        .foregroundStyle(result.passed ? Color.green : Color.red)
                                    Text(result.name)
                                        .font(.caption)
                                    Spacer()
                                }
                            }
                        }
                    }
                }
                
                InteractConnectedCardDivider(leadingInset: 56)
                
                InteractNavigationRow(
                    title: "Developer Settings",
                    subtitle: "Manage developer tokens and connected apps.",
                    systemImage: "curlybraces"
                ) {
                    DeveloperSettingsView(client: client)
                }
                
                InteractConnectedCardDivider(leadingInset: 56)
                
                InteractNavigationRow(
                    title: "Admin Issues",
                    subtitle: "Review backend error reports.",
                    systemImage: "exclamationmark.triangle"
                ) {
                    AdminErrorView(client: client, adminErrorFeed: adminErrorFeed)
                }
            }
        }
    }
    
    private var appearancePickerRow: some View {
        HStack(spacing: 12) {
            Image(systemName: "circle.lefthalf.filled")
                .foregroundStyle(.secondary)
            
            VStack(alignment: .leading, spacing: 2) {
                Text("Appearance")
                Text("Use system, light, or dark mode.")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
            
            Spacer(minLength: 12)
            
            Picker(
                "Appearance",
                selection: Binding(
                    get: { client.appearancePreference },
                    set: { client.setAppearancePreference($0) }
                )
            ) {
                ForEach(InteractAppearancePreference.allCases) { preference in
                    Text(preference.title).tag(preference)
                }
            }
            .pickerStyle(.menu)
            .labelsHidden()
        }
    }
    
    private var designPickerRow: some View {
        HStack(spacing: 12) {
            Image(systemName: "square.stack.3d.up")
                .foregroundStyle(.secondary)
            
            VStack(alignment: .leading, spacing: 2) {
                Text("Design")
                Text("Choose the original app design or the new design pass.")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
            
            Spacer(minLength: 12)
            
            Picker(
                "Design",
                selection: Binding(
                    get: { client.designPreference },
                    set: { client.setDesignPreference($0) }
                )
            ) {
                ForEach(InteractDesignPreference.allCases) { preference in
                    Text(preference.title).tag(preference)
                }
            }
            .pickerStyle(.menu)
            .labelsHidden()
        }
    }
    
    private func runContractChecks() {
        client.hapticPress()
        runningDebugChecks = true

        DispatchQueue.global(qos: .userInitiated).async {
            let report = DebugHarness.runContractBaselineChecks()
            DispatchQueue.main.async {
                debugReport = report
                runningDebugChecks = false
            }
        }
    }
}


struct SearchSettingPage : View {
    @ObservedObject var client: Client
    @State var searchSetting: SearchSettingResponse?
    @State var ready: Bool = false;
    @State var currentSetting: String? = "v1"

    var body : some View {
        ScrollView {
            LazyVStack(alignment: .leading, spacing: 12) {
                if (self.ready == false) {
                    InteractConnectedCardSection {
                        InteractConnectedCardRow {
                            HStack(spacing: 10) {
                                ProgressView()
                                Text("Loading search settings...")
                                    .foregroundStyle(.secondary)
                            }
                        }
                    }
                } else {
                    InteractSectionHeader(
                        title: "Search Algorithm",
                        subtitle: "Change the default search algorithm used by the app."
                    )
                    
                    InteractConnectedCardSection {
                        InteractConnectedCardRow {
                            InteractSettingsRowLabel(
                                title: "Current Search",
                                subtitle: currentSetting ?? "Unknown",
                                systemImage: "magnifyingglass.circle",
                                showsChevron: false
                            )
                        }
                    }

                    InteractSectionHeader(title: "Options")

                    ForEach (self.searchSetting?.possibleSearch ?? []) { searchType in
                        InteractConnectedCardSection(tone: searchType.name == self.searchSetting?.currentSearch.preferredSearch ? .selected : .normal) {
                            Button {
                                client.api.search.changeSearchSetting(newSearch: searchType.name) { result in
                                    print("change setting")
                                    switch result {
                                    case .success(let results):
                                        self.searchSetting = results
                                        for searchType in self.searchSetting?.possibleSearch ?? [] {
                                            if (searchType.name == self.searchSetting?.currentSearch.preferredSearch) {
                                                currentSetting = searchType.niceName
                                            }
                                        }
                                        self.ready = true
                                    case .failure(let error):
                                        print("Error: \(error.localizedDescription)")
                                    }
                                }
                            } label: {
                                InteractConnectedCardRow {
                                    InteractSettingsRowLabel(
                                        title: searchType.niceName,
                                        subtitle: "\(searchType.name) - \(searchType.description)",
                                        systemImage: "slider.horizontal.3",
                                        showsChevron: false
                                    )
                                }
                            }
                            .buttonStyle(.plain)
                        }
                    }
                }
            }
            .interactScreenPadding()
        }
        .interactAppBackground()
        .onAppear(perform: loadSearchSettings)
        .navigationTitle("Search Setting")
    }
    
    private func loadSearchSettings() {
        guard ready == false else {
            return
        }
        
        client.api.search.searchSetting() { result in
            print("search setting request")
            switch result {
            case .success(let results):
                self.searchSetting = results
                for searchType in self.searchSetting?.possibleSearch ?? [] {
                    if (searchType.name == self.searchSetting?.currentSearch.preferredSearch) {
                        currentSetting = searchType.niceName
                    }
                }
                
                self.ready = true
            case .failure(let error):
                print("Error: \(error.localizedDescription)")
            }
        }
    }
}
