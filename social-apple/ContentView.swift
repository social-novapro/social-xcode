//
//  ContentView.swift
//  social-apple
//
//  Created by Daniel Kravec on 2023-04-19.
//

import SwiftUI
import CoreData

struct ContentView: View {
    @StateObject var client = Client()
    @ObservedObject var feedPosts: FeedPosts = FeedPosts(client: Client())
    @Environment(\.horizontalSizeClass) private var horizontalSizeClass
    
    init() {
        // INDEPENDANT CLIENT
        self.feedPosts.getFeed()
    }
    
    var body: some View {
        Group {
#if os(iOS) || os(tvOS)
           if horizontalSizeClass == .compact {
               if #available(iOS 26, *) {
                   compactLayoutViewLiquidGlass(client: client, feedPosts: feedPosts, horizontalSizeClass: horizontalSizeClass)

               } else {
                   compactLayoutView(client: client, feedPosts: feedPosts, horizontalSizeClass: horizontalSizeClass)

               }
           } else {
               regularLayoutView(client: client, feedPosts: feedPosts, horizontalSizeClass: horizontalSizeClass)

           }
#elseif os(macOS)
            macLayoutView(client: client, feedPosts: feedPosts, horizontalSizeClass: horizontalSizeClass)

#elseif os(visionOS)
            visionLayoutView(client: client, feedPosts: feedPosts, horizontalSizeClass: horizontalSizeClass)

#endif
        }
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



struct compactLayoutViewLiquidGlass : View {
    @ObservedObject var client: Client
    @ObservedObject var feedPosts: FeedPosts
    @State var horizontalSizeClass: UserInterfaceSizeClass?
    @State var localSelected:Int16 = 0
    @State var searchText = ""
    
    var body: some View {
        VStack {
            if #available(iOS 26, *) {
                
                if (client.loggedIn) {
//                    NavigationStack {

                    TabView(selection: $localSelected) {
                        Tab("Home", systemImage: "house", value: 0) {
                            NavigationStack {
                                FeedPage(client: client, feedPosts: feedPosts)
                            }
                        }
                        Tab("System", systemImage: "archivebox", value: 2) {
                            NavigationStack {
                                SideBarNavigation(client: client, feedPosts: feedPosts, horizontalSizeClass: horizontalSizeClass)
                            }
                        }
                        if (client.devMode?.isEnabled == true) {
                            Tab("Debug", systemImage: "hammer", value: 3) {
                                NavigationStack {
                                    DevModeView(client: client)
                                }
                            }
                        }
                        Tab("Live Chat", systemImage: "bubble.left", value: 4) {
                            NavigationStack {
                                LiveChatView(client: client)
                            }
                        }
                        Tab("Search", systemImage: "magnifyingglass", value: 5, role: .search) {
                            NavigationStack {
                                SearchView(client: client)
                            }
                        }
                        
                    }
                } else {
                    NavigationStack {
                        BeginPage(client: client)
                    }
                }
            }
        }
        .onChange(of: localSelected, perform: {newvalue in
            client.hapticPress()
            client.navigation = client.navigationManager.switchTab(newTab: newvalue)
        })
        .onAppear() {
            localSelected = client.navigation?.selectedTab ?? 0
        }

    }
}

struct compactLayoutView : View {
    @ObservedObject var client: Client
    @ObservedObject var feedPosts: FeedPosts
    @State var horizontalSizeClass: UserInterfaceSizeClass?

    var body: some View {
        VStack {
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
                        SideBarNavigation(client: client, feedPosts: feedPosts, horizontalSizeClass: horizontalSizeClass)
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
        #if os(iOS)
        .fullScreenCover(isPresented: $client.serverOffline, content: {
            ServerStatusOffline(client: client)
        })
        #endif
        .onChange(of: client.loggedIn, perform: {newValue in
            self.feedPosts.newClient(client: client)
            self.feedPosts.getFeed()
        })
        .overlay(
            AppTabNavigation(client: client, localSelected: Int(client.navigation?.selectedTab ?? 0))
                .frame(height: 50)
                .padding(.bottom, 25),
            alignment: .bottom
        )
        #if os(iOS)
        .navigationViewStyle(StackNavigationViewStyle())
        .overlay(
            IncomeNotificationView(client: client)
                .frame(height: 50)
                .padding(.top, 25),
            alignment: .top
        )
        .navigationViewStyle(StackNavigationViewStyle())
        #endif

    }
}

struct regularLayoutView : View {
    @ObservedObject var client: Client
    @ObservedObject var feedPosts: FeedPosts
    @State var horizontalSizeClass: UserInterfaceSizeClass?

    
    var body: some View {
        NavigationSplitView {
            SideBarNavigation(client: client, feedPosts: feedPosts, horizontalSizeClass: horizontalSizeClass)
        } detail: {
            Group {
                if client.serverOffline {
                    ServerStatusOffline(client: client)
                } else if client.loggedIn || client.beginPageMode == 0 {
                    FeedPage(client: client, feedPosts: feedPosts)
                } else {
                    BeginPage(client: client)
                }
            }
            .onChange(of: client.loggedIn, perform: {newValue in
                print("changed client.loggedIn to \(newValue) group inside splitView")
            })

        }
        #if os(iOS) || os(tvOS)
        .fullScreenCover(isPresented: $client.serverOffline, content: {
            ServerStatusOffline(client: client)
        })
        .onChange(of: client.loggedIn, perform: {newValue in
            print("changed client.loggedIn to \(newValue) regularLayoutView")
            self.feedPosts.newClient(client: client)
            self.feedPosts.getFeed()
        })
        .overlay(
            IncomeNotificationView(client: client)
                .frame(height: 50)
                .padding(.top, 25),
            alignment: .top
        )
        .navigationViewStyle(StackNavigationViewStyle())
        #endif

    }
}

struct macLayoutView : View {
    @ObservedObject var client: Client
    @ObservedObject var feedPosts: FeedPosts
    @State var horizontalSizeClass: UserInterfaceSizeClass?

    @ViewBuilder var body: some View {
        NavigationView {
            VStack {
                SideBarNavigation(client: client, feedPosts: feedPosts,  horizontalSizeClass: horizontalSizeClass)
            }
            .onChange(of: client.loggedIn, perform: {newValue in
                self.feedPosts.newClient(client: client)
                self.feedPosts.getFeed()
            })
            if client.serverOffline {
                ServerStatusOffline(client: client)
            } else if client.loggedIn {
                FeedPage(client: client, feedPosts: feedPosts)
            } else {
                BeginPage(client: client)
            }
        }
    }
}

struct visionLayoutView : View {
    @ObservedObject var client: Client
    @ObservedObject var feedPosts: FeedPosts
    @State var horizontalSizeClass: UserInterfaceSizeClass?

    @ViewBuilder var body: some View {
        VStack {
            NavigationView {
                SideBarNavigation(client: client, feedPosts: feedPosts,  horizontalSizeClass: horizontalSizeClass)
                
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
    }
}

struct IncomeNotificationView: View {
    @ObservedObject var client: Client
    @State var expand = false
    @State var newNotification = false
    @State var notificationBody = ""
    
    #if os(iOS)
    @UIApplicationDelegateAdaptor private var appDelegate: MyAppDelegate
    #endif

    var body: some View {
        VStack {
            if $client.api.apiHelper.errorShow.wrappedValue == true {
                HStack (alignment: .center) {
                    VStack {
                        Text("\(client.api.apiHelper.errorFound.code)")
                        Text("\(client.api.apiHelper.errorFound.msg)")
                    }
                    
                    Button(action: {
                        DispatchQueue.main.async {
                            self.client.dismissError()
                            $client.api.apiHelper.errorShow.wrappedValue = false
                        }
                        print("pressed dismiss")
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
                .background(client.themeData.mainBackground)
                .onLongPressGesture {
                    DispatchQueue.main.async {
                        self.client.dismissError()
                    }
                }
            } /*else {
                VStack {
                    Text("\(client.api.apiHelper.errorFound.code)")
                    Text("\(client.api.apiHelper.errorFound.msg)")
                }
                
                Button(action: {
                    self.client.triggerError()
                    print("pressed error")
                }, label: {
                    Image(systemName: "plus.circle")
                        .font(.system(size: 22))
                })
            }*/
//            .onChange(of: self.client.api.apiHelper.errorShow) { _ in
//                print("chang")
//            }
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
                .background(client.themeData.mainBackground)
                .onLongPressGesture {
                    self.newNotification = false
                    self.notificationBody = ""
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
    @ObservedObject var client: Client
    @ObservedObject var feedPosts: FeedPosts
    @State var horizontalSizeClass: UserInterfaceSizeClass?

    var body: some View {
        List {
            // when user is logged in
            if (client.loggedIn) {
                if horizontalSizeClass != .compact {
                    VStack {
                        NavigationLink {
                            FeedPage(client: client, feedPosts: feedPosts)
                        } label: {
                            HStack {
                                Image(systemName: "house")
                                Text("Feed")
                            }
                        }
                    }
                    VStack {
                        NavigationLink {
                            LiveChatView(client: client)
                        } label: {
                            HStack {
                                Image(systemName: "bubble.left")
                                Text("Chat")
                            }
                        }
                    }
                    VStack {
                        NavigationLink {
                            SearchView(client: client)
                        } label: {
                            HStack {
                                Image(systemName: "magnifyingglass")
                                Text("Search")
                            }
                        }
                    }
                }
                
                VStack {
                    NavigationLink {
                        ProfileView(client: client, userData: client.userData, userID: client.userTokens.userID)
                    } label: {
                        HStack {
                            Image(systemName: "person")
                            Text("Profile")
                        }
                    }
                }
                VStack {
                    NavigationLink {
                        CreatePost(client: client)
                    } label: {
                        HStack {
                            Image(systemName: "plus.circle")
                            Text("Create Post")
                        }
                    }
                }
                
                VStack {
                    NavigationLink {
                        BasicSettings(client: client)
                    } label: {
                        HStack {
                            Image(systemName: "gearshape")
                            Text("Settings")
                        }
                    }
                }
                VStack {
                    NavigationLink {
                        LogoutView(client: client)
                    } label: {
                        HStack {
                            Image(systemName: "x.circle")
                            Text("Logout")
                        }
                    }
                }
            }
            // when user isnt logged in
            else {
                VStack {
                    NavigationLink {
                        BeginPage(client: client)
                    } label: {
                        HStack {
                            Image(systemName: "book")
                            Text("Begin")
                        }
                    }
                }
            }
            
            // both
            if (client.devMode?.isEnabled == true) {
                VStack {
                    NavigationLink {
                        DevModeView(client: client)
                    } label: {
                        HStack {
                            Image(systemName: "hammer")
                            Text("DevMode")
                        }
                    }
                }
            }
            
            VStack {
                NavigationLink {
                    AboutView(client: client)
                } label: {
                    HStack {
                        Image(systemName: "info.circle")
                        Text("About")
                    }
                }
            }
            /*
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
            */
        }
        .navigationTitle("Interact")
    }
}

struct AppTabNavigation: View {
    @ObservedObject var client: Client
//    @State var expand = false
    @State var localSelected:Int = 0
    
    var body: some View {
        VStack {
            HStack (alignment: .center) {
                if (client.navigation?.hidden == true || client.loggedIn == false) {
                    EmptyView()
                }
                else {
                    if #available(iOS 26, *) {
                        TabView(selection: $localSelected) {
                            Tab("Home", systemImage: "house", value: 0) {
                            }
                            Tab("Search", systemImage: "magnifyingglass", value: 5, role: .search) {
                                NavigationStack {
                                    
                                }
                            }
                            Tab("System", systemImage: "archivebox", value: 2) {
                            }
                            if (client.devMode?.isEnabled == true) {
                                Tab("Debug", systemImage: "hammer", value: 3) {
                                }
                            }
                            Tab("Live Chat", systemImage: "bubble.left", value: 4) {
                            }
                        }
                    } else {
                        CustomTabView(client: client)
                    }
                }
            }
        }
        .onChange(of: localSelected, perform: {newvalue in
            client.hapticPress()
            client.navigation = client.navigationManager.switchTab(newTab: Int16(newvalue))
        })
        if #unavailable(iOS 26) {
            
            Spacer()
        }
    }
}

struct CustomTabView : View {
    @ObservedObject var client: Client

    var body: some View {
        Spacer(minLength: /*@START_MENU_TOKEN@*/0/*@END_MENU_TOKEN@*/)
        HStack {
            if !(client.navigation?.expanded ?? false) {
//                            Spacer(minLength: 5)

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

extension Binding {
    func optionalBinding() -> Binding<Value?> {
        Binding<Value?>(
            get: { self.wrappedValue },
            set: { newValue in
                if let unwrappedValue = newValue {
                    self.wrappedValue = unwrappedValue
                }
            }
        )
    }
}

extension Binding {
     func toUnwrapped<T>(defaultValue: T) -> Binding<T> where Value == Optional<T>  {
        Binding<T>(get: { self.wrappedValue ?? defaultValue }, set: { self.wrappedValue = $0 })
    }
}
