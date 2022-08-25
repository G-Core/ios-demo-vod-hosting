//
//  DataRequest.swift
//  GCoreVODsDemo
//
//  Created by Evgenij Polubin on 18.07.2022.
//

import Foundation

protocol DataRequest {
    associatedtype Response
    
    var url: String { get }
    var method: HTTPMethod { get }
    var headers: [String : String] { get }
    var queryItems: [String : String] { get }
    var body: Data? { get }
    var contentType: String { get }
    
    func decode(_ data: Data) throws -> Response
}

extension DataRequest where Response: Decodable {
    func decode(_ data: Data) throws -> Response {
        let decoder = JSONDecoder()
        return try decoder.decode(Response.self, from: data)
    }
}

extension DataRequest {
    var contentType: String { "application/json" }
    var headers: [String : String] { [:] }
    var queryItems: [String : String] { [:] }
    var body: Data? { nil }
}
