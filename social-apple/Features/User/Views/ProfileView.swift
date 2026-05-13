//
//  ProfileView.swift
//  social-apple
//
//  Created by Daniel Kravec on 2023-11-28.
//

import SwiftUI

private func profilePostBinding(
    profileData: ProfileViewClass,
    postID: String,
    keyPath: ReferenceWritableKeyPath<ProfileViewClass, [AllPosts]>,
    fallback: AllPosts
) -> Binding<AllPosts> {
    Binding {
        profileData[keyPath: keyPath].first { $0.postData._id == postID } ?? fallback
    } set: { updatedPost in
        var posts = profileData[keyPath: keyPath]
        guard let index = posts.firstIndex(where: { $0.postData._id == postID }) else {
            return
        }
        posts[index] = updatedPost
        profileData[keyPath: keyPath] = posts
    }
}

private func nonEmptyText(_ value: String?, fallback: String) -> String {
    let trimmedValue = value?.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
    return trimmedValue.isEmpty ? fallback : trimmedValue
}

private struct ProfileStatusView: View {
    let title: String
    let message: String
    let isLoading: Bool
    let retryTitle: String?
    let retryAction: (() -> Void)?

    var body: some View {
        VStack(spacing: 10) {
            if isLoading {
                ProgressView()
            }

            Text(title)
                .font(.headline)

            Text(message)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)

            if let retryTitle, let retryAction {
                Button(retryTitle, action: retryAction)
                    .buttonStyle(.bordered)
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .padding(20)
    }
}

private struct ProfileSectionStatusView: View {
    let state: ProfileSectionLoadState
    let retryAction: (() -> Void)?

    var body: some View {
        switch state {
        case .loading:
            ProfileStatusView(
                title: "Loading...",
                message: "Fetching the latest profile data.",
                isLoading: true,
                retryTitle: nil,
                retryAction: nil
            )
        case .loaded:
            EmptyView()
        case .empty(let message):
            ProfileStatusView(
                title: "Nothing here yet",
                message: message,
                isLoading: false,
                retryTitle: nil,
                retryAction: nil
            )
        case .failed(let message):
            ProfileStatusView(
                title: "Could not load this section",
                message: message,
                isLoading: false,
                retryTitle: "Retry",
                retryAction: retryAction
            )
        }
    }
}

struct ProfileView : View {
    @ObservedObject var client: Client
    @ObservedObject var profileData: ProfileViewClass
    @State var userData: UserData?
    @State var userID: String?
    @State var selectedProfile: SelectedProfileData = SelectedProfileData()
    @State var userFollowingList: UserFollowListData?
    @State var userFollowerList: UserFollowListData?
    @State var selectedFollowList = 0
    @State private var loadedFollowListsForUserID: String?
    @State private var selectedProfileSection: ProfileSection = .posts
    @State private var followingLoadState: ProfileSectionLoadState = .loading
    @State private var followersLoadState: ProfileSectionLoadState = .loading
    @State private var followingRequestID = UUID()
    @State private var followersRequestID = UUID()
    @State private var showingFollowList = false
    @State private var editingProfile = false
    @State private var editingResults: UserEditResponse?
    @State private var showEditResults = false
    @State private var followingLoadingNextIndex = false
    @State private var followersLoadingNextIndex = false
    @State private var sectionTransitionDirection = 1
    @GestureState private var sectionDragOffset: CGFloat = 0

    init (client: Client, userData: UserData?, userID: String?) {
        self.client = client
        self.userData = userData
        self.userID = userID
        self.profileData = ProfileViewClass(client: client, userData: userData, userID: userID)
    }
    
    var body: some View {
        VStack {
            switch profileData.loadState {
            case .loading:
                ProfileStatusView(
                    title: "Loading profile...",
                    message: "Fetching profile details.",
                    isLoading: true,
                    retryTitle: nil,
                    retryAction: nil
                )
            case .loaded:
                loadedProfileContent
            case .empty(let message):
                ProfileStatusView(
                    title: "No user found",
                    message: message,
                    isLoading: false,
                    retryTitle: "Retry",
                    retryAction: {
                        profileData.refreshProfile()
                    }
                )
            case .failed(let message):
                ProfileStatusView(
                    title: "Profile failed to load",
                    message: message,
                    isLoading: false,
                    retryTitle: "Retry",
                    retryAction: {
                        profileData.refreshProfile()
                    }
                )
            }
//#endif

        }
        .navigationTitle(profileData.doneLoading ? "Profile of @" + (profileData.userData?.username ?? "unknown") : "Loading profile...")
        .interactAppBackground()
        .sheet(isPresented: $showingFollowList) {
            NavigationView {
                FollowingFollowerView(
                    client: client,
                    userID: userID ?? "",
                    userFollowingList: $userFollowingList,
                    userFollowerList: $userFollowerList,
                    selectedFollowList: $selectedFollowList,
                    followingLoadState: followingLoadState,
                    followersLoadState: followersLoadState,
                    refreshFollowing: {
                        await refreshFollowList(type: 0)
                    },
                    refreshFollowers: {
                        await refreshFollowList(type: 1)
                    },
                    followingLoadingNextIndex: followingLoadingNextIndex,
                    followersLoadingNextIndex: followersLoadingNextIndex,
                    loadNextFollowing: {
                        loadNextFollowList(type: 0)
                    },
                    loadNextFollowers: {
                        loadNextFollowList(type: 1)
                    }
                )
                .navigationTitle(selectedFollowList == 0 ? "Following" : "Followers")
                .interactAppBackground()
                .toolbar {
                    Button("Done") {
                        showingFollowList = false
                    }
                }
                .onAppear {
                    let resolvedID = (profileData.userData?._id ?? profileData.userID).trimmingCharacters(in: .whitespacesAndNewlines)
                    loadFollowListsIfNeeded(userID: resolvedID)
                }
            }
        }
        .onAppear() {
            if let userData {
                profileData.provBasic(userData: userData)
            }

            profileData.ready()
            print("showing)")
        }
        .onChange(of: profileData.userData?._id ?? "") { newUserID in
            loadFollowListsIfNeeded(userID: newUserID)
        }
        .onChange(of: profileData.loadState) { newLoadState in
            guard newLoadState == .loaded else {
                return
            }

            let resolvedID = (profileData.userData?._id ?? profileData.userID).trimmingCharacters(in: .whitespacesAndNewlines)
            loadFollowListsIfNeeded(userID: resolvedID)
        }
        .onChange(of: client.userTokens.userID) { _ in
            loadedFollowListsForUserID = nil
            userFollowingList = nil
            userFollowerList = nil
            followingLoadState = .loading
            followersLoadState = .loading
            followingLoadingNextIndex = false
            followersLoadingNextIndex = false
            profileData.refreshProfile()

            let resolvedID = (profileData.userData?._id ?? profileData.userID).trimmingCharacters(in: .whitespacesAndNewlines)
            if !resolvedID.isEmpty {
                loadFollowLists(userID: resolvedID)
            }
        }
    }

    private var loadedProfileContent: some View {
        List {
            ProfileHeaderView(
                client: client,
                profileData: profileData,
                selectedFollowList: $selectedFollowList,
                showingFollowList: $showingFollowList,
                editingProfile: $editingProfile,
                showEditResults: $showEditResults
            )
            .listRowInsets(EdgeInsets())
            .listRowSeparator(.hidden)
            .padding(.horizontal, 15)
            .padding(.vertical, 12)

            if editingProfile {
                EditProfileView(
                    client: client,
                    profileData: profileData,
                    editingProfile: $editingProfile,
                    editingResults: $editingResults,
                    showEditResults: $showEditResults
                )
                .listRowInsets(EdgeInsets())
                .listRowSeparator(.hidden)
                .padding(15)
            } else if showEditResults {
                EditProfileResults(
                    client: client,
                    profileData: profileData,
                    editingResults: $editingResults,
                    showEditResults: $showEditResults
                )
                .listRowInsets(EdgeInsets())
                .listRowSeparator(.hidden)
                .padding(15)
            } else {
                ProfileSectionPicker(selectedSection: $selectedProfileSection)
                    .listRowInsets(EdgeInsets())
                    .listRowSeparator(.hidden)
                    .padding(.horizontal, 15)
                    .padding(.bottom, 8)

                sectionRowsWithSwipe
            }
        }
        .listStyle(.plain)
#if !os(tvOS)
        .listRowSeparator(.hidden)
#endif
        .refreshable {
            await refreshSelectedProfileSection()
        }
        .simultaneousGesture(sectionSwipeGesture)
    }

    @ViewBuilder
    private var sectionRowsWithSwipe: some View {
        Group {
            selectedSectionRows
        }
        .id(selectedProfileSection)
        .offset(x: interactiveSectionDragOffset)
        .opacity(sectionDragOpacity)
        .transition(sectionTransition)
        .animation(.interactiveSpring(response: 0.28, dampingFraction: 0.86), value: sectionDragOffset)
        .animation(.spring(response: 0.28, dampingFraction: 0.88), value: selectedProfileSection)
    }

    private var sectionSwipeGesture: some Gesture {
        DragGesture(minimumDistance: 18, coordinateSpace: .local)
            .updating($sectionDragOffset) { value, state, _ in
                guard canTrackSectionDrag(value) else {
                    state = 0
                    return
                }

                state = boundedSectionDragOffset(value.translation.width)
            }
            .onEnded { value in
                guard !editingProfile && !showEditResults else {
                    return
                }

                let horizontalDistance = value.translation.width
                let verticalDistance = value.translation.height
                let predictedHorizontalDistance = value.predictedEndTranslation.width
                let horizontalThreshold: CGFloat = 70
                let mostlyHorizontal = abs(horizontalDistance) > abs(verticalDistance) * 1.4
                let reachedDistance = abs(horizontalDistance) > horizontalThreshold
                let reachedVelocity = abs(predictedHorizontalDistance) > 160

                guard mostlyHorizontal && (reachedDistance || reachedVelocity) else {
                    return
                }

                if (reachedVelocity ? predictedHorizontalDistance : horizontalDistance) < 0 {
                    switchProfileSection(offset: 1)
                } else {
                    switchProfileSection(offset: -1)
                }
            }
    }

    private var interactiveSectionDragOffset: CGFloat {
        sectionDragOffset
    }

    private var sectionDragOpacity: Double {
        1 - min(Double(abs(sectionDragOffset) / 600), 0.18)
    }

    private var sectionTransition: AnyTransition {
        let insertionEdge: Edge = sectionTransitionDirection >= 0 ? .trailing : .leading
        let removalEdge: Edge = sectionTransitionDirection >= 0 ? .leading : .trailing

        return .asymmetric(
            insertion: .move(edge: insertionEdge).combined(with: .opacity),
            removal: .move(edge: removalEdge).combined(with: .opacity)
        )
    }

    @ViewBuilder
    private var selectedSectionRows: some View {
        switch selectedProfileSection {
        case .posts:
            profilePostRows(
                posts: profileData.postData,
                state: profileData.postsLoadState,
                keyPath: \.postData,
                section: .posts,
                loadMoreOnBottom: true
            )
        case .pins:
            profilePostRows(
                posts: profileData.pinData,
                state: profileData.pinsLoadState,
                keyPath: \.pinData,
                section: .pins,
                loadMoreOnBottom: false
            )
        case .mentions:
            profilePostRows(
                posts: profileData.mentionData,
                state: profileData.mentionsLoadState,
                keyPath: \.mentionData,
                section: .mentions,
                loadMoreOnBottom: false
            )
        case .badges:
            badgeRows
        case .quickInfo, .followLists:
            EmptyView()
        }
    }

    @ViewBuilder
    private func profilePostRows(
        posts: [AllPosts],
        state: ProfileSectionLoadState,
        keyPath: ReferenceWritableKeyPath<ProfileViewClass, [AllPosts]>,
        section: ProfileSection,
        loadMoreOnBottom: Bool
    ) -> some View {
        switch state {
        case .loaded:
            ForEach(posts, id: \.postData._id) { post in
                let postID = post.postData._id

                PostPreView(client: client, feedData: profilePostBinding(profileData: profileData, postID: postID, keyPath: keyPath, fallback: post), selectedProfile: $selectedProfile)
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
#if !os(tvOS)
                    .listRowSeparator(.hidden)
#endif
                    .listRowInsets(EdgeInsets())
                    .padding(10)
                    .onAppear {
                        if loadMoreOnBottom && self.profileData.postData.last?.postData._id == postID {
                            self.profileData.nextUserPostsIndex()
                        }
                    }
            }

            if loadMoreOnBottom && profileData.loadingNextIndex {
                HStack {
                    Spacer()
                    ProgressView()
                    Spacer()
                }
                .padding(20)
                .listRowSeparator(.hidden)
            } else {
                EmptyView()
                    .padding(.bottom, 30)
                    .listRowSeparator(.hidden)
            }
        default:
            ProfileSectionStatusView(state: state) {
                profileData.refreshProfile(section: section)
            }
#if !os(tvOS)
            .listRowSeparator(.hidden)
#endif
            .listRowInsets(EdgeInsets())
        }
    }

    @ViewBuilder
    private var badgeRows: some View {
        switch profileData.badgesLoadState {
        case .loaded:
            ForEach(profileData.badgeData, id: \.id) { badge in
                BadgeCardView(client: client, badgeData: badge)
                    .padding(10)
                    .listRowInsets(EdgeInsets())
#if !os(tvOS)
                    .listRowSeparator(.hidden)
#endif
            }
            EmptyView()
                .padding(.bottom, 30)
                .listRowSeparator(.hidden)
        default:
            ProfileSectionStatusView(state: profileData.badgesLoadState) {
                profileData.refreshProfile(section: .badges)
            }
#if !os(tvOS)
            .listRowSeparator(.hidden)
#endif
            .listRowInsets(EdgeInsets())
        }
    }

    private func refreshSelectedProfileSection() async {
        switch selectedProfileSection {
        case .posts, .pins, .mentions, .badges:
            await refreshProfileData(section: selectedProfileSection)
        case .quickInfo, .followLists:
            await refreshProfileData()
        }
    }

    private func switchProfileSection(offset: Int) {
        let sections = ProfileSection.profileContentSections
        guard let currentIndex = sections.firstIndex(of: selectedProfileSection) else {
            return
        }

        let newIndex = currentIndex + offset
        guard sections.indices.contains(newIndex) else {
            return
        }

        client.hapticPress()
        sectionTransitionDirection = offset
        withAnimation(.easeInOut(duration: 0.2)) {
            selectedProfileSection = sections[newIndex]
        }
    }

    private func canTrackSectionDrag(_ value: DragGesture.Value) -> Bool {
        guard !editingProfile && !showEditResults else {
            return false
        }

        let horizontalDistance = value.translation.width
        let verticalDistance = value.translation.height

        return abs(horizontalDistance) > 12 && abs(horizontalDistance) > abs(verticalDistance) * 1.25
    }

    private func boundedSectionDragOffset(_ translation: CGFloat) -> CGFloat {
        let offset = translation < 0 ? 1 : -1
        let canMove = canSwitchProfileSection(offset: offset)
        let dampedTranslation = canMove ? translation : translation * 0.18

        return min(max(dampedTranslation, -180), 180)
    }

    private func canSwitchProfileSection(offset: Int) -> Bool {
        let sections = ProfileSection.profileContentSections
        guard let currentIndex = sections.firstIndex(of: selectedProfileSection) else {
            return false
        }

        return sections.indices.contains(currentIndex + offset)
    }

    private func refreshProfileData(section: ProfileSection? = nil) async {
        client.hapticPress()
        await withCheckedContinuation { (continuation: CheckedContinuation<Void, Never>) in
            profileData.refreshProfile(section: section) {
                continuation.resume()
            }
        }
    }

    private func loadFollowListsIfNeeded(userID: String) {
        let resolvedID = userID.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !resolvedID.isEmpty else {
            return
        }

        let missingInitialLists = userFollowingList == nil || userFollowerList == nil
        guard loadedFollowListsForUserID != resolvedID || missingInitialLists else {
            return
        }

        loadedFollowListsForUserID = resolvedID
        loadFollowLists(userID: resolvedID)
    }

    private func loadFollowLists(userID: String) {
        let resolvedID = userID.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !resolvedID.isEmpty else {
            followingLoadState = .failed("No profile was selected.")
            followersLoadState = .failed("No profile was selected.")
            return
        }

        let nextFollowingRequestID = UUID()
        let nextFollowersRequestID = UUID()
        followingRequestID = nextFollowingRequestID
        followersRequestID = nextFollowersRequestID
        userFollowingList = nil
        userFollowerList = nil
        followingLoadState = .loading
        followersLoadState = .loading
        followingLoadingNextIndex = false
        followersLoadingNextIndex = false

        Task {
            await loadFollowList(userID: resolvedID, type: 0, requestID: nextFollowingRequestID)
        }

        Task {
            await loadFollowList(userID: resolvedID, type: 1, requestID: nextFollowersRequestID)
        }
    }

    private func refreshFollowList(type: Int) async {
        await MainActor.run {
            client.hapticPress()
        }

        var resolvedID = ""
        var requestID = UUID()

        await MainActor.run {
            resolvedID = (profileData.userData?._id ?? profileData.userID).trimmingCharacters(in: .whitespacesAndNewlines)
            requestID = UUID()

            if type == 0 {
                followingRequestID = requestID
                userFollowingList = nil
                followingLoadState = .loading
                followingLoadingNextIndex = false
            } else {
                followersRequestID = requestID
                userFollowerList = nil
                followersLoadState = .loading
                followersLoadingNextIndex = false
            }
        }

        guard !resolvedID.isEmpty else {
            await MainActor.run {
                if type == 0 {
                    followingLoadState = .failed("No profile was selected.")
                } else {
                    followersLoadState = .failed("No profile was selected.")
                }
            }
            return
        }

        await loadFollowList(userID: resolvedID, type: type, requestID: requestID)
    }

    private func loadNextFollowList(type: Int) {
        let currentList = type == 0 ? userFollowingList : userFollowerList
        let isLoadingNext = type == 0 ? followingLoadingNextIndex : followersLoadingNextIndex

        guard !isLoadingNext,
              let prevIndexID = currentList?.prevIndexID,
              !prevIndexID.isEmpty else {
            return
        }

        let resolvedID = (currentList?.userID ?? profileData.userData?._id ?? profileData.userID).trimmingCharacters(in: .whitespacesAndNewlines)
        guard !resolvedID.isEmpty else {
            return
        }

        let requestID = type == 0 ? followingRequestID : followersRequestID

        if type == 0 {
            followingLoadingNextIndex = true
        } else {
            followersLoadingNextIndex = true
        }

        Task {
            await loadFollowList(userID: resolvedID, type: type, requestID: requestID, indexID: prevIndexID, append: true)
        }
    }

    private func loadFollowList(userID: String, type: Int, requestID: UUID, indexID: String? = nil, append: Bool = false) async {
        do {
            let list = try await client.api.users.followingFollowerList(userID: userID, type: type, indexID: indexID)

            await MainActor.run {
                guard isCurrentFollowListRequest(type: type, requestID: requestID, userID: userID) else {
                    setFollowListLoadingNext(false, type: type)
                    return
                }

                if type == 0 {
                    userFollowingList = append ? mergedFollowList(current: userFollowingList, next: list) : list
                    followingLoadState = followListState(list: userFollowingList ?? list, type: type)
                } else {
                    userFollowerList = append ? mergedFollowList(current: userFollowerList, next: list) : list
                    followersLoadState = followListState(list: userFollowerList ?? list, type: type)
                }
                setFollowListLoadingNext(false, type: type)
            }
        } catch {
            let message = userFacingErrorMessage(error, fallback: "We could not load this list.")
            print("Failed to get follow list: \(error.localizedDescription)")

            await MainActor.run {
                guard isCurrentFollowListRequest(type: type, requestID: requestID, userID: userID) else {
                    setFollowListLoadingNext(false, type: type)
                    return
                }

                if !append {
                    if type == 0 {
                        followingLoadState = .failed(message)
                    } else {
                        followersLoadState = .failed(message)
                    }
                }
                setFollowListLoadingNext(false, type: type)
            }
        }
    }

    private func setFollowListLoadingNext(_ isLoading: Bool, type: Int) {
        if type == 0 {
            followingLoadingNextIndex = isLoading
        } else {
            followersLoadingNextIndex = isLoading
        }
    }

    private func mergedFollowList(current: UserFollowListData?, next: UserFollowListData) -> UserFollowListData {
        var mergedData = current?.data ?? []

        for nextDataPoint in next.data ?? [] {
            guard !mergedData.contains(where: { $0.followData._id == nextDataPoint.followData._id }) else {
                continue
            }
            mergedData.append(nextDataPoint)
        }

        return UserFollowListData(
            found: next.found || !mergedData.isEmpty,
            followIndexID: next.followIndexID ?? current?.followIndexID,
            prevIndexID: next.prevIndexID,
            nextIndexID: next.nextIndexID,
            timestamp: next.timestamp ?? current?.timestamp,
            current: next.current ?? current?.current,
            type: next.type ?? current?.type,
            userID: next.userID ?? current?.userID,
            userData: next.userData ?? current?.userData,
            amount: next.amount ?? current?.amount,
            includedIndexes: next.includedIndexes ?? current?.includedIndexes,
            follows: next.follows ?? current?.follows,
            data: mergedData
        )
    }

    private func isCurrentFollowListRequest(type: Int, requestID: UUID, userID: String) -> Bool {
        let selectedUserID = (profileData.userData?._id ?? profileData.userID).trimmingCharacters(in: .whitespacesAndNewlines)
        guard selectedUserID == userID else {
            return false
        }

        if type == 0 {
            return followingRequestID == requestID
        }

        return followersRequestID == requestID
    }

    private func followListState(list: UserFollowListData, type: Int) -> ProfileSectionLoadState {
        let data = list.data ?? []
        if data.isEmpty {
            return .empty(type == 0 ? "No following found." : "No followers found.")
        }

        return .loaded
    }
}

private struct ProfileSectionPicker: View {
    @Binding var selectedSection: ProfileSection

    var body: some View {
        Picker("Profile section", selection: $selectedSection) {
            ForEach(ProfileSection.profileContentSections) { section in
                Text(section.title)
                    .tag(section)
            }
        }
        .pickerStyle(.segmented)
    }
}

private struct ProfileAvatarView: View {
    let userData: UserData
    let size: CGFloat

    var body: some View {
        if let profileURL = userData.profileURL, !profileURL.isEmpty {
            AsyncImage(url: URL(string: profileURL)) { phase in
                switch phase {
                case .empty:
                    ProgressView()
                        .frame(width: size, height: size)
                case .success(let image):
                    image
                        .resizable()
                        .scaledToFill()
                        .frame(width: size, height: size)
                        .clipShape(Circle())
                case .failure:
                    fallbackAvatar
                @unknown default:
                    fallbackAvatar
                }
            }
            .frame(width: size, height: size)
            .clipShape(Circle())
        } else {
            fallbackAvatar
        }
    }

    private var fallbackAvatar: some View {
        ZStack {
            Circle()
                .fill(Color.secondary.opacity(0.14))

            Image(systemName: "person.fill")
                .font(.system(size: size * 0.42))
                .foregroundColor(.secondary)
        }
        .frame(width: size, height: size)
    }
}

private struct ProfileHeaderView: View {
    @ObservedObject var client: Client
    @ObservedObject var profileData: ProfileViewClass
    @Binding var selectedFollowList: Int
    @Binding var showingFollowList: Bool
    @Binding var editingProfile: Bool
    @Binding var showEditResults: Bool

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            if let userData = profileData.userData {
                HStack(alignment: .top, spacing: 12) {
                    ProfileAvatarView(userData: userData, size: 64)

                    VStack(alignment: .leading, spacing: 4) {
                        HStack(spacing: 6) {
                            Text(nonEmptyText(userData.displayName, fallback: "Unknown User"))
                                .font(.title2)
                                .fontWeight(.semibold)
                            if userData.verified == true {
                                Image(systemName: "checkmark.seal.fill")
                                    .foregroundColor(.accentColor)
                            }
                        }

                        Text("@" + nonEmptyText(userData.username, fallback: "unknown"))
                            .foregroundColor(.secondary)
                    }

                    Spacer()

                    profileAction(userData: userData)
                }

                if let description = userData.description?.trimmingCharacters(in: .whitespacesAndNewlines), !description.isEmpty {
                    Text(description)
                        .fixedSize(horizontal: false, vertical: true)
                }

                if let statusTitle = userData.statusTitle?.trimmingCharacters(in: .whitespacesAndNewlines), !statusTitle.isEmpty {
                    Text(statusTitle)
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }

                if let creationTimestamp = userData.creationTimestamp {
                    Label("Joined " + int64TimeFormatter(timestamp: creationTimestamp), systemImage: "calendar")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }

                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 18) {
                        followCountButton(count: userData.followingCount ?? 0, title: "Following", type: 0)
                        followCountButton(count: userData.followerCount ?? 0, title: "Followers", type: 1)

                        if let totalPosts = userData.totalPosts {
                            countLabel(count: totalPosts, title: "Posts")
                        }
                        if let totalReplies = userData.totalReplies {
                            countLabel(count: totalReplies, title: "Replies")
                        }
                        if let totalQuotes = userData.totalQuotes {
                            countLabel(count: totalQuotes, title: "Quotes")
                        }
                    }
                }
            } else {
                Text("Profile details unavailable")
                    .foregroundColor(.secondary)
            }
        }
    }

    @ViewBuilder
    private func profileAction(userData: UserData) -> some View {
        if profileData.isClient {
            Button("Edit Profile") {
                client.hapticPress()
                showEditResults = false
                editingProfile = true
            }
            .buttonStyle(.bordered)
        } else if let profileUserID = userData._id, !profileUserID.isEmpty {
            Button(profileData.followed ? "Unfollow" : "Follow") {
                toggleFollow(profileUserID: profileUserID)
            }
            .buttonStyle(.borderedProminent)
        }
    }

    private func followCountButton(count: Int64, title: String, type: Int) -> some View {
        Button {
            client.hapticPress()
            selectedFollowList = type
            showingFollowList = true
        } label: {
            countLabel(count: count, title: title)
        }
        .buttonStyle(.plain)
    }

    private func countLabel(count: Int64, title: String) -> some View {
        VStack(alignment: .leading, spacing: 2) {
            Text(String(count))
                .font(.subheadline)
                .fontWeight(.semibold)
            Text(title)
                .font(.caption)
                .foregroundColor(.secondary)
        }
    }

    private func toggleFollow(profileUserID: String) {
        client.hapticPress()
        Task {
            if profileData.followed {
                do {
                    _ = try await client.api.users.unFollowUser(userID: profileUserID)
                    await MainActor.run {
                        profileData.followed = false
                    }
                } catch let error as ErrorData {
                    print("ErrorData: \(error.code), \(error.msg)")
                } catch {
                    print("Unexpected error: \(error)")
                }
            } else {
                do {
                    _ = try await client.api.users.followUser(userID: profileUserID)
                    await MainActor.run {
                        profileData.followed = true
                    }
                } catch let error as ErrorData {
                    print("ErrorData: \(error.code), \(error.msg)")
                } catch {
                    print("Unexpected error: \(error)")
                }
            }
        }
    }
}

struct ProfileMentionView: View {
    @ObservedObject var client: Client
    @ObservedObject var profileData: ProfileViewClass
    let loadState: ProfileSectionLoadState
    let retryAction: () -> Void
    let refreshAction: () async -> Void
    @State var selectedProfile: SelectedProfileData = SelectedProfileData()

    init(client: Client, profileData: ProfileViewClass, loadState: ProfileSectionLoadState, retryAction: @escaping () -> Void, refreshAction: @escaping () async -> Void) {
        self.client = client
        self.profileData = profileData
        self.loadState = loadState
        self.retryAction = retryAction
        self.refreshAction = refreshAction
        print(profileData)
    }

    var body: some View {
        VStack {
            Text("User Mentions")

            List {
                switch loadState {
                case .loaded:
                    ForEach(self.profileData.mentionData, id: \.postData._id) { post in
                        let postID = post.postData._id

                        PostPreView(client: client, feedData: profilePostBinding(profileData: profileData, postID: postID, keyPath: \.mentionData, fallback: post), selectedProfile: $selectedProfile)
                            .frame(maxWidth: .infinity, maxHeight: .infinity)
#if !os(tvOS)
                            .listRowSeparator(.hidden)
#endif
                            .listRowInsets(EdgeInsets())
                            .padding(10)
                    }
                    EmptyView()
                        .padding(.bottom, 20)
                default:
                    ProfileSectionStatusView(state: loadState, retryAction: retryAction)
#if !os(tvOS)
                        .listRowSeparator(.hidden)
#endif
                        .listRowInsets(EdgeInsets())
                }
            }
#if !os(tvOS)
            .listStyle(.plain)
            .listRowSeparator(.hidden)
#endif
            .refreshable {
                await refreshAction()
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}

struct EditChange: View {
    @ObservedObject var client: Client
    @Binding var change: UserEditChangeResponse;
    @State var fakeString: String = ""
    @State var fakeDate: Int64 = 0

    var body: some View {
        VStack {
            HStack {
                Spacer()
                VStack {
                    HStack {
                        Text(change.title)
                            .font(.headline)
                        Spacer()
                    }
                    
                    HStack {
                        Text(change.description)
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                        Spacer()
                    }
                    if (change.type == "String") {
                        HStack {
                            Text("Current: \(String(describing: change.currentValueString ?? ""))")
                            Spacer()
                        }
                        TextField("Update", text: $change.newValueString)

                    } else if (change.type == "Date") {
                        HStack {
                            if (change.currentValueDate == nil) {
                                Text("Current:")
                            } else {
                                Text("Current: \(int64TimeFormatter(timestamp: change.currentValueDate ?? 0))")
                            }
                            Spacer()
                        }
#if !os(tvOS)
                        DatePicker(selection: $change.newValueDate, in: ...Date.now, displayedComponents: .date) {
                            Text("Select a date (must be older than 13)")
                        }
#endif
                    }
                    Spacer()
                }
                .padding(10)
                .interactCardSurface(
                    cornerRadius: 20,
                    lineWidth: 3,
                    originalBackground: client.themeData.mainBackground,
                    originalBorder: .gray
                )
            }
        }
        .onChange(of: change.newValueString) { newValue in
            change.updated = true;
        }

        .onChange(of: change.newValueDate) { newValue in
            change.updated = true;
        }
    }
}

struct EditProfileResults : View {
    @ObservedObject var client: Client
    @ObservedObject var profileData: ProfileViewClass
    @Binding var editingResults: UserEditResponse?
    @Binding var showEditResults: Bool

    var body: some View {
        VStack {
            HStack {
                Text("Editing Result")
                    .foregroundColor(.secondary)
            }
            Divider()
            HStack {
                HStack {
                    Button(action: {
                        client.hapticPress()
                        DispatchQueue.main.async {
                            showEditResults=false
                        }
                    }) {
                        HStack {
                            Text("Close")
                        }
                        .foregroundColor(.secondary)
                    }
                    .buttonStyle(PlainButtonStyle())
                }
            }
            // editor
            VStack {
                ScrollView {
                    Text("Will show errors and successes here at a later date. Until then, close and reopen the profile page to see changes.")
                    // invalid fields, fails, acceptedChanges
                    
//                    ForEach(editingResults?.invalidFields ?? []) { invalid in
//                        //
//                    }
//                    ForEach(editingResults?.fails ?? []) { invalid in
//                        VStack {
//                            Text("Field Failed: \(invalid.field)")
//                            Text("Code: \(invalid.code)")
//                            Text("Message: \(invalid.msg)")
//                        }
//                        Divider()
//                    }
                    
//                    ForEach($editingResults.acceptedChanges) { accepted in
//                        
//                    }
                    
//                    ForEach($possibleEdits) { change in
//                        EditChange(client: client, change: change)
//                    }
//                    .padding(10)
                }
            }
        }
    }
}
struct EditProfileView : View {
    @ObservedObject var client: Client
    @ObservedObject var profileData: ProfileViewClass
    
    @Binding var editingProfile: Bool
    @Binding var editingResults: UserEditResponse?
    @Binding var showEditResults: Bool

    @State var doneLoading: Bool = false
    @State var possibleEdits: [UserEditChangeResponse] = [];
    
    @State var userEdited:Bool = false
    
    var body: some View {
        VStack {
            HStack {
                Text("Editing Profile")
                    .foregroundColor(.secondary)
            }
            Divider()
            HStack {
                Spacer()
                HStack {
                    Button(action: {
                        client.hapticPress()
                        DispatchQueue.main.async {
                            editingProfile=false
                        }
                    }) {
                        HStack {
                            Text("Cancel Changes")
                        }
                        .foregroundColor(.secondary)
                    }
                    .buttonStyle(PlainButtonStyle())
                }
                Spacer()
                HStack {
                    Spacer()

                    Button(action: {
                        client.hapticPress()
                        DispatchQueue.main.async {
                            // get all possible edits
                            // pass it
                            var userEditReq: [HttpReqKeyValue] = []
                            for edit in possibleEdits {
                                if (edit.updated == true) {
                                    if (edit.type == "String") {
                                        userEditReq.append(HttpReqKeyValue(key: edit.dbName, value: edit.newValueString))
                                    } else if (edit.type == "Date") {
                                        userEditReq.append(HttpReqKeyValue(key: edit.dbName, value: String(dateTimeFormatterInt64(date: edit.newValueDate))))
                                    }
                                }
                            }
                            
                            print(userEditReq)
                            Task {
                                let responseEdit = try await client.api.users.userEdit(userEditReq: userEditReq)
                                
                                self.editingResults = responseEdit
                                print(editingResults ?? "none edit profile view")
                                

                            }
                            editingProfile=false
                            showEditResults=true

//                            editingProfile=false
                        }
                    }) {
                        HStack {
                            Text("Publish Changes")
                        }
                        .foregroundColor(.primary)
                    }
                    .buttonStyle(PlainButtonStyle())
                }
                
                Spacer()
                
            }
            // editor
            VStack {
                if (doneLoading == true) {
                    ScrollView {
                        ForEach($possibleEdits) { change in
                            EditChange(client: client, change: change)
                        }
                        .padding(10)
                    }
                }
            }
        }
        .onAppear() {
            DispatchQueue.main.async {
                Task {
                    do {
                        possibleEdits = try await client.api.users.getUserEdit()
                        doneLoading = true;
                    } catch let error as ErrorData {
                        print("failed true" )
                        print(error)
                        if (error.code == "C022") {
                            print("already following")
                        }
                    } catch {
                        print("Unexpected error: \(error)")
                    }
                }
            }
        }
    }
}

struct BadgeCardView : View {
    @ObservedObject var client: Client
    @State var badgeData: BadgeData

    var body: some View {
        HStack {
            Spacer()
            VStack {
                Spacer()

                VStack {
                    Text(badgeData.name)
                    Text(badgeData.description)
                    Text("Achieved: " + int64TimeFormatter(timestamp: badgeData.achieved));
                    Spacer()
                }
                VStack {
                    if (badgeData.showCount==true) {
                        Text("Achieved " + String(badgeData.count) + " times")
                        Text("Lastest: " + int64TimeFormatter(timestamp: badgeData.latest ?? badgeData.achieved));
                        Spacer()
                    }
                }
                Spacer()

            }
            Spacer()
        }
        .padding(10)
        .interactCardSurface(
            cornerRadius: 20,
            lineWidth: 3,
            originalBackground: client.themeData.mainBackground,
            originalBorder: .gray
        )
    }
}


struct FollowingFollowerView: View {
    @ObservedObject var client: Client
    @State var userID: String? = ""
    
    @Binding var userFollowingList: UserFollowListData?
    @Binding var userFollowerList: UserFollowListData?
    @Binding var selectedFollowList: Int
    let followingLoadState: ProfileSectionLoadState
    let followersLoadState: ProfileSectionLoadState
    let refreshFollowing: () async -> Void
    let refreshFollowers: () async -> Void
    let followingLoadingNextIndex: Bool
    let followersLoadingNextIndex: Bool
    let loadNextFollowing: () -> Void
    let loadNextFollowers: () -> Void
    @State var isLoading: Bool = true
    @State var failed: Bool = false
    
    var body: some View {
        VStack {
            VStack {
                VStack {
                    Text("\(selectedFollowList == 0 ? "Following" : "Followers") List")
                    Button(action: {
                        client.hapticPress()
                        if (selectedFollowList==0) {
                            selectedFollowList=1
                        } else if (selectedFollowList==1) {
                            selectedFollowList=0
                        }
                    }) {
                        Text("Switch to \(selectedFollowList == 0 ? "Followers" : "Following") List")
                            .foregroundColor(.primary)
                            .padding(15)
                            .interactCardSurface(tone: .selected, cornerRadius: 20, lineWidth: 3, originalBorder: .accentColor)
                            .padding(5)
                    }
                    
                }
                if (selectedFollowList == 0) {
                    FollowingFollowerListView(client: client, userList: $userFollowingList, selectedFollowList: $selectedFollowList, loadState: followingLoadState, isLoadingNext: followingLoadingNextIndex, refreshAction: refreshFollowing, loadNextAction: loadNextFollowing)
                } else if (selectedFollowList == 1) {
                    FollowingFollowerListView(client: client, userList: $userFollowerList, selectedFollowList: $selectedFollowList, loadState: followersLoadState, isLoadingNext: followersLoadingNextIndex, refreshAction: refreshFollowers, loadNextAction: loadNextFollowers)
                }
            }
        }
    }
}

struct FollowingFollowerProfilePreview: View {
    @ObservedObject var client: Client
    @State var followDataPoint: UserFollowListDataPoint
    
    var body: some View {
        VStack {
            HStack {
                Text(followDataPoint.userData.displayName ?? "")
                    .foregroundColor(.secondary)
                Text("@" + (followDataPoint.userData.username ?? "unknown"))
                    .foregroundColor(.secondary)
                Spacer()
            }
            
            HStack {
                if let creationTimestamp = followDataPoint.userData.creationTimestamp {
                    Text("Joined " + int64TimeFormatter(timestamp: creationTimestamp))
                        .foregroundColor(.secondary)
                }

                Spacer()
            }
            
            if ((followDataPoint.userData.description) != nil) {
                HStack {
                    Text(followDataPoint.userData.description ?? "no description")
                        .foregroundColor(.secondary)
                    Spacer()
                }
            }
            
            HStack {
                Text(String(followDataPoint.userData.followingCount ?? 0) + " following |")
                Text(String(followDataPoint.userData.followerCount ?? 0) + " followers")
                Spacer()
            }
            
            HStack {
                Text("Followed: " + int64TimeFormatter(timestamp: followDataPoint.followData.timestamp))
                Spacer()
            }
            
            if let profileUserID = followDataPoint.userData._id, !profileUserID.isEmpty, client.userTokens.userID != profileUserID {
                Button(action: {
                    client.hapticPress()
                    DispatchQueue.main.async {
                        Task {
                            if (followDataPoint.userData.followed == true) {
                                do {
                                    _ = try await client.api.users.unFollowUser(userID: profileUserID)
                                    followDataPoint.userData.followed = false
                                } catch let error as ErrorData {
                                    print("ErrorData: \(error.code), \(error.msg)")
                                } catch {
                                    print("Unexpected error: \(error)")
                                }
                            } else {
                                do {
                                    _ = try await client.api.users.followUser(userID: profileUserID)
                                    followDataPoint.userData.followed = true
                                } catch let error as ErrorData {
                                    print("ErrorData: \(error.code), \(error.msg)")
                                } catch {
                                    print("Unexpected error: \(error)")
                                }
                            }
                        }
                    }
                }) {
                    HStack {
                        if (followDataPoint.userData.followed == true) {
                            Text("Unfollow User")
                        } else {
                            Text("Follow User")
                        }
                        Spacer()
                    }
                }
                .buttonStyle(PlainButtonStyle())
                
            }
        }
        .padding(15)
        .interactCardSurface(
            cornerRadius: 20,
            lineWidth: 3,
            originalBackground: client.themeData.mainBackground,
            originalBorder: .gray
        )

    }
}
struct FollowingFollowerListView: View {
    @ObservedObject var client: Client
    @Binding var userList: UserFollowListData?
    @Binding var selectedFollowList: Int
    let loadState: ProfileSectionLoadState
    let isLoadingNext: Bool
    let refreshAction: () async -> Void
    let loadNextAction: () -> Void

    var body: some View {
        VStack {
            let followRows = self.userList?.data ?? []

            List {
                switch loadState {
                case .loaded:
                    if followRows.isEmpty {
                        ProfileSectionStatusView(
                            state: .empty("No " + (selectedFollowList == 0 ? "following" : "followers") + " found."),
                            retryAction: nil
                        )
#if !os(tvOS)
                        .listRowSeparator(.hidden)
#endif
                        .listRowInsets(EdgeInsets())
                    } else {
                        ForEach(followRows, id: \.followData._id) { followDataPoint in
                            FollowingFollowerProfilePreview(client: client, followDataPoint: followDataPoint)
#if !os(tvOS)
                                .listRowSeparator(.hidden)
#endif
                                .listRowInsets(EdgeInsets())
                                .padding(10)
                                .onAppear(){
                                    client.hapticPress()
                                }

                        }
                        EmptyView()
                            .padding(.bottom, 40)

                        if userList?.prevIndexID != nil {
                            HStack {
                                Spacer()
                                if isLoadingNext {
                                    ProgressView()
                                } else {
                                    ProgressView()
                                        .opacity(0)
                                        .onAppear {
                                            loadNextAction()
                                        }
                                }
                                Spacer()
                            }
                            .padding(20)
#if !os(tvOS)
                            .listRowSeparator(.hidden)
#endif
                            .listRowInsets(EdgeInsets())
                        }
                    }
                default:
                    ProfileSectionStatusView(state: loadState) {
                        Task {
                            await refreshAction()
                        }
                    }
#if !os(tvOS)
                    .listRowSeparator(.hidden)
#endif
                    .listRowInsets(EdgeInsets())
                }
            }
            .listStyle(.plain)
#if !os(tvOS)
            .listRowSeparator(.hidden)
#endif
            .refreshable {
                client.hapticPress()
                await refreshAction()
            }
        }
        .onAppear() {
            print("onAppear, selectedFollowList: \(selectedFollowList)")
            print("if found and type is \(String(userList?.type ?? 3)) \(String(userList?.found ?? false))")
        }
    }
}
