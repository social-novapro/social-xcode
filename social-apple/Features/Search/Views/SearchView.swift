//
//  SearchView.swift
//  social-apple
//
//  Created by Daniel Kravec on 2024-01-12.
//

import SwiftUI

struct SearchView: View {
    @ObservedObject var client: Client
    @StateObject private var searchClass: SearchClass
    @State private var selectedProfile: SelectedProfileData = SelectedProfileData()

    init(client: Client) {
        self.client = client
        _searchClass = StateObject(wrappedValue: SearchClass(client: client))
    }

    private var isSearchMode: Bool {
        !searchClass.searchText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
    }

    private var activeUsers: [UserData] {
        isSearchMode ? (searchClass.searchResults.usersFound ?? []) : (searchClass.exploreResults.usersFound ?? [])
    }

    private var activeHashtags: [SearchV2HashtagData] {
        isSearchMode ? (searchClass.searchResults.hashtagsFound ?? []) : (searchClass.exploreResults.hashtagsFound ?? [])
    }

    private var activePostsCount: Int {
        if isSearchMode {
            return searchClass.searchResults.postsFound?.count ?? 0
        }
        return searchClass.exploreResults.postsFound?.count ?? 0
    }

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 14) {
                if searchClass.isLoading {
                    HStack {
                        ProgressView()
                        Text("Loading...")
                    }
                }

                if let errorText = searchClass.errorText {
                    VStack(alignment: .leading, spacing: 6) {
                        Text("Failed to load explore/search")
                            .font(.headline)
                        Text(errorText)
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                        Button("Retry") {
                            if isSearchMode {
                                searchClass.onSearchTextChanged(searchClass.searchText)
                            } else {
                                searchClass.loadExplore()
                            }
                        }
                    }
                }

                if !activeHashtags.isEmpty {
                    sectionHeader(isSearchMode ? "Hashtags" : "Trending Hashtags")
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 8) {
                            ForEach(activeHashtags) { tag in
                                Button {
                                    searchClass.searchText = tag.displayText
                                    searchClass.onSearchTextChanged(tag.displayText)
                                } label: {
                                    Text(tag.displayText)
                                        .font(.subheadline)
                                        .padding(.horizontal, 10)
                                        .padding(.vertical, 6)
                                        .background(client.themeData.mainBackground)
                                        .overlay(
                                            RoundedRectangle(cornerRadius: 10)
                                                .stroke(Color.secondary, lineWidth: 1)
                                        )
                                        .cornerRadius(10)
                                }
                                .buttonStyle(.plain)
                            }
                        }
                    }
                }

                if !activeUsers.isEmpty {
                    sectionHeader(isSearchMode ? "Users" : "Newest Users")
                    ForEach(activeUsers) { user in
                        ExploreUserRow(client: client, user: user, isSearchMode: isSearchMode, searchClass: searchClass)
                    }
                }

                if activePostsCount > 0 {
                    sectionHeader(isSearchMode ? "Posts" : "Newest Posts")
                    ForEach(Array(0..<activePostsCount), id: \.self) { index in
                        if let postBinding = bindingForPost(at: index) {
                            PostPreView(client: client, feedData: postBinding, selectedProfile: $selectedProfile)
                        }
                    }
                }

                if !searchClass.isLoading && searchClass.errorText == nil && activeHashtags.isEmpty && activeUsers.isEmpty && activePostsCount == 0 {
                    Text(isSearchMode ? "No results found" : "No explore content available")
                        .foregroundStyle(.secondary)
                }
            }
            .padding(10)
        }
        .navigationTitle("Search")
        .searchable(text: $searchClass.searchText, prompt: "Search posts, users, hashtags")
        .onChange(of: searchClass.searchText) { newValue in
            searchClass.onSearchTextChanged(newValue)
        }
        .navigationDestination(isPresented: $selectedProfile.showProfile) {
            ProfileView(client: client, userData: selectedProfile.profileData, userID: selectedProfile.userID)
        }
    }

    @ViewBuilder
    private func sectionHeader(_ title: String) -> some View {
        Text(title)
            .font(.title3)
            .fontWeight(.semibold)
    }

    private func bindingForPost(at index: Int) -> Binding<AllPosts>? {
        if isSearchMode {
            guard let posts = searchClass.searchResults.postsFound,
                  posts.indices.contains(index) else {
                return nil
            }

            return Binding(
                get: { searchClass.searchResults.postsFound?[index] ?? posts[index] },
                set: { newValue in
                    searchClass.searchResults.postsFound?[index] = newValue
                }
            )
        }

        guard let posts = searchClass.exploreResults.postsFound,
              posts.indices.contains(index) else {
            return nil
        }

        return Binding(
            get: { searchClass.exploreResults.postsFound?[index] ?? posts[index] },
            set: { newValue in
                searchClass.exploreResults.postsFound?[index] = newValue
            }
        )
    }
}

private struct ExploreUserRow: View {
    @ObservedObject var client: Client
    let user: UserData
    let isSearchMode: Bool
    @ObservedObject var searchClass: SearchClass
    @State private var profileShowing: Bool = false
    @State private var isMutatingFollow: Bool = false

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Button {
                profileShowing = true
            } label: {
                HStack(spacing: 10) {
                    if let profileURL = user.profileURL, !profileURL.isEmpty {
                        AsyncImage(url: URL(string: profileURL)) { phase in
                            switch phase {
                            case .empty:
                                ProgressView()
                                    .frame(width: 36, height: 36)
                            case .success(let image):
                                image
                                    .resizable()
                                    .scaledToFill()
                                    .frame(width: 36, height: 36)
                                    .clipShape(Circle())
                            case .failure:
                                Image(systemName: "person.circle")
                                    .font(.title2)
                            @unknown default:
                                EmptyView()
                            }
                        }
                    } else {
                        Image(systemName: "person.circle")
                            .font(.title2)
                    }

                    VStack(alignment: .leading, spacing: 2) {
                        HStack {
                            Text(user.displayName ?? "Unknown")
                                .font(.headline)
                            if user.verified == true {
                                Image(systemName: "checkmark.seal.fill")
                            }
                        }
                        Text("@\(user.username ?? "unknown")")
                            .foregroundStyle(.secondary)
                        Text(user.description ?? "")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                            .lineLimit(2)
                    }

                    Spacer()
                }
            }
            .buttonStyle(.plain)

            HStack {
                Text("\(user.followerCount ?? 0) followers")
                    .font(.caption)
                    .foregroundStyle(.secondary)
                Spacer()
                if (user._id ?? "") != client.userTokens.userID {
                    Button(user.followed == true ? "Unfollow" : "Follow") {
                        mutateFollow()
                    }
                    .buttonStyle(.borderedProminent)
                    .disabled(isMutatingFollow)
                }
            }
        }
        .padding(12)
        .background(client.themeData.mainBackground)
        .cornerRadius(14)
        .overlay(
            RoundedRectangle(cornerRadius: 14)
                .stroke(Color.secondary, lineWidth: 1)
        )
        .navigationDestination(isPresented: $profileShowing) {
            ProfileView(client: client, userData: user, userID: user._id)
        }
    }

    private func mutateFollow() {
        guard let userID = user._id else {
            return
        }

        let currentlyFollowed = user.followed == true
        searchClass.setFollow(userID: userID, followed: !currentlyFollowed, inSearchResults: isSearchMode)
        isMutatingFollow = true

        Task {
            do {
                if currentlyFollowed {
                    _ = try await client.api.users.unFollowUser(userID: userID)
                } else {
                    _ = try await client.api.users.followUser(userID: userID)
                }
            } catch {
                searchClass.setFollow(userID: userID, followed: currentlyFollowed, inSearchResults: isSearchMode)
            }
            await MainActor.run {
                isMutatingFollow = false
            }
        }
    }
}
