//
//  HomeView.swift
//  social-apple
//
//  Created by Daniel Kravec on 2023-04-19.
//

import SwiftUI

struct HomeView: View {
    /*
     look for tokens
     */
    @State private var userlogindata: UserLoginData
    
    var body: some View {
        Text(/*@START_MENU_TOKEN@*/"Hello, World!"/*@END_MENU_TOKEN@*/)
        LoginPage(onDone: { userData in
            print("Received data from subview: \(userData)")
        })
    }
}

/*
 .navigationDestination(
        for: AnimalGroup.ID.self
    ) { groupId in
        AnimalGroupView(groupId: groupId)
    }
 */
//struct HomeView_Previews: PreviewProvider {
//    static var previews: some View {
//        HomeView()
//    }
//}
