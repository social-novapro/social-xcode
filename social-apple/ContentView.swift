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
    @StateObject var client = ApiClient()
    /*
     takes over 
     - userTokenManager
     - userLoginresponse
     - userTokens
     - userTokensLoaded (maybe)
     */

    @State var pageLoading:Bool = true;
    
    @State var devMode:DevModeData? = DevModeData(isEnabled: false);
    @State var currentNavigation:CurrentNavigationData? = CurrentNavigationData(selectedTab: 0)

    @Environment(\.horizontalSizeClass) private var horizontalSizeClass

    @ViewBuilder var body: some View {
        NavigationView {
            ZStack {
#if os(iOS)
                if horizontalSizeClass == .compact {
                    if (client.loggedIn) {
                        if (client.navigation?.selectedTab==0) {
                            FeedPage(client: client)
                        }
                        if (client.navigation?.selectedTab==1) {
                            AboutView(client: client)
                        }
                        if (client.navigation?.selectedTab==2) {
                            SideBarNavigation(client: client)
                        }
                        if (client.navigation?.selectedTab==3) {
                            DevModeView(client: client)
                        }
                        if (client.navigation?.selectedTab==4) {
                            LiveChatView(client: client)
                        }
                    } else {
                        BeginPage(client: client)
                    }
                }
#endif
                VStack {
#if os(iOS)
                    if horizontalSizeClass != .compact {
                        SideBarNavigation(client: client)
                    }
#endif
#if os(macOS)
                    SideBarNavigation(client: client)
#endif
                }
            }
            if horizontalSizeClass != .compact {
                if (client.loggedIn) {
                    FeedPage(client: client)
                } else {
                    BeginPage(client: client)
                }
            }
        }
#if os(iOS)
        .if(horizontalSizeClass == .compact) { view in
            view.overlay(
                AppTabNavigation(client: client)
                    .frame(height: 50)
                    .padding(.bottom, 8),
                alignment: .bottom
            )
            .navigationViewStyle(StackNavigationViewStyle())
        }
#endif
        .onAppear {
            print ("devMode: \(devMode!)")
            print ("page: \(currentNavigation?.selectedTab ?? -1)")
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
    @ObservedObject var client: ApiClient
    
    var body: some View {
        List {
            // when user is logged in
            if (client.loggedIn) {
                VStack {
                    NavigationLink {
                        FeedPage(client: client)
                    } label: {
                        Text("Feed")
                    }
                }
                VStack {
                    NavigationLink {
                        CreatePost(client: client)
                    } label: {
                        Text("Create Post")
                    }
                }
                VStack {
                    NavigationLink {
                        UserView(client: client)
                    } label: {
                        Text("Profile")
                    }
                }
                VStack {
                    NavigationLink {
                        LogoutView(client: client)
                    } label: {
                        Text("Logout")
                    }
                }
            }
            // when user isnt logged in
            else {
                VStack {
                    NavigationLink {
                        BeginPage(client: client)
                    } label: {
                        Text("Begin")
                    }
                }
            }
            
            // both
            if (client.devMode?.isEnabled == true) {
                VStack {
                    NavigationLink {
                        DevModeView(client: client)
                    } label: {
                        Text("DevMode")
                    }
                }
            }
            VStack {
                NavigationLink {
                    AboutView(client: client)
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
    @ObservedObject var client: ApiClient
    @State var expand = false

    var body: some View {
        HStack (alignment: .center) {
            if (client.loggedIn == false) {
                EmptyView()
            }
            else {
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
                            client.navigation = client.navigationManager.switchTab(newTab: 0)
                        }) {
                            Image(systemName: "tray.2")
                                .font(.system(size: 22))
                                .foregroundColor(client.navigation?.selectedTab == 0 ? .accentColor: .secondary)
                                .padding(.horizontal)
                        }
                        Spacer(minLength: 5)
                        Button(action: {
                            client.navigation = client.navigationManager.switchTab(newTab: 1)
                        }) {
                            Image(systemName: "info.circle")
                                .font(.system(size: 22))
                                .foregroundColor(client.navigation?.selectedTab == 1 ? .accentColor: .secondary)
                                .padding(.horizontal)
                        }
                        Spacer(minLength: 5)
                        Button(action: {
                            client.navigation = client.navigationManager.switchTab(newTab: 2)
                        }) {
                            Image(systemName: "gear")
                                .font(.system(size: 22))
                                .foregroundColor(client.navigation?.selectedTab == 2 ? .accentColor: .secondary)
                                .padding(.horizontal)
                        }
                        Spacer(minLength: 5)
                        if (client.devMode?.isEnabled == true) {
                            Button(action: {
                                client.navigation = client.navigationManager.switchTab(newTab: 3)
                            }) {
                                Image(systemName: "hammer")
                                    .font(.system(size: 22))
                                    .foregroundColor(client.navigation?.selectedTab == 3 ? .accentColor: .secondary)
                                    .padding(.horizontal)
                            }
                            Spacer(minLength: 5)
                        }
                        Spacer(minLength: 5)
                        Button(action: {
                            client.navigation = client.navigationManager.switchTab(newTab: 4)
                        }) {
                            Image(systemName: "bubble")
                                .font(.system(size: 22))
                                .foregroundColor(client.navigation?.selectedTab == 4 ? .accentColor: .secondary)
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
            }
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
