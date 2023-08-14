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
    case FormData(String)
    case Encoding
}

extension ZNHeader {
    var key: String {
        switch self {
        case .Cookie: return "Cookie"
        case .ContentJson, .FormData: return "Content-Type"
        case .AuthBearer: return "Authorization"
        case .Encoding: return "Content-Transfer-Encoding"
        }
    }

    var value: String {
        switch self {
        case .ContentJson: return "application/json"
        case let .AuthBearer(token): return "Bearer \(token)"
        case let .FormData(uuid): return "multipart/form-data; boundary=\(uuid)"
        case .Encoding: return "base64"
        default: return ""
        }
    }
}
