//
//  AdminData.swift
//  social-apple
//
//  Created by Daniel Kravec on 2024-04-11.
//

import Foundation

class AdminErrorFeed: ObservableObject {
//    @ObservedObject var client: ApiClient
    let client: ApiClient

    @Published var errorIndex: ErrorIndexData = ErrorIndexData(indexID: "", timestamp: 0, foundIssues: [])
    @Published var issues: [ErrorIssueData] = []
    @Published var loadingScroll: Bool = false
    @Published @MainActor var isLoading: Bool = true
    @Published var gotFeed: Bool = false

    init(client: ApiClient) {
        self.client = client
    }

    func getFeed() {
        DispatchQueue.main.async {
            if (self.gotFeed==true) {
                return
            }
            self.client.admin.errors.list() { result in
                print("allpost request")
                
                switch result {
                case .success(let feed):
                    DispatchQueue.main.async {
                        self.errorIndex = feed
                        self.errorIndex.foundIssues.reverse()
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
        DispatchQueue.main.async {
            // due to new posts showing at bottom
            // could change that and fix it needing to be clear
            if (toClear==true) {
                self.issues = []
            }
            
            for newIssue in newIssues {
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
            self.client.admin.errors.list() { result in
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
            self.client.admin.errors.list(indexID: self.errorIndex.prevIndexID ?? "") { result in
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
struct ErrorIndexData: Decodable {
    var indexID: String
    var nextIndexID: String? = nil
    var prevIndexID: String? = nil
    var amount: Int64? = 0
    var timestamp: Int64
    var foundIssues: [ErrorIssueData]
}


struct ErrorIssueData: Decodable, Identifiable, Equatable {
    static func == (lhs: ErrorIssueData, rhs: ErrorIssueData) -> Bool {
        return (lhs._id == rhs._id)
    }
    
    var id = UUID()
    var _id: String
    var userID: String? = ""
    var errorVersion: Int64
    var errorCode: String
    var errorMsg: String
    var timestamp: Int64
    var resolved: Bool
    var resolvedTimestamp: Int64? = nil
    var inReview: Bool
    var reviewedBy: String? = nil
    var reviewTimestamp: Int64? = nil
    var reviewHistory: [ErrorIssueHistory]? = []
    
    private enum CodingKeys: String, CodingKey {
        case _id
        case userID
        case errorVersion
        case errorCode
        case errorMsg
        case timestamp
        case resolved
        case resolvedTimestamp
        case inReview
        case reviewedBy
        case reviewTimestamp
        case reviewHistory
    }

}

struct ErrorIssueHistory: Decodable {
    var _id: String
    var reviewBy: String
    var reviewStart: Int64
    var reviewEnd: Int64
    var resolvedTimestamp: Int64
}
