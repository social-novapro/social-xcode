//
//  AdminStateData.swift
//  social-apple
//
//  Created by Daniel Kravec on 2024-04-11.
//

import Foundation

class AdminErrorFeed: ObservableObject {
    let client: Client

    @Published var errorIndex: ErrorIndexData = ErrorIndexData(indexID: "", timestamp: 0, foundIssues: [])
    @Published var issues: [ErrorIssueData] = []
    @Published var loadingScroll: Bool = false
    @Published @MainActor var isLoading: Bool = true
    @Published var gotFeed: Bool = false

    init(client: Client) {
        self.client = client
    }

    func getFeed() {
        DispatchQueue.main.async {
            if (self.gotFeed==true) {
                return
            }
            self.client.api.admin.errors.list() { result in
                print("allpost request")

                switch result {
                case .success(let feed):
                    DispatchQueue.main.async {
                        self.errorIndex = feed
                        self.addIssues(newIssues: self.errorIndex.foundIssues, toClear: true)
                        print("Done")
                        self.isLoading = false
                        self.gotFeed = true
                    }

                    print("Feed refreshed successfully.")

                case .failure(let error):
                    print("Error: \(error.localizedDescription)")
                }
            }
        }
    }

    func addIssues(newIssues: [ErrorIssueData], toClear:Bool=false) -> Void{
        var addIssues = newIssues
        addIssues.reverse()

        DispatchQueue.main.async {
            // due to new posts showing at bottom
            // could change that and fix it needing to be clear
            if (toClear==true) {
                self.issues = []
            }

            for newIssue in addIssues {
                if let existingIndex = self.issues.firstIndex(where: { $0._id == newIssue._id }) {
                    print("existing")
                    self.issues[existingIndex] = newIssue
                } else {
                    self.issues.append(newIssue)
                }
            }
        }
    }

    func refreshFeed() -> Void {
        DispatchQueue.main.async {
            self.client.api.admin.errors.list() { result in
                self.client.hapticPress()

                switch result {
                case .success(let feedData):
                    DispatchQueue.main.async {
                        self.errorIndex = feedData
                        self.addIssues(newIssues: self.errorIndex.foundIssues, toClear: true)
                    }
                case .failure(let error):
                    print("Error: \(error.localizedDescription)")
                }
            }
        }
    }

    func nextIndex() -> Void {
        DispatchQueue.main.async {
            self.client.api.admin.errors.list(indexID: self.errorIndex.prevIndexID ?? "") { result in
                self.client.hapticPress()

                switch result {
                case .success(let feed):
                    DispatchQueue.main.async {
                        self.errorIndex = feed
                        self.addIssues(newIssues: self.errorIndex.foundIssues, toClear: false)
                        self.loadingScroll = false
                    }
                case .failure(let error):
                    print("Error: \(error.localizedDescription)")
                }
            }
        }
    }
}
