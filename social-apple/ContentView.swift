//
//  ContentView.swift
//  social-apple
//
//  Created by Daniel Kravec on 2023-04-19.
//

import SwiftUI
import CoreData

struct ContentView: View {
    @StateObject var client = ApiClient()
    @ObservedObject var feedPosts: FeedPosts = FeedPosts(client: ApiClient())

    /*
     takes over 
     - userTokenManager
     - userLoginresponse
     - userTokens
     - userTokensLoaded (maybe)
     */

    @Environment(\.horizontalSizeClass) private var horizontalSizeClass
    
    init() {
        // INDEPENDANT CLIENT
        self.feedPosts.getFeed()
    }
    
    @ViewBuilder var body: some View {
        NavigationView {
            ZStack {
#if os(iOS)
                if horizontalSizeClass == .compact {
//                    NavigationStack {
                        if (client.loggedIn) {
                            switch client.navigation?.selectedTab {
                            case 0:
                                NavigationStack {
                                    FeedPage(client: client, feedPosts: feedPosts)
                                }
                            case 1:
                                NavigationStack {
                                    CreatePost(client: client)
                                }
                            case 2:
                                NavigationStack {
                                    SideBarNavigation(client: client, feedPosts: feedPosts)
                                }
                            case 3:
                                NavigationStack {
                                    DevModeView(client: client)
                                }
                            case 4:
                                NavigationStack {
                                    LiveChatView(client: client)
                                }
                            case 5:
                                NavigationStack {
                                    SearchView(client: client)
                                }
                            default:
                                NavigationStack {
                                    BeginPage(client: client)
                                }
                            }
                        } else {
                            NavigationStack {
                                BeginPage(client: client)
                            }
                        }
                }
#endif
                VStack {
#if os(iOS)
                    // Text("hello")
                      //  .background(Color(hex:0xf5bc53))
                    if horizontalSizeClass != .compact {
                        SideBarNavigation(client: client, feedPosts: feedPosts)
                    }
#endif
#if os(macOS)
                    SideBarNavigation(client: client, feedPosts: feedPosts)
#endif
#if os(visionOS)
                    SideBarNavigation(client: client, feedPosts: feedPosts)
                    
                    if (client.serverOffline == true) {
                        ServerStatusOffline(client: client)
                    } else if (client.loggedIn) {
                        NavigationStack {
                            FeedPage(client: client, feedPosts: feedPosts)
                        }
                    } else {
                        NavigationStack {
                            BeginPage(client: client)
                        }
                    }
#endif
                }
            }
#if os(iOS)
            .fullScreenCover(isPresented: $client.serverOffline, content: {
                ServerStatusOffline(client: client)
            })
#endif
            if horizontalSizeClass != .compact {
                if (client.serverOffline == true) {
                    ServerStatusOffline(client: client)
                } else if (client.loggedIn) {
                    NavigationStack {
                        FeedPage(client: client, feedPosts: feedPosts)
                    }
                } else {
                    NavigationStack {
                        BeginPage(client: client)
                    }
                }
            }
        }
#if os(iOS)
        .if(horizontalSizeClass == .compact) { view in
            view.overlay(
                AppTabNavigation(client: client)
                    .frame(height: 50)
                    .padding(.bottom, 25),
                alignment: .bottom
            )
          
            .navigationViewStyle(StackNavigationViewStyle())
        }
        
        .if(horizontalSizeClass == .compact) { view in
            view.overlay(
                IncomeNotificationView(client: client)
                    .frame(height: 50)
                    .padding(.top, 25),
                alignment: .top
            )
          
            .navigationViewStyle(StackNavigationViewStyle())
        }
#endif
        .onAppear {
            print("serveroffline \(client.serverOffline)")
            print ("devMode: \(client.devMode!)")
            print ("page: \(client.navigation?.selectedTab ?? -1)")
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

struct IncomeNotificationView: View {
    @ObservedObject var client: ApiClient
    @State var expand = false
    @State var newNotification = false
    @State var notificationBody = ""
    #if os(iOS)
    @UIApplicationDelegateAdaptor private var appDelegate: MyAppDelegate
    #endif

    var body: some View {
        VStack {
            if self.client.errorShow==true {
                HStack (alignment: .center) {
                    VStack {
                        Text("\(client.errorFound?.code ?? "Unknown Error Code")")
                        Text("\(client.errorFound?.msg ?? "An error occured")")
                    }
                    
                    Button(action: {
                        self.newNotification = false
                        self.notificationBody = ""
                    }, label: {
                        Image(systemName: "x.circle")
                            .font(.system(size: 22))
                    })
                }

                .padding(.vertical, self.expand ? 10 : 10)
                .padding(.horizontal, self.expand ? 10 : 8)
                .background(.regularMaterial)
                .clipShape(Capsule())
                .overlay(
                    RoundedRectangle(cornerRadius: 35)
                        .stroke(Color.accentColor, lineWidth: 2)
                )
                .padding(22)
                .background(client.devMode?.isEnabled == true ? Color.red : Color.clear)
                .onLongPressGesture {
                    self.newNotification.toggle()
                }
            }
#if os(iOS)
            if self.newNotification==true {
                HStack (alignment: .center) {
                    VStack {
                        Text("\(notificationBody)")
                    }
                    
                    Button(action: {
                        self.newNotification = false
                        self.notificationBody = ""
                    }, label: {
                        Image(systemName: "x.circle")
                            .font(.system(size: 22))
                    })
                }

                .padding(.vertical, self.expand ? 10 : 10)
                .padding(.horizontal, self.expand ? 10 : 8)
                .background(.regularMaterial)
                .clipShape(Capsule())
                .overlay(
                    RoundedRectangle(cornerRadius: 35)
                        .stroke(Color.accentColor, lineWidth: 2)
                )
                .padding(22)
                .background(client.devMode?.isEnabled == true ? Color.red : Color.clear)
                .onLongPressGesture {
                    self.newNotification.toggle()
                }
            }
    #endif
        }
        .onAppear {
            #if os(iOS)
            // Subscribe to changes in the MyAppDelegate
            NotificationCenter.default.addObserver(forName: NSNotification.Name("NotificationReceived"), object: nil, queue: nil) { notification in
                print("Received new message: \(notification)")
                self.notificationBody = notification.object as! String
                // Refresh the view when a notification is received
                self.newNotification = true
                print("App is in the foreground")
            }
            #endif
        }
    }
}

struct SideBarNavigation: View {
    @ObservedObject var client: ApiClient
    @ObservedObject var feedPosts: FeedPosts

    var body: some View {
        List {
            // when user is logged in
            if (client.loggedIn) {
                VStack {
                    NavigationLink {
                        FeedPage(client: client, feedPosts: feedPosts)
                    } label: {
                        Text("Feed")
                    }
                }
                VStack {
                    NavigationLink {
                        LiveChatView(client: client)
                    } label: {
                        Text("Chat")
                    }
                }
                VStack {
                    NavigationLink {
                        SearchView(client: client)
                    } label: {
                        Text("Search Interact")
                    }
                }
                VStack {
                    NavigationLink {
                        ProfileView(client: client, userData: client.userData)
                    } label: {
                        Text("Profile")
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
                        BasicSettings(client: client)
                    } label: {
                        Text("Settings")
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
                    AnalyticsView(client: client) // could pass devmode
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
//    @State var expand = false

    var body: some View {
        VStack {
            HStack (alignment: .center) {
                
                if (client.loggedIn == false) {
                    EmptyView()
                }
                else {
                    Spacer(minLength: /*@START_MENU_TOKEN@*/0/*@END_MENU_TOKEN@*/)
                    HStack {
                        if !(client.navigation?.expanded ?? false) {
                            Button(action: {
                                client.hapticPress()
                                withAnimation(.interactiveSpring(response: 0.45, dampingFraction: 0.6, blendDuration: 0.6)) {
                                    client.navigation = client.navigationManager.swapExpanded()
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
                                client.hapticPress()
                                client.navigation = client.navigationManager.switchTab(newTab: 0)
                            }) {
                                Image(systemName: "house")
                                    .font(.system(size: 22))
                                    .foregroundColor(client.navigation?.selectedTab == 0 ? .accentColor: .secondary)
                                    .padding(.horizontal)
                            }
                            Spacer(minLength: 5)
                            Button(action: {
                                client.hapticPress()
                                client.navigation = client.navigationManager.switchTab(newTab: 5)
                            }) {
                                Image(systemName: "magnifyingglass")
                                    .font(.system(size: 22))
                                    .foregroundColor(client.navigation?.selectedTab == 5 ? .accentColor: .secondary)
                                    .padding(.horizontal)
                            }
                            Spacer(minLength: 5)
                            Button(action: {
                                client.hapticPress()
                                client.navigation = client.navigationManager.switchTab(newTab: 2)
                            }) {
                                Image(systemName: "archivebox")
                                    .font(.system(size: 22))
                                    .foregroundColor(client.navigation?.selectedTab == 2 ? .accentColor: .secondary)
                                    .padding(.horizontal)
                            }
                            Spacer(minLength: 5)
                            if (client.devMode?.isEnabled == true) {
                                Button(action: {
                                    client.hapticPress()
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
                                client.hapticPress()
                                client.navigation = client.navigationManager.switchTab(newTab: 4)
                            }) {
                                Image(systemName: "bubble.left")
                                    .font(.system(size: 22))
                                    .foregroundColor(client.navigation?.selectedTab == 4 ? .accentColor: .secondary)
                                    .padding(.horizontal)
                            }
                            Button(action: {
                                client.hapticPress()
                                withAnimation(.interactiveSpring(response: 0.45, dampingFraction: 0.6, blendDuration: 0.6)) {
                                    client.navigation = client.navigationManager.swapExpanded()
                                }
                            }) {
                                Image(systemName: "arrow.right")
                                    .font(.system(size: 22))
                                    .foregroundColor(.secondary).padding()
                            }
                            Spacer(minLength: /*@START_MENU_TOKEN@*/0/*@END_MENU_TOKEN@*/)
                        }
                    }
                    .padding(.vertical, client.navigation?.expanded ?? false ? 10 : 10)
                    .padding(.horizontal, client.navigation?.expanded ?? false ? 10 : 8)
                    .background(.regularMaterial)
                    .clipShape(Capsule())
                    .overlay(
                        RoundedRectangle(cornerRadius: 35)
                            .stroke(Color.accentColor, lineWidth: 2)
                    )
                    .padding(22)
                    .background(client.devMode?.isEnabled == true ? Color.red : Color.clear)
                }
            }
        }
        Spacer()
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


extension Color {
    init(hex: Int, opacity: Double = 1.0) {
        let red = Double((hex & 0xff0000))
        let green = Double((hex & 0x00ff00))
        let blue = Double((hex & 0x0000ff))
        self.init(.sRGB, red: red, green: green, blue: blue, opacity: opacity)
    }
}
