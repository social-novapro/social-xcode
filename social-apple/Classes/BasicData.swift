//
//  BasicData.swift
//  social-apple
//
//  Created by Daniel Kravec on 2024-01-12.
//

import Foundation


struct SearchLookupData: Encodable {
    var lookupkey: String
}

struct SearchFoundData: Decodable {
    var usersFound: [UserData]?
    var postsFound: [AllPosts]?
}
//var found = {
//    usersFound,
//    postsFound
//};
