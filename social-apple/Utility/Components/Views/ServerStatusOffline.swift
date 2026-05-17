//
//  ServerStatusOffline.swift
//  social-apple
//
//  Created by Daniel Kravec on 2024-01-16.
//

import SwiftUI

struct ServerStatusOffline: View {
    @ObservedObject var client: Client
    @State var checkingStatus: Bool = false
    @State var stillOffline: Bool = false
    
    var body: some View {
        VStack {
            Spacer(minLength: 24)

            VStack(spacing: 18) {
                Image(systemName: "wifi.exclamationmark")
                    .font(.system(size: 44, weight: .semibold))
                    .foregroundStyle(.secondary)

                VStack(spacing: 6) {
                    Text("Interact Server Offline")
                        .font(.title2.weight(.semibold))
                    Text("Sorry for the inconvenience. Please come back again later.")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                        .multilineTextAlignment(.center)
                }

                if checkingStatus {
                    HStack(spacing: 8) {
                        if !stillOffline {
                            ProgressView()
                        }

                        Text(stillOffline ? "Still offline" : "Checking status...")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                }

                Button(action: checkStatus) {
                    HStack(spacing: 8) {
                        if checkingStatus && !stillOffline {
                            ProgressView()
                        }
                        Text(checkingStatus ? "Checking..." : "Check Status")
                    }
                    .frame(maxWidth: .infinity)
                }
                .buttonStyle(.borderedProminent)
                .disabled(checkingStatus && !stillOffline)
            }
            .padding(18)
            .interactCardSurface()

            Spacer(minLength: 24)
        }
        .navigationTitle("Interact Offline")
        .interactScreenPadding(maxWidth: 420)
        .interactAppBackground()
    }

    private func checkStatus() {
        checkingStatus = true
        stillOffline = false
        client.hapticPress()
        client.checkServerStatus()

        DispatchQueue.main.asyncAfter(deadline: .now() + 1.2) {
            if client.serverOffline {
                stillOffline = true
            }
            checkingStatus = false
        }
    }
}
