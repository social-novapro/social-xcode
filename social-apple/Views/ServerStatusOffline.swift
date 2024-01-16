//
//  ServerStatusOffline.swift
//  social-apple
//
//  Created by Daniel Kravec on 2024-01-16.
//

import SwiftUI

struct ServerStatusOffline: View {
    @ObservedObject var client:ApiClient
    @State var checkingStatus: Bool = false
    @State var stillOffline: Bool = false
    
    var body: some View {
        VStack {
            Spacer()
            Text("Interact Server Offline!")
            Spacer()
            Text("Sorry for the inconvince.")
            Text("Please come back again later.")
            
            if (checkingStatus==true) {
                if (stillOffline) {
                    Text("Still Offline")
                } else {
                    Text("Checking Status")
                    Text("If no result, restart app.")
                }
            }
            Button(action: {
                checkingStatus=true
                client.hapticPress()
                client.checkServerStatus()
                self.stillOffline = true
            }) {
                Text("Check Status")
                    .padding(15)
                    .cornerRadius(20)
                    .overlay(
                        RoundedRectangle(cornerRadius: 20)
                            .stroke(Color.accentColor, lineWidth: 3)
                    )
            }
            Spacer()
        }
        .navigationTitle("Interact Offline")
        .background(.background)
    }
}
