//
//  ErrorData.swift
//  social-apple
//
//  Created by Daniel Kravec on 2023-04-20.
//

import Foundation

struct ErrorData : Decodable {
    let code: String
    let msg: String

    init (code: String, msg: String) {
        self.code = code
        self.msg = msg
    }
}

struct ErrorDataWithAuth: Decodable {
    let authorized: Bool
    let error: ErrorData
    
    init (authorized: Bool, error: ErrorData) {
        self.authorized = authorized
        self.error = error
    }
}
