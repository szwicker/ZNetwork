//
//  File.swift
//  
//
//  Created by Simon Zwicker on 07.08.23.
//

import Foundation

public enum ZNHeader: Equatable {
    case Cookie
    case ContentJson
    case AuthBearer(String)
    case FormData
    case Boundary
}

extension ZNHeader {
    var key: String {
        switch self {
        case .Cookie: return "Cookie"
        case .ContentJson: return "Content-Type"
        case .AuthBearer: return "Authorization"
        case .FormData: return "Content-Type"
        case .Boundary: return "boundary"
        }
    }

    var value: String {
        switch self {
        case .ContentJson: return "application/json"
        case let .AuthBearer(token): return "Bearer \(token)"
        case .FormData: return "multipart/form-data"
        case .Boundary: return UUID().uuidString
        default: return ""
        }
    }
}
