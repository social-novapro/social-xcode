//
//  ErrorData.swift
//  social-apple
//
//  Created by Daniel Kravec on 2023-04-20.
//

import Foundation


enum APIError: Error {
    case code
    case msg
    case decodingError(Error)
    // Add more cases as needed for specific error types in your API interactions
}

struct ErrorData : Codable, Error {
    let code: String
    let msg: String
    let error: Bool

    init (code: String, msg: String, error: Bool) {
        self.code = code
        self.msg = msg
        self.error = error
    }
}

extension ErrorData: LocalizedError {
    var errorDescription: String? {
        msg
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

extension ErrorDataWithAuth: LocalizedError {
    var errorDescription: String? {
        error.msg
    }
}

func userFacingErrorMessage(_ error: Error, fallback: String) -> String {
    if let apiError = error as? ErrorData, !apiError.msg.isEmpty {
        return apiError.msg
    }
    
    if let authError = error as? ErrorDataWithAuth, !authError.error.msg.isEmpty {
        return authError.error.msg
    }
    
    let nsError = error as NSError
    if nsError.domain == NSURLErrorDomain {
        return "We couldn't reach Interact. Check your connection and try again."
    }
    
    let message = error.localizedDescription
    if message.isEmpty || message.contains("com.example.error") {
        return fallback
    }
    
    return message
}

struct ApiHeader: Decodable {
    let value: String
    let field: String
}

struct ErrorUserEdit: Identifiable, Encodable, Decodable, Error {
    var id = UUID()
    
    var field: String
    
    var code: String
    var msg: String
    var error: Bool
    
    init (field: String, code: String, msg: String, error: Bool) {
        self.field = field
        self.code = code
        self.msg = msg
        self.error = error
    }
}
