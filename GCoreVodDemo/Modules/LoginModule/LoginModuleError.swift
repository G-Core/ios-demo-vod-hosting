//
//  File.swift
//  GCoreVodDemo
//
//  Created by Evgenij Polubin on 19.07.2022.
//

import Foundation

enum LoginModuleError: Error {
    case emptyTextFields

    var description: String {
        switch self {
        case .emptyTextFields:
            return "Need to fill in all the fields"
        }
    }
}
