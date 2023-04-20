//
//  UserView.swift
//  social-apple
//
//  Created by Daniel Kravec on 2023-04-19.
//

import SwiftUI

struct UserView: View {
    @Binding var userData: UserData?
    
    var body: some View {
        Text(userData?.username ?? "Username")
        Text(userData?.displayName ?? "displayname")
    }
}

//struct UserView_Previews: PreviewProvider {
//    let userData: UserData = {
//        _id: "1",
//        __v: "2",
//        username: "dan"
//    }
//
//    static var previews: some View {
//        UserView(userData: userData)
//    }
//}
