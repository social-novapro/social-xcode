//
//  AdminErrorView.swift
//  social-apple
//
//  Created by Daniel Kravec on 2024-04-11.
//

import SwiftUI

struct AdminErrorView: View {
    @ObservedObject var client: Client
    @ObservedObject var adminErrorFeed: AdminErrorFeed
    
    var body: some View {
        VStack {
            if (self.adminErrorFeed.isLoading == false) {
                List {
                    ForEach(self.adminErrorFeed.issues.indices, id: \.self) { index in
                        VStack {
                            AdminErrorIssueView(client: client, issueData: $adminErrorFeed.issues[index])
                        }
#if !os(tvOS)
                        .listRowSeparator(.hidden)
#endif
                        .listRowInsets(EdgeInsets())
                        .padding(10)
                        .onAppear(){
                            if (self.adminErrorFeed.errorIndex.foundIssues.last?.id == adminErrorFeed.issues[index].id && self.adminErrorFeed.loadingScroll == false) {
                                client.hapticPress()
                                self.adminErrorFeed.loadingScroll = true
                                
                                if (self.adminErrorFeed.errorIndex.prevIndexID != nil) {
                                    DispatchQueue.main.async {
                                        adminErrorFeed.nextIndex()
                                    }
                                }
                            }
                        }
                    }
                }
#if !os(tvOS)
                .listStyle(.plain)
                .listRowSeparator(.hidden)
#endif
                .refreshable {
                    client.hapticPress()
                    DispatchQueue.main.async {
                        adminErrorFeed.refreshFeed()
                    }
                }
            }
            else {
                Text("loading errors")
            }
        }
        .onAppear {
            self.adminErrorFeed.getFeed()
            self.adminErrorFeed.isLoading = false
        }
        .navigationTitle("Admin Issues")
    }
}

struct AdminErrorIssueView : View {
    @ObservedObject var client: Client
    @Binding var issueData: ErrorIssueData
    
    var body: some View {
        VStack {
            VStack {
                HStack {
                    Text(issueData.errorCode+" - "+issueData.errorMsg)
                    Spacer()
                }
                HStack {
                    Text(int64TimeFormatter(timestamp: issueData.timestamp))
                    Spacer()
                }
            }
            .padding(15)
            .background(client.themeData.mainBackground)
            .cornerRadius(20)
            .overlay(
                RoundedRectangle(cornerRadius: 20)
                    .stroke(Color.gray, lineWidth: 3)
            )
            AdminErrorIssueSubData(client: client, issueData: $issueData)
        }
        .padding(15)
        .background(client.themeData.mainBackground)
        .cornerRadius(20)
        .overlay(
            RoundedRectangle(cornerRadius: 20)
                .stroke(Color.gray, lineWidth: 3)
        )
    }
}

struct AdminErrorIssueSubData : View {
    @ObservedObject var client: Client
    @Binding var issueData: ErrorIssueData

    var body: some View {
        VStack {
            VStack {
                if (issueData.inReview == true) {
                    HStack {
                        Text("In review")
                        Spacer()
                    }
                    HStack {
                        Text("Reviewer: " + (issueData.reviewedBy ?? ""))
                        Spacer()
                    }
                    HStack {
                        Text(int64TimeFormatter(timestamp: issueData.reviewTimestamp ?? 0))
                        Spacer()
                    }
                } else {
                    HStack {
                        Text("Not under review")
                        Spacer()
                    }
                }
            }
            VStack {
                if (issueData.resolved == true) {
                    Text("Resolved")
                    Text("Reviewer: " + (issueData.reviewedBy ?? ""))
                    Text(int64TimeFormatter(timestamp: issueData.resolvedTimestamp ?? 0))
                } else {
                    HStack {
                        Text("Unresolved")
                        Spacer()
                    }
                }
            }
            VStack {
                HStack {
                    if ((issueData.userID) != nil) {
                        Text("userID: " + (issueData.userID ?? ""))
                    } else {
                        Text("Unknown userID")
                    }
                    Spacer()
                }
            }
        }
        .padding(15)
        .background(client.themeData.mainBackground)
        .cornerRadius(20)
        .overlay(
            RoundedRectangle(cornerRadius: 20)
                .stroke(Color.gray, lineWidth: 3)
        )
    }
}
