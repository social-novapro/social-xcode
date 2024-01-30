//
//  PostView.swift
//  social-apple
//
//  Created by Daniel Kravec on 2024-01-29.
//

import SwiftUI

struct PostView: View {
    @ObservedObject var client: ApiClient
    @Binding var feedData: AllPosts
    
    var body: some View {
        VStack {
            HStack {
                VStack {
                    Text(feedData.postData.content ?? "No content")
                        .foregroundColor(.secondary)
                        .lineLimit(100) // or set a specific number
                        .multilineTextAlignment(.leading) // or .center, .trailing
                }
                Spacer()
            }
        }
    }
}
