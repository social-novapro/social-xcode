//
//  Begin.swift
//  social-apple
//
//  Created by Daniel Kravec on 2023-04-19.
//

import SwiftUI

struct BeginPage: View {
    @State var userData: UserData?
    @State var userDataLoaded:Bool = false;
    
    var body: some View {
        NavigationView {

            VStack {
                Text("Hello, world!")
               
                if (!userDataLoaded) {
                    LoginPage(onDone: { userDataInput in
                        
                        self.userData = userDataInput
                        userDataLoaded = true;
                        print(userDataInput)
                    })
                } else {
                    UserView(userData: $userData)
                }
            }
            .navigationTitle("Begin")
            
        }
    }

}
