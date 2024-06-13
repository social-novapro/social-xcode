//
//  BasicData.swift
//  social-apple
//
//  Created by Daniel Kravec on 2024-01-12.
//

import Foundation



//var found = {
//    usersFound,
//    postsFound
//};

struct HapticModeData: Decodable, Encodable {
    var isEnabled: Bool
}

enum API: Error {
    case invalidResponse
    case decodingError(Error)
    // Add more cases as needed for specific error types in your API interactions
}
