//
//  File.swift
//  
//
//  Created by Simon Zwicker on 07.08.23.
//

public enum ZNHeader {
    case Cookie
}

extension ZNHeader {
    var key: String {
        switch self {
        case .Cookie: return "Cookie"
        }
    }

    var value: String {
        switch self {
        default: return ""
        }
    }
}
