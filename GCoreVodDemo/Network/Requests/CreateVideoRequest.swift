//
//  CreateVideoRequest.swift
//  GCoreVodDemo
//
//  Created by Evgenij Polubin on 10.08.2022.
//

import Foundation

struct CreateVideoRequest: DataRequest {
    typealias Response = VOD
    
    let token: String
    let videoName: String
    
    var url: String { GCoreAPI.videos.rawValue }
    var method: HTTPMethod { .post }
    
    var headers: [String: String] {
        [ "Authorization" : "Bearer \(token)" ]
    }
    
    var body: Data? {
       try? JSONEncoder().encode([
        "name": videoName
       ])
    }
}
