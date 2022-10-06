//
//  ErrorResponse.swift
//  GCoreVodDemo
//
//  Created by Evgenij Polubin on 18.07.2022.
//

import Foundation

enum ErrorResponse: Error {
    case invalidToken
    case unexpectedError
    case invalidCredentials
    
    static var invalidEndPoint: NSError {
        .init(domain: "Invalid end point", code: 404, userInfo: nil)
    }

    var description: String {
        switch self {
        case .invalidToken: return "Invalid token"
        case .unexpectedError: return "Unexpected error"
        case .invalidCredentials: return "Invalid username or password"
        }
    }
}
