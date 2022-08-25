//
//  AuthenticationRequest.swift
//  GCoreVODsDemo
//
//  Created by Evgenij Polubin on 18.07.2022.
//

import Foundation

struct AuthenticationRequest: DataRequest {
    typealias Response = Tokens
    
    let username: String
    let password: String
    
    var url: String { GCoreAPI.authorization.rawValue }
    var method: HTTPMethod { .post }
    
    var body: Data? {
       try? JSONEncoder().encode([
        "password": password,
        "username": username,
       ])
    }
}
