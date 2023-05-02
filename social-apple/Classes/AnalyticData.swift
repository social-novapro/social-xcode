//
//  AnalyticData.swift
//  social-apple
//
//  Created by Daniel Kravec on 2023-05-01.
//

import Foundation

struct UserConectionData: Decodable {
    var id = UUID()
    var _id: String? = nil
    var timestamp: String? = nil
    var api_urlbase: String? = nil
    var api_url: String? = nil
    
    private enum CodingKeys: String, CodingKey {
        case _id
        case timestamp
        case api_urlbase
        case api_url
    }
}

struct AnalyticTrendDataPoint: Decodable, Identifiable {
    var id = UUID()
    var _id: String? = nil
    var __v: Int64? = nil
    var userConnections: [UserConectionData]? = nil
    
    private enum CodingKeys: String, CodingKey {
        case _id
        case __v
        case userConnections
    }
}
