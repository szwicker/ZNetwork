//
//  File.swift
//  
//
//  Created by Simon Zwicker on 07.08.23.
//

public enum ZNHeader {
    case Cookie
    case ContentJson
}

extension ZNHeader {
    var key: String {
        switch self {
        case .Cookie: return "Cookie"
        case .ContentJson: return "Content-Type"
        }
    }

    var value: String {
        switch self {
        case .ContentJson: return "application/json"
        default: return ""
        }
    }
}
