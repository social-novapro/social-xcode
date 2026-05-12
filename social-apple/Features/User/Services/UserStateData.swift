//
//  UserStateData.swift
//  social-apple
//
//  Created by Daniel Kravec on 2023-04-19.
//

import Foundation

enum ProfileLoadState: Equatable {
    case loading
    case loaded
    case empty(String)
    case failed(String)
}

enum ProfileSection: Int, CaseIterable, Identifiable, Hashable {
    case quickInfo
    case badges
    case pins
    case posts
    case mentions
    case followLists

    var id: Int {
        rawValue
    }
}

enum ProfileSectionLoadState: Equatable {
    case loading
    case loaded
    case empty(String)
    case failed(String)
}

class ProfileViewClass: ObservableObject {
    var client: Client
    @Published var userID: String
    @Published var userData: UserData?

    @Published var postData: [AllPosts] = []
    @Published var pinData: [AllPosts] = []
    @Published var badgeData: [BadgeData] = []
    @Published var mentionData: [AllPosts] = []
    @Published var userDataFull: UserDataFull?
    @Published var followed: Bool = false

    @Published var loadState: ProfileLoadState = .loading
    @Published var postsLoadState: ProfileSectionLoadState = .loading
    @Published var pinsLoadState: ProfileSectionLoadState = .loading
    @Published var badgesLoadState: ProfileSectionLoadState = .loading
    @Published var mentionsLoadState: ProfileSectionLoadState = .loading

    @Published var doneLoading: Bool = false
    @Published var possibleFail: Bool = false
    @Published var isClient: Bool = false

    @Published var loadingNextIndex: Bool = false
    @Published var userPostIndexData: UserPostIndexData?

    private var activeProfileRequestID: UUID?

    init(client: Client, userData: UserData?, userID: String?) {
        self.client = client
        self.userID = userID ?? client.userTokens.userID
        self.userData = userData ?? nil
        if (userData?._id == client.userTokens.userID) {
            isClient = true;
        } else {
            isClient = false;
        }
    }

    func provBasic(userData: UserData) {
        self.userData = userData
        updateOwnershipState()
    }

    func ready() {
        loadProfile(clearContent: true)
    }

    func refreshProfile(section: ProfileSection? = nil, completion: (() -> Void)? = nil) {
        loadProfile(clearContent: section == nil, focusedSection: section, completion: completion)
    }

    func updateOwnershipState() {
        isClient = userData?._id == client.userTokens.userID

        postData = postData.map { postWithUpdatedOwnership($0) }
        pinData = pinData.map { postWithUpdatedOwnership($0) }
        mentionData = mentionData.map { postWithUpdatedOwnership($0) }
    }

    private func loadProfile(clearContent: Bool, focusedSection: ProfileSection? = nil, completion: (() -> Void)? = nil) {
        let requestUserID = self.userID.trimmingCharacters(in: .whitespacesAndNewlines)
        let requestID = UUID()

        DispatchQueue.main.async {
            self.activeProfileRequestID = requestID
            self.doneLoading = false
            self.possibleFail = false
            if let focusedSection {
                self.setSectionState(.loading, for: focusedSection)
            } else {
                self.loadState = .loading
                self.setProfileSectionStates(.loading)
            }
            self.loadingNextIndex = false
            self.userPostIndexData = nil
            if clearContent {
                self.postData = []
                self.pinData = []
                self.badgeData = []
                self.mentionData = []
            }
            self.updateOwnershipState()
        }

        guard !requestUserID.isEmpty else {
            DispatchQueue.main.async {
                guard self.activeProfileRequestID == requestID else {
                    completion?()
                    return
                }
                self.doneLoading = true
                self.possibleFail = true
                self.userData = nil
                if let focusedSection {
                    self.setSectionState(.failed("Profile unavailable."), for: focusedSection)
                } else {
                    self.loadState = .failed("We could not find a profile to load.")
                    self.setProfileSectionStates(.failed("Profile unavailable."))
                }
                completion?()
            }
            return
        }

        // check cache
        client.api.users.getUser(userID: requestUserID) { result in
            switch result {
            case .success(let results):
                print("Updating results")
                DispatchQueue.main.async {
                    guard self.activeProfileRequestID == requestID else {
                        completion?()
                        return
                    }

                    guard let resolvedID = results.userData._id, !resolvedID.isEmpty else {
                        self.doneLoading = true
                        self.possibleFail = true
                        self.userData = nil
                        if let focusedSection {
                            self.setSectionState(.empty("Nothing to show."), for: focusedSection)
                        } else {
                            self.loadState = .empty("This profile was not found.")
                            self.setProfileSectionStates(.empty("Nothing to show."))
                        }
                        completion?()
                        return
                    }

                    self.followed = results.extraData?.followed ?? false
                    self.userDataFull = results;
                    self.userData = results.userData;
                    self.userID = resolvedID
                    self.updateOwnershipState()
//                    self.postData = results.postData.reversed();
                    self.addPosts(newPosts: results.postData.reversed(), toClear: true)
                    self.pinData = results.pinData.reversed();
                    self.badgeData = results.badgeData?.reversed() ?? []
                    self.mentionData = results.mentionData?.reversed() ?? []
                    self.updateOwnershipState()
                    self.doneLoading = true
                    self.possibleFail = false
                    self.loadState = .loaded
                    self.postsLoadState = self.sectionState(isEmpty: self.postData.isEmpty, emptyMessage: "No posts yet.")
                    self.pinsLoadState = self.sectionState(isEmpty: self.pinData.isEmpty, emptyMessage: "No pins yet.")
                    self.badgesLoadState = self.sectionState(isEmpty: self.badgeData.isEmpty, emptyMessage: "No badges yet.")
                    self.mentionsLoadState = self.sectionState(isEmpty: self.mentionData.isEmpty, emptyMessage: "No mentions yet.")

                    self.userPostIndexData = results.userPostIndexData ?? nil;
                    completion?()
                }

                print(results)
            case .failure(let error):
                print("Error: \(error.localizedDescription)")
                DispatchQueue.main.async {
                    guard self.activeProfileRequestID == requestID else {
                        completion?()
                        return
                    }

                    let message = userFacingErrorMessage(error, fallback: "We could not load this profile.")
                    self.doneLoading = true
                    self.possibleFail = true
                    if let focusedSection {
                        self.setSectionState(.failed(message), for: focusedSection)
                    } else {
                        self.userData = nil
                        self.loadState = .failed(message)
                        self.setProfileSectionStates(.failed(message))
                    }
                    completion?()
                }
            }
        }
    }

    func nextUserPostsIndex() {
        DispatchQueue.main.async {
            if (self.loadingNextIndex == true) { return; }
            self.loadingNextIndex = true
            self.client.hapticPress()

            guard let prevIndexID = self.userPostIndexData?.prevIndexID else {
                print("no index data", self.userPostIndexData as Any)
                self.loadingNextIndex = false
                return;
            }

            var myIndexData:UserIndexDataRes?

            Task{
                do {
                    myIndexData = try await self.client.api.users.getNextUserPostIndex(indexID: prevIndexID)

                    self.userPostIndexData = myIndexData?.index ?? nil;
                    self.addPosts(newPosts: myIndexData?.posts.reversed() ?? [])

                    self.loadingNextIndex = false
                    self.client.hapticPress()
                } catch {
                    self.loadingNextIndex = false
                    print("Failed get user index: \(error.localizedDescription)")
                    return;
                }
            }
        }
    }

    // copied from PostData.swift
    func addPosts(newPosts: [AllPosts], toClear:Bool=false) -> Void {
        let applyPosts = {
            // due to new posts showing at bottom
            // could change that and fix it needing to be clear
            if (toClear==true) {
                self.postData = []
            }

            for var newPost in newPosts {
                newPost = self.postWithUpdatedOwnership(newPost)

                // this isnt working, will need to figure out, only in case of bad index going to server or getting from
                if let existingIndex = self.postData.firstIndex(where: { $0.postData._id == newPost.postData._id }) {
                    self.postData[existingIndex] = newPost
                } else {
                    self.postData.append(newPost)
                }
            }
        }

        if Thread.isMainThread {
            applyPosts()
        } else {
            DispatchQueue.main.async(execute: applyPosts)
        }
    }

    private func postWithUpdatedOwnership(_ post: AllPosts) -> AllPosts {
        var updatedPost = post
        updatedPost.postLiveData.isOwner = updatedPost.postData.userID == self.client.userTokens.userID
        return updatedPost
    }

    private func sectionState(isEmpty: Bool, emptyMessage: String) -> ProfileSectionLoadState {
        isEmpty ? .empty(emptyMessage) : .loaded
    }

    private func setProfileSectionStates(_ state: ProfileSectionLoadState) {
        postsLoadState = state
        pinsLoadState = state
        badgesLoadState = state
        mentionsLoadState = state
    }

    private func setSectionState(_ state: ProfileSectionLoadState, for section: ProfileSection) {
        switch section {
        case .badges:
            badgesLoadState = state
        case .pins:
            pinsLoadState = state
        case .posts:
            postsLoadState = state
        case .mentions:
            mentionsLoadState = state
        case .quickInfo, .followLists:
            break
        }
    }
}
