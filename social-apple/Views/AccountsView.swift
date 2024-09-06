//
//  AccountsView.swift
//  social-apple
//
//  Created by Daniel Kravec on 2024-01-17.
//

import SwiftUI

struct AccountsView: View {
    @ObservedObject var client: Client
    

    var body: some View {
        VStack {
            VStack {
                LeftText(text: "User Login")
                LeftText(text: "Sign into another account.")
            }
            .padding(15)
            .cornerRadius(20)
            .overlay(
                RoundedRectangle(cornerRadius: 20)
                    .stroke(Color.accentColor, lineWidth: 3)
            )
            
            VStack {
                LeftText(text: "Switch Login")
                LeftText(text: "Switch to another account.")
            }
            .padding(15)
            .cornerRadius(20)
            .overlay(
                RoundedRectangle(cornerRadius: 20)
                    .stroke(Color.accentColor, lineWidth: 3)
            )
            
            VStack {
                LeftText(text: "Sign Out")
                LeftText(text: "Open your sign out options.")
            }
            .padding(15)
            .cornerRadius(20)
            .overlay(
                RoundedRectangle(cornerRadius: 20)
                    .stroke(Color.accentColor, lineWidth: 3)
            )
        }
        .padding(10)
        .navigationTitle("Connected Accounts")
    }
}

struct LeftText: View {
    @State var text:String
    
    var body: some View {
        HStack {
            Text(text)
            Spacer()
        }
    }
}
