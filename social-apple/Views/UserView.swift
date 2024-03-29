//
//  UserView.swift
//  social-apple
//
//  Created by Daniel Kravec on 2023-04-19.
//

import SwiftUI

struct UserView: View {
    @ObservedObject var client: ApiClient    
    @State var userData: UserData?
    @State var isLoading:Bool = true
    
    var body: some View {
        VStack {
            if !isLoading {
                VStack {
                    Text("Your user")
                    Text(userData?.username ?? "Username")
                    Text(userData?.displayName ?? "displayname")
                }
                .background(.indigo)
            } else {
                Text("Loading")
            }
        }
        .navigationTitle("User View")
        .onAppear {
            client.users.getByID(userID: client.userTokens.userID) { result in
                switch result {
                case .success(let userData):
                    print("userData, UserView ")
                    print("Done")
                    self.userData = userData
                    self.isLoading = false
                case .failure(let error):
                    print("Error: \(error.localizedDescription)")
                }
            }
        }
    }
}
