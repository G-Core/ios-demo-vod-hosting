//
//  VOD.swift
//  GCoreVodDemo
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

extension VOD {
    static var mock: [VOD] {
        guard let url = Bundle.main.url(forResource: "VodMock.json", withExtension: nil) else {
            fatalError("Failed to locate VodMock.json in bundle.")
        }

        guard let data = try? Data(contentsOf: url) else {
            fatalError("Failed to load VodMock.json) from bundle.")
        }

        return try! JSONDecoder().decode([VOD].self, from: data)
    }
}
