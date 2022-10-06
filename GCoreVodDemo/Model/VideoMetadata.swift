//
//  VideoMetadata.swift
//  GCoreVodDemo
//
//  Created by Evgenij Polubin on 10.08.2022.
//

import Foundation

struct VideoMetadata: Decodable {
    struct Server: Decodable {
        let hostname: String
    }
    
    struct Video: Decodable {
        let name: String
        let id: Int
        let clientID: Int
        
        enum CodingKeys: String, CodingKey {
            case name, id
            case clientID = "client_id"
        }
    }
    
    let servers: [Server]
    let video: Video
    let token: String
    
    var uploadURLString: String {
        "https://" + (servers.first?.hostname ?? "") + "/upload"
    }
}
