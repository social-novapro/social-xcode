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

                VStack {
                    Toggle("Haptics", isOn: $enabledHaptic)
                    HStack {
                        Text("Haptics is currently: " + String(client.haptic?.isEnabled ?? true))
                        Spacer()
                    }
                }
                .padding(10)
            }
        }
        .onChange(of: enabledDevMode) { newValue in
            client.devMode = client.devModeManager.swapMode()
        }
        .onChange(of: enabledHaptic) { newValue in
            client.haptic = client.hapticModeManager.swapMode()
        }
        .padding(10)
        .navigationTitle("Basic Settings")
    }
}
