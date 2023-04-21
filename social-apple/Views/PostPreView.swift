//
//  PostView.swift
//  social-apple
//
//  Created by Daniel Kravec on 2023-04-20.
//

import SwiftUI

struct PostPreView: View {
    @Binding var postData: PostData?
    @Binding var userData: UserData?

    var body: some View {
        Text(/*@START_MENU_TOKEN@*/"Hello, World!"/*@END_MENU_TOKEN@*/)
    }
}

struct PostContentArea: View {
    @Binding var postData: PostData?
    var body: some View {
        Text("hi")
    }
}

struct PostUserArea: View {
    @Binding var userData: UserData?

    var body: some View {
        Text("hi")
    }
}
