//
//  GCoreAPI.swift
//  GCoreVODsDemo
//
//  Created by Evgenij Polubin on 18.07.2022.
//

import Foundation

enum GCoreAPI: String {
    case authorization = "https://api.gcorelabs.com/iam/auth/jwt/login"
    case videos = "https://api.gcorelabs.com/streaming/videos"
    case refreshToken = "https://api.gcorelabs.com/iam/auth/jwt/refresh"
}

