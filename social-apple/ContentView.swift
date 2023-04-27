//
//  ContentView.swift
//  social-apple
//
//  Created by Daniel Kravec on 2023-04-19.
//

import SwiftUI
import CoreData

struct ContentView: View {
    @State var userTokenManager = UserTokenHandler()
    @State var userLoginResponse: UserLoginResponse?
    @State var userTokens:UserTokenData?
    @State var userTokensLoaded:Bool=false;
    @State var pageLoading:Bool=true;
    
    var body: some View {
        NavigationView {
            List {
                // when user is logged in
                if (userTokensLoaded) {
                    VStack {
                        NavigationLink {
                            FeedPage(userTokenData: $userTokens)
                        } label: {
                            Text("Feed")
                        }
                    }
                    VStack {
                        NavigationLink {
                            CreatePost(userTokenData: $userTokens)
                        } label: {
                            Text("Create Post")
                        }
                    }
                    VStack {
                        NavigationLink {
                            UserView(userTokenData: $userTokens)
                        } label: {
                            Text("Profile")
                        }
                    }
                    VStack {
                        NavigationLink {
                            LogoutView()
                        } label: {
                            Text("Logout")
                        }
                    }                
                }
                // when user isnt logged in
                else {
                    VStack {
                        NavigationLink {
                            BeginPage()
                        } label: {
                            Text("Begin")
                        }
                    }
                }
                // both
            
                VStack {
                    NavigationLink {
                        AboutView()
                    } label: {
                        Text("About")
                    }
                }
            }

            if (userTokensLoaded) {
                FeedPage(userTokenData: $userTokens)
            } else {
                LoginPage(onDone: { userLoginResponseIn in
                    userTokensLoaded = true;
                    self.userTokens = UserTokenData(
                        accessToken: userLoginResponseIn.accessToken,
                        userToken: userLoginResponseIn.userToken,
                        userID: userLoginResponseIn.userID
                     )
                    userTokenManager.saveUserTokens(userTokenData: self.userTokens!)
                    print("userresponsein")
                })
            }
        }
        .navigationTitle("Interact")
        .onAppear {
            userTokens = userTokenManager.getUserTokens()
            if (userTokens == nil) {
                print ("tokens NOT loaded at begin")
                self.pageLoading = false
            }
            else {
                print ("tokens loaded at begin")
                userTokensLoaded = true
                print("userTokens: .onAppear, else, BeginPage()")
                self.pageLoading = false
            }
       }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView().environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
    }
}
