//
//  AdminModelsData.swift
//  social-apple
//
//  Created by Daniel Kravec on 2024-04-11.
//

import Foundation

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
