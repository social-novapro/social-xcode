//
//  DevModeView.swift
//  social-apple
//
//  Created by Daniel Kravec on 2023-04-28.
//

import SwiftUI

struct DevModeView: View {
    @Binding var userTokenData: UserTokenData?
    @Binding var devMode: DevModeData?

    var body: some View {
        VStack {
            HStack {
                Text("Developer Mode is enabled, to disable go to About page")
            }
            .padding(20)
            VStack {
                Text("Your Tokens:")
                Text("userID: \(userTokenData?.userID ?? "not logged")")
                Text("userToken: \(userTokenData?.userToken ?? "not logged")")
                Text("accessToken: \(userTokenData?.accessToken ?? "not logged")")
            }
        }
        .navigationTitle("Dev Mode")
    }
}
