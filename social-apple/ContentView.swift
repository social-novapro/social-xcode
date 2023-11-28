//
//  ContentView.swift
//  social-apple
//
//  Created by Daniel Kravec on 2023-04-19.
//

import SwiftUI
import CoreData

struct ContentView: View {
//    @ObservedObject var websocket = LiveChatWebSocket()
    @State var client = ApiClient()
    /*
     takes over 
     - userTokenManager
     - userLoginresponse
     - userTokens
     - userTokensLoaded (maybe)
     */
    
    @State var userTokenManager = UserTokenHandler()
    @State var devModeManager = DevModeHandler()
    @State var currentNavigationManager = CurrentNavigationHandler()

    @State var userLoginResponse: UserLoginResponse?
    @State var userTokens:UserTokenData?
    
    @State var userTokensLoaded:Bool = false;
    @State var pageLoading:Bool = true;
    
    @State var devMode:DevModeData? = DevModeData(isEnabled: false);
    @State var currentNavigation:CurrentNavigationData? = CurrentNavigationData(selectedTab: 0)

    @Environment(\.horizontalSizeClass) private var horizontalSizeClass

    @ViewBuilder var body: some View {
        NavigationView {
            ZStack {
#if os(iOS)
                if horizontalSizeClass == .compact {
                    if (userTokensLoaded) {
                        if (self.currentNavigation?.selectedTab==0) {
                            FeedPage(client: $client, userTokenData: $userTokens, devMode: $devMode)
                        }
                        if (self.currentNavigation?.selectedTab==1) {
                            AboutView(devMode: $devMode)
                        }
                        if (self.currentNavigation?.selectedTab==2) {
                            SideBarNavigation(
                                client: $client,
                                userTokenManager: $userTokenManager,
                                devModeManager: $devModeManager,
                                currentNavigationManager: $currentNavigationManager,
                                userLoginResponse: $userLoginResponse,
                                userTokens: $userTokens,
                                userTokensLoaded: $userTokensLoaded,
                                pageLoading: $pageLoading,
                                devMode: $devMode,
                                currentNavigation: $currentNavigation
                            )
                        }
                        if (self.currentNavigation?.selectedTab==3) {
                            DevModeView(userTokenData: $userTokens, devMode: $devMode)
                        }
                        if (self.currentNavigation?.selectedTab==4) {
                            LiveChatView(userTokenData: $userTokens)
                        }
                    } else {
                        LoginPage(client: $client, onDone: { userLoginResponseIn in
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
#endif
                VStack {
#if os(iOS)
                    if horizontalSizeClass != .compact {
                        SideBarNavigation(
                            client: $client,
                            userTokenManager: $userTokenManager,
                            devModeManager: $devModeManager,
                            currentNavigationManager: $currentNavigationManager,
                            userLoginResponse: $userLoginResponse,
                            userTokens: $userTokens,
                            userTokensLoaded: $userTokensLoaded,
                            pageLoading: $pageLoading,
                            devMode: $devMode,
                            currentNavigation: $currentNavigation
                        )
                    }
#endif
#if os(macOS)
                    SideBarNavigation(
                        client: $client,
                        userTokenManager: $userTokenManager,
                        devModeManager: $devModeManager,
                        currentNavigationManager: $currentNavigationManager,
                        userLoginResponse: $userLoginResponse,
                        userTokens: $userTokens,
                        userTokensLoaded: $userTokensLoaded,
                        pageLoading: $pageLoading,
                        devMode: $devMode,
                        currentNavigation: $currentNavigation
                    )
#endif
                }
            }
            if horizontalSizeClass != .compact {
                if (userTokensLoaded) {
                    FeedPage(client: $client, userTokenData: $userTokens, devMode: $devMode)
                } else {
                    LoginPage(client: $client, onDone: { userLoginResponseIn in
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
        }
#if os(iOS)
        .if(horizontalSizeClass == .compact) { view in
            view.overlay(
                AppTabNavigation(currentNavigation: $currentNavigation, devMode: $devMode)
                    .frame(height: 50)
                    .padding(.bottom, 8),
                alignment: .bottom
            )
            .navigationViewStyle(StackNavigationViewStyle())
        }
#endif
        .onAppear {
            devMode = devModeManager.getDevMode()
            print ("devMode: \(devMode!)")
            currentNavigation = currentNavigationManager.getCurrentNavigation()
            print ("page: \(currentNavigation?.selectedTab ?? -1)")
            userTokens = userTokenManager.getUserTokens()
            if (userTokens == nil) {
                print ("tokens NOT loaded at begin")
                self.pageLoading = false
            } else {
                print ("tokens loaded at begin")
                userTokensLoaded = true
                print("userTokens: .onAppear, else, BeginPage()")
                self.pageLoading = false
            }
        }
    }
}

extension View {
    @ViewBuilder func `if`<Content: View>(_ condition: Bool, content: (Self) -> Content) -> some View {
        if condition {
            content(self)
        } else {
            self
        }
    }
}

struct SideBarNavigation: View {
    @Binding var client: ApiClient
    
    @Binding var userTokenManager:UserTokenHandler
    @Binding var devModeManager:DevModeHandler
    @Binding var currentNavigationManager:CurrentNavigationHandler

    @Binding var userLoginResponse: UserLoginResponse?
    @Binding var userTokens:UserTokenData?
    
    @Binding var userTokensLoaded:Bool
    @Binding var pageLoading:Bool
    
    @Binding var devMode:DevModeData?
    @Binding var currentNavigation:CurrentNavigationData?
    
    var body: some View {
        List {
            // when user is logged in
            if (userTokensLoaded) {
                VStack {
                    NavigationLink {
                        FeedPage(client: $client, userTokenData: $userTokens, devMode: $devMode)
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
                        LogoutView(client: $client, userTokenData: $userTokens, devMode: $devMode, userTokensLoaded: $userTokensLoaded)
                    } label: {
                        Text("Logout")
                    }
                }
            }
            // when user isnt logged in
            else {
                VStack {
                    NavigationLink {
                        BeginPage(client: $client, userTokenData: $userTokens, devMode: $devMode, userTokensLoaded: $userTokensLoaded)
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
            VStack {
                NavigationLink {
                    secondaryAnalyticView() // could pass devmode
                } label: {
                    Text("Analytics2")
                }
            }
        }
        .navigationTitle("Interact")
    }
}

struct AppTabNavigation: View {
    @Binding var currentNavigation:CurrentNavigationData?
    @Binding var devMode: DevModeData?

    @State var currentNavigationManager = CurrentNavigationHandler()
    @State var expand = false

    var body: some View {
        HStack (alignment: .center) {
            Spacer(minLength: /*@START_MENU_TOKEN@*/0/*@END_MENU_TOKEN@*/)
            HStack {
                if !self.expand {
                    Button(action: {
                        withAnimation(.interactiveSpring(response: 0.45, dampingFraction: 0.6, blendDuration: 0.6)) {
                            self.expand.toggle()
                        }
                    }) {
                        Image(systemName: "arrow.left")
                            .font(.system(size: 22))
                            .foregroundColor(.accentColor).padding()
                    }
                }
                else {
                    Spacer(minLength: 5)
                    Button(action: {
                        currentNavigation = currentNavigationManager.switchTab(newTab: 0)
                    }) {
                        Image(systemName: "tray.2")
                            .font(.system(size: 22))
                            .foregroundColor(self.currentNavigation?.selectedTab == 0 ? .accentColor: .secondary)
                            .padding(.horizontal)
                    }
                    Spacer(minLength: 5)
                    Button(action: {
                        currentNavigation = currentNavigationManager.switchTab(newTab: 1)
                    }) {
                        Image(systemName: "info.circle")
                            .font(.system(size: 22))
                            .foregroundColor(self.currentNavigation?.selectedTab == 1 ? .accentColor: .secondary)
                            .padding(.horizontal)
                    }
                    Spacer(minLength: 5)
                    Button(action: {
                        currentNavigation = currentNavigationManager.switchTab(newTab: 2)
                    }) {
                        Image(systemName: "gear")
                            .font(.system(size: 22))
                            .foregroundColor(self.currentNavigation?.selectedTab == 2 ? .accentColor: .secondary)
                            .padding(.horizontal)
                    }
                    Spacer(minLength: 5)
                    if (devMode?.isEnabled == true) {
                        Button(action: {
                            currentNavigation = currentNavigationManager.switchTab(newTab: 3)
                        }) {
                            Image(systemName: "hammer")
                                .font(.system(size: 22))
                                .foregroundColor(self.currentNavigation?.selectedTab == 3 ? .accentColor: .secondary)
                                .padding(.horizontal)
                        }
                        Spacer(minLength: 5)
                    }
                    Spacer(minLength: 5)
                    Button(action: {
                        currentNavigation = currentNavigationManager.switchTab(newTab: 4)
                    }) {
                        Image(systemName: "bubble")
                            .font(.system(size: 22))
                            .foregroundColor(self.currentNavigation?.selectedTab == 4 ? .accentColor: .secondary)
                            .padding(.horizontal)
                    }
                    Button(action: {
                        withAnimation(.interactiveSpring(response: 0.45, dampingFraction: 0.6, blendDuration: 0.6)) {
                            self.expand.toggle()
                        }
                        
                    }) {
                        Image(systemName: "arrow.right")
                            .font(.system(size: 22))
                            .foregroundColor(.secondary).padding()
                    }
                    Spacer(minLength: /*@START_MENU_TOKEN@*/0/*@END_MENU_TOKEN@*/)
                }
            }
            .padding(.vertical, self.expand ? 10 : 10)
            .padding(.horizontal, self.expand ? 10 : 8)
            .background(.regularMaterial)
            .clipShape(Capsule())
            .padding(22)
            .onLongPressGesture {
                self.expand.toggle()
            }
//            .animation(.interactiveSpring(response: 0.45, dampingFraction: 0.6, blendDuration: 0.6))
        }
    }
}

struct TabButton: View {
    var buttonIcon = ""
    var text = ""
    var num = -1
    var isActive = false
    
    var body: some View {
        Image(systemName: buttonIcon)
            .font(.system(size: 22))
            .foregroundColor(isActive ? .accentColor:  .secondary)
            .padding(.horizontal)
    }
}
