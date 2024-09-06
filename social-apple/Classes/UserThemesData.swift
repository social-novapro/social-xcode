//
//  UserThemesData.swift
//  social-apple
//
//  Created by Daniel Kravec on 2024-02-11.
//

import Foundation


struct ThemeExportedIndex: Decodable {
    var indexID: String
    var nextIndexID: String?
    var prevIndexID: String?
    var themes: [String]
//    var users: UserData
    // how tf do i access this 
}
