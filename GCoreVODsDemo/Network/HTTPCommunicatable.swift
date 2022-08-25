//
//  NetworkManager.swift
//  GCoreVODsDemo
//
//  Created by Evgenij Polubin on 18.07.2022.
//

import Foundation

protocol HTTPCommunicatable {
    func request<Request: DataRequest>(
        _ request: Request,
        completion: @escaping (Result<Request.Response, Error>) -> Void
    )
}


