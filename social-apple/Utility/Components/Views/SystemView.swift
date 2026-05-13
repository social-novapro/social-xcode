//
//  SystemView.swift
//  social-apple
//
//  Created by Codex on 2026-05-13.
//

import SwiftUI

struct SystemView: View {
    @ObservedObject var client: Client
    @ObservedObject var feedPosts: FeedPosts
    var presentation: SystemPresentation = .tab

    @StateObject private var adminErrorFeed: AdminErrorFeed

    init(client: Client, feedPosts: FeedPosts, presentation: SystemPresentation = .tab) {
        self.client = client
        self.feedPosts = feedPosts
        self.presentation = presentation
        _adminErrorFeed = StateObject(wrappedValue: AdminErrorFeed(client: client))
    }

    var body: some View {
        ScrollView {
            LazyVStack(alignment: .leading, spacing: 12) {
                if client.loggedIn {
                    userSection
                    settingsSection
                } else {
                    beginSection
                }

                if client.devMode?.isEnabled == true {
                    developerSection
                }

                aboutSection
            }
            .interactScreenPadding(maxWidth: presentation.maxWidth)
        }
        .interactAppBackground()
        .navigationTitle(presentation.navigationTitle)
    }

    private var userSection: some View {
        SystemSection(title: "Account", subtitle: "Your profile and posting tools.") {
            SystemNavigationItem(
                title: "Profile",
                subtitle: "@\(client.userData?.username ?? "unknown")",
                systemImage: "person"
            ) {
                ProfileView(client: client, userData: client.userData, userID: client.userTokens.userID)
            }

            InteractConnectedCardDivider(leadingInset: 56)

            SystemNavigationItem(
                title: "Create Post",
                subtitle: "Write a new post, poll, or copost.",
                systemImage: "plus.circle"
            ) {
                CreatePost(client: client)
            }
        }
    }

    private var settingsSection: some View {
        SystemSection(title: "System", subtitle: "Local app settings and account actions.") {
            SystemNavigationItem(
                title: "Settings",
                subtitle: "Appearance, app, and developer options.",
                systemImage: "gearshape"
            ) {
                BasicSettings(client: client, feedPosts: feedPosts)
            }

            InteractConnectedCardDivider(leadingInset: 56)

            SystemNavigationItem(
                title: "Connected Accounts",
                subtitle: "Add, switch, and manage saved accounts.",
                systemImage: "person.2"
            ) {
                AccountsView(client: client, feedPosts: feedPosts)
            }

            InteractConnectedCardDivider(leadingInset: 56)

            SystemNavigationItem(
                title: "Logout",
                subtitle: "Log out of the current or all accounts.",
                systemImage: "x.circle",
                tone: .destructive
            ) {
                LogoutView(client: client, feedPosts: feedPosts)
            }
        }
    }

    private var beginSection: some View {
        SystemSection(title: "Begin", subtitle: "Sign in or create an account.") {
            SystemNavigationItem(
                title: "Begin",
                subtitle: "Open the welcome and sign-in flow.",
                systemImage: "book"
            ) {
                BeginPage(client: client)
            }
        }
    }

    private var developerSection: some View {
        SystemSection(title: "Developer", subtitle: "Visible while Dev Mode is enabled.", tone: .destructive) {
            SystemNavigationItem(
                title: "Dev Mode",
                subtitle: "Local tokens and debug actions.",
                systemImage: "hammer"
            ) {
                DevModeView(client: client)
            }

            InteractConnectedCardDivider(leadingInset: 56)

            SystemNavigationItem(
                title: "Developer Settings",
                subtitle: "Developer tokens and connected applications.",
                systemImage: "curlybraces"
            ) {
                DeveloperSettingsView(client: client)
            }

            InteractConnectedCardDivider(leadingInset: 56)

            SystemNavigationItem(
                title: "Admin Issues",
                subtitle: "Review backend error reports.",
                systemImage: "exclamationmark.triangle"
            ) {
                AdminErrorView(client: client, adminErrorFeed: adminErrorFeed)
            }
        }
    }

    private var aboutSection: some View {
        SystemSection(title: "About") {
            SystemNavigationItem(
                title: "About Interact",
                subtitle: "Version, build, and project details.",
                systemImage: "info.circle"
            ) {
                AboutView(client: client)
            }
        }
    }
}

enum SystemPresentation {
    case tab
    case sidebar

    var navigationTitle: String {
        switch self {
        case .tab:
            return "System"
        case .sidebar:
            return "Interact"
        }
    }

    var maxWidth: CGFloat {
        switch self {
        case .tab:
            return 620
        case .sidebar:
            return 420
        }
    }
}

struct SystemSection<Content: View>: View {
    let title: String
    var subtitle: String?
    var tone: InteractSectionTone = .normal
    let content: Content

    init(
        title: String,
        subtitle: String? = nil,
        tone: InteractSectionTone = .normal,
        @ViewBuilder content: () -> Content
    ) {
        self.title = title
        self.subtitle = subtitle
        self.tone = tone
        self.content = content()
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            InteractSectionHeader(title: title, subtitle: subtitle)
            InteractConnectedCardSection(tone: tone) {
                content
            }
        }
    }
}

struct SystemNavigationItem<Destination: View>: View {
    let title: String
    var subtitle: String?
    let systemImage: String
    var tone: InteractSectionTone = .normal
    let destination: Destination

    init(
        title: String,
        subtitle: String? = nil,
        systemImage: String,
        tone: InteractSectionTone = .normal,
        @ViewBuilder destination: () -> Destination
    ) {
        self.title = title
        self.subtitle = subtitle
        self.systemImage = systemImage
        self.tone = tone
        self.destination = destination()
    }

    var body: some View {
        NavigationLink {
            destination
        } label: {
            InteractConnectedCardRow {
                InteractSettingsRowLabel(
                    title: title,
                    subtitle: subtitle,
                    systemImage: systemImage
                )
            }
        }
        .buttonStyle(.plain)
    }
}
