//
//  LocalLogData.swift
//  social-apple
//
//  Created by Daniel Kravec on 2023-12-04.
//

import Foundation

struct LocalLogData: Decodable, Encodable {
    var id: UUID
    var userId: String? = nil
    var code: String? = nil
    var desc: String? = nil
    var location: String? = nil
    var timestamp: Int64? = nil
}
