//
//  VODRequest.swift
//  GCoreVodDemo
//
//  Created by Evgenij Polubin on 09.08.2022.
//

import Foundation

struct VODRequest: DataRequest {
    typealias Response = [VOD]
    
    let token: String
    let page: Int
    
    var url: String { GCoreAPI.videos.rawValue }
    var method: HTTPMethod { .get }
    
    var headers: [String: String] {
        [ "Authorization" : "Bearer \(token)" ]
    }
    
    var queryItems: [String: String] {
        [
            // q[status_eq] is used to download only ready-to-watch videos
            "q[status_eq]": String(3),
            "page": String(page),
        ]
    }
}
