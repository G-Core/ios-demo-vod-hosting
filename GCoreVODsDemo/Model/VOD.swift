//
//  VOD.swift
//  GCoreVODsDemo
//
//  Created by Evgenij Polubin on 18.07.2022.
//

import Foundation

struct VOD: Decodable {
    let name: String
    let id: Int
    let screenshot: URL?
    let hls: URL?
    
    enum CodingKeys: String, CodingKey {
        case name, id, screenshot
        case hls = "hls_url"
    }
}

struct Tokens: Decodable {
    let refresh: String
    let access: String
}
