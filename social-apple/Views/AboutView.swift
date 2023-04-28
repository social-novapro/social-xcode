//
//  AboutView.swift
//  social-apple
//
//  Created by Daniel Kravec on 2023-04-22.
//

import SwiftUI

struct AboutView: View {
    @Binding var devMode: DevModeData?
    @State var devModeManager = DevModeHandler()

    var body: some View {
        VStack {
            VStack {
                Text("Interact is developed by Nova Productions")
                    .fontWeight(.heavy)
                Text("https://novapro.net")
                    .underline()
            }
            .padding(20)
            
            VStack {
                Text("About Interact")
                    .fontWeight(.heavy)
                Text("Interact is a social network, started in July 2021")
                Text("Interact has an open API, letting anyone develop for it")
                
            }
            .padding(20)

            VStack {
                if (devMode?.isEnabled == true) {
                    Text("Disable DevMode")
                        .fontWeight(.heavy)
                }
                else {
                    Text("Enable DevMode")
                        .fontWeight(.heavy)
                }
                Button(action: {
                    devMode = devModeManager.swapMode()
                }) {
                    Text("Dev Mode")
                }
            }
            .padding(20)

        }
        .padding(20)
        .navigationTitle("About Interact")
    }
}
