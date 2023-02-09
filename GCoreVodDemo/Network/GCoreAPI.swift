//
//  GCoreAPI.swift
//  GCoreVodDemo
//
//  Created by Evgenij Polubin on 18.07.2022.
//

import Foundation

enum GCoreAPI: String {
    case authorization = "https://api.gcore.com/iam/auth/jwt/login"
    case videos = "https://api.gcore.com/streaming/videos"
    case refreshToken = "https://api.gcore.com/iam/auth/jwt/refresh"
}
