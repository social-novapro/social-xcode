//
//  BasicSettings.swift
//  social-apple
//
//  Created by Daniel Kravec on 2024-01-14.
//

import SwiftUI

struct BasicSettings: View {
    @ObservedObject var client: ApiClient

    @State var enabledDevMode:Bool
    @State var enabledHaptic:Bool
    @State var searchSettingOpen:Bool = false;
    @State var feedSettingOpen:Bool = false;
    
    init(client: ApiClient) {
        self.client = client;
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
                Button(action: {
                    client.hapticPress()
                    self.searchSettingOpen = true
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
            }
        }
        .onChange(of: enabledDevMode) { newValue in
            client.devMode = client.devModeManager.swapMode()
        }
        #if os(iOS)
        .onChange(of: enabledHaptic) { newValue in
            client.haptic = client.hapticModeManager.swapMode()
        }
        #endif
        .navigationDestination(isPresented: $searchSettingOpen) {
            SearchSettingPage(client: client)
        }

        .padding(10)
        .navigationTitle("Basic Settings")
    }
}


struct SearchSettingPage : View {
    @ObservedObject var client: ApiClient
    @State var searchSetting: SearchSettingResponse?
    @State var ready: Bool = false;
    @State var currentSetting: String? = "v1"

    var body : some View {
        VStack {
            if (self.ready == false) {
                Text("Loading...")
                    .onAppear(perform: {
                        client.search.searchSetting() { result in
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
                                client.search.changeSearchSetting(newSearch: searchType.name) { result in
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
