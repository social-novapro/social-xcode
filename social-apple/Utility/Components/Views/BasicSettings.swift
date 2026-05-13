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
    @State var subSettings:Bool = false;
    @State var settingsTab:Int64 = 0;
    @State var runningDebugChecks: Bool = false
    @State var debugReport: DebugContractCheckReport?
    
    init(client: Client, feedPosts: FeedPosts) {
        self.client = client;
        self.feedPosts = feedPosts
        self.enabledDevMode = client.devMode?.isEnabled ?? false;
        self.enabledHaptic = client.haptic?.isEnabled ?? true;
    }
    
    var body: some View {
        VStack {
            VStack {
                HStack {
                    Text("Interact Settings")
                    Spacer()
                }
                HStack {
                    Text("Here you can change a few application settings, some are local, and some are site wide.")
                    Spacer()
                }
            }
            .padding(10)
            
            ScrollView {
                VStack {
                    Toggle("DevMode", isOn: $enabledDevMode)
                    HStack {
                        Text("DevMode is currently: " + String(client.devMode?.isEnabled ?? false))
                        Spacer()
                    }

                    Button(action: {
                        client.hapticPress()
                        runningDebugChecks = true

                        DispatchQueue.global(qos: .userInitiated).async {
                            let report = DebugHarness.runContractBaselineChecks()
                            DispatchQueue.main.async {
                                debugReport = report
                                runningDebugChecks = false
                            }
                        }
                    }) {
                        HStack {
                            Text(runningDebugChecks ? "Running contract debug tests..." : "Run Contract Debug Tests")
                            Spacer()
                            Image(systemName: "play.circle")
                        }
                    }
                    .buttonStyle(.plain)

                    if let debugReport {
                        HStack {
                            Text("Contract checks: \(debugReport.passedCount)/\(debugReport.results.count) passed")
                            Spacer()
                        }

                        ForEach(debugReport.results) { result in
                            HStack {
                                Text(result.passed ? "PASS" : "FAIL")
                                    .foregroundStyle(result.passed ? Color.green : Color.red)
                                Text(result.name)
                                Spacer()
                            }
                        }
                    }

                }
                .padding(10)
                #if os(iOS)
                VStack {
                    Toggle("Haptics", isOn: $enabledHaptic)
                    HStack {
                        Text("Haptics is currently: " + String(client.haptic?.isEnabled ?? true))
                        Spacer()
                    }
                }
                .padding(10)
                #endif
                preferencesSection
                
                Button(action: {
                    client.hapticPress()
                    self.subSettings = true
                    self.settingsTab = 1
                }) {
                    VStack {
                        VStack {
                            HStack {
                                Text("Search")
                                Spacer()
                                Image(systemName: "arrow.forward.circle")
                            }
                            HStack {
                                Text("Press to open search settings.")
                                Spacer()
                            }
                        }
                    }
                }
                .buttonStyle(.plain)
                .padding(10)
                Button(action: {
                    client.hapticPress()
                    self.subSettings = true
                    self.settingsTab = 2
                }) {
                    VStack {
                        VStack {
                            HStack {
                                Text("Developer")
                                Spacer()
                                Image(systemName: "arrow.forward.circle")
                            }
                            HStack {
                                Text("Press to open developer settings.")
                                Spacer()
                            }
                        }
                    }
                }
                .buttonStyle(.plain)
                .padding(10)
                Button(action: {
                    client.hapticPress()
                    self.subSettings = true
                    self.settingsTab = 3
                }) {
                    VStack {
                        VStack {
                            HStack {
                                Text("Account")
                                Spacer()
                                Image(systemName: "arrow.forward.circle")
                            }
                            HStack {
                                Text("Press to open account settings.")
                                Spacer()
                            }
                        }
                    }
                }
                .buttonStyle(.plain)
                .padding(10)
                Button(action: {
                    client.hapticPress()
                    self.subSettings = true
                    self.settingsTab = 4
                }) {
                    VStack {
                        VStack {
                            HStack {
                                Text("Notifications")
                                Spacer()
                                Image(systemName: "arrow.forward.circle")
                            }
                            HStack {
                                Text("Press to open push notification settings.")
                                Spacer()
                            }
                        }
                    }
                }
                .buttonStyle(.plain)
                .padding(10)
                
                Button(action: {
                    client.hapticPress()
                    self.subSettings = true
                    self.settingsTab = 5
                }) {
                    VStack {
                        VStack {
                            HStack {
                                Text("Admin Issues")
                                Spacer()
                                Image(systemName: "arrow.forward.circle")
                            }
                            HStack {
                                Text("Press to open admin issues.")
                                Spacer()
                            }
                        }
                    }
                }
                .buttonStyle(.plain)
                .padding(10)
                
                VStack {
                    
                }
                .padding(20)
            }
            .padding(15)
            .interactCardSurface(
                tone: client.designPreference == .new ? .selected : .normal,
                cornerRadius: 20,
                lineWidth: 3,
                originalBackground: client.themeData.mainBackground,
                originalBorder: .accentColor
            )
            .padding(10)
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
        .navigationDestination(isPresented: $subSettings) {
            if (settingsTab==1) {
                SearchSettingPage(client: client)
            } else if (settingsTab==2) {
                DeveloperSettingsView(client: client)
            } else if (settingsTab==3) {
                AccountsView(client: client, feedPosts: feedPosts)
            } else if (settingsTab==4) {
                PushNotifications(client: client)
            } else if (settingsTab==5) {
                AdminErrorView(client: client, adminErrorFeed: adminErrorFeed)
            }
        }
        .padding(10)
        .navigationTitle("Settings")
    }
    
    private var preferencesSection: some View {
        Group {
            if client.designPreference == .new {
                InteractConnectedCardSection(tone: .selected) {
                    InteractConnectedCardRow {
                        appearancePickerRow
                    }
                    
                    InteractConnectedCardDivider(leadingInset: 56)
                    
                    InteractConnectedCardRow {
                        designPickerRow
                    }
                }
            } else {
                VStack(spacing: 12) {
                    appearancePickerRow
                    designPickerRow
                }
                .padding(10)
            }
        }
        .padding(10)
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
}


struct SearchSettingPage : View {
    @ObservedObject var client: Client
    @State var searchSetting: SearchSettingResponse?
    @State var ready: Bool = false;
    @State var currentSetting: String? = "v1"

    var body : some View {
        VStack {
            if (self.ready == false) {
                Text("Loading...")
                    .onAppear(perform: {
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
                    })
            } else {
                VStack {
                    ScrollView {
                        HStack {
                            Text("Change your default search algorithm")
                            Spacer()
                        }
                        
                        HStack {
                            Text("Current default search is:")
                            Text(currentSetting ?? "Unknown")
                            Spacer()

                        }

                        ForEach (self.searchSetting?.possibleSearch ?? []) { searchType in
                            Button(action: {
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
                            }) {
                                HStack {
                                    VStack {
                                        HStack {
                                            Text(searchType.description)
                                        }
                                        HStack {
                                            Text("\(searchType.name) - \(searchType.niceName)")
                                        }
                                    }
                                    Spacer()
                                }
                            }
                            .padding(15)
                            .background(client.devMode?.isEnabled == true ? Color.red : Color.clear)
                            .cornerRadius(20)
                            .overlay(
                                RoundedRectangle(cornerRadius: 20)
                                    .stroke(Color.accentColor, lineWidth: 3)
                            )
                            .padding(10)
                        }
                    }
                }
                Spacer()
            }
            
        }
        .padding(10)
        .navigationTitle("Search Setting")
    }
}
