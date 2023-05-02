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
    @State var devModeManager = DevModeHandler()
    
    @State var userLoginResponse: UserLoginResponse?
    @State var userTokens:UserTokenData?
    
    @State var userTokensLoaded:Bool = false;
    @State var pageLoading:Bool = true;
    @State var devMode:DevModeData? = DevModeData(isEnabled: false);
    
    var body: some View {
        NavigationView {
            List {
                // when user is logged in
                if (userTokensLoaded) {
                    VStack {
                        NavigationLink {
                            FeedPage(userTokenData: $userTokens, devMode: $devMode)
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
                            LogoutView(userTokenData: $userTokens, devMode: $devMode, userTokensLoaded: $userTokensLoaded)
                        } label: {
                            Text("Logout")
                        }
                    }                
                }
                // when user isnt logged in
                else {
                    VStack {
                        NavigationLink {
                            BeginPage(userTokenData: $userTokens, devMode: $devMode, userTokensLoaded: $userTokensLoaded)
                        } label: {
                            Text("Begin")
                        }
                    }
                }
                
                // both
                if (devMode?.isEnabled == true) {
                    VStack {
                        NavigationLink {
                            DevModeView(userTokenData: $userTokens, devMode: $devMode)
                        } label: {
                            Text("DevMode")
                        }
                    }
                }
                VStack {
                    NavigationLink {
                        AboutView(devMode: $devMode)
                    } label: {
                        Text("About")
                    }
                }
                VStack {
                    NavigationLink {
                        AnalyticsView() // could pass devmode
                    } label: {
                        Text("Analytics")
                    }
                }
            }

            if (userTokensLoaded) {
                FeedPage(userTokenData: $userTokens, devMode: $devMode)
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
            devMode = devModeManager.getDevMode()
            print ("devMode: \(devMode!)")
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
