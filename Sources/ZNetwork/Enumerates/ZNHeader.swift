//
//  File.swift
//  
//
//  Created by Simon Zwicker on 07.08.23.
//

public enum ZNHeader {
    case Cookie
    case ContentJson
    case AuthBearer(String)
    case FormData
}

extension ZNHeader {
    var key: String {
        switch self {
        case .Cookie: return "Cookie"
        case .ContentJson: return "Content-Type"
        case .AuthBearer: return "Authorization"
        case .FormData: return "Content-Type"
        }
    }

    var value: String {
        switch self {
        case .ContentJson: return "application/json"
        case let .AuthBearer(token): return "Bearer \(token)"
        case .FormData: return "multipart/form-data"
        default: return ""
        }
    }
}
