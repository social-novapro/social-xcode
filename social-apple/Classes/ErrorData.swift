//
//  ErrorData.swift
//  social-apple
//
//  Created by Daniel Kravec on 2023-04-20.
//

import Foundation

struct ErrorData : Decodable, Error {
    let code: String
    let msg: String
    let error: Bool

    init (code: String, msg: String, error: Bool) {
        self.code = code
        self.msg = msg
        self.error = error
    }
}

struct ErrorDataWithAuth: Decodable, Error {
    let authorized: Bool
    let error: ErrorData
    
    init (authorized: Bool, error: ErrorData) {
        self.authorized = authorized
        self.error = error
    }
}

struct ApiHeader: Decodable {
    let value: String
    let field: String
}
