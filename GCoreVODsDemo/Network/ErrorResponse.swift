//
//  ErrorResponse.swift
//  GCoreVODsDemo
//
//  Created by Evgenij Polubin on 18.07.2022.
//

import Foundation

enum ErrorResponse: String, Error {
    case invalidToken = "Invalid token"
    case unexpectedError = "Unexpected error"
    case invalidCredentials = "Invalid username or password"
    
    static var invalidEndPoint: NSError {
        .init(domain: "Invalid end point", code: 404, userInfo: nil)
    }
}
