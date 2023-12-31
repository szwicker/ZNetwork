//
//  File.swift
//  
//
//  Created by Simon Zwicker on 07.08.23.
//

public enum ZNetworkError: Error {
    case decode
    case invalidURL
    case noResponse
    case noData(Codable)
    case unauthorized(Codable)
    case unexpectedStatusCode(Codable)
    case unknown

    var customMessage: String {
        switch self {
        case .decode:
            return "Decode error"
        case .unauthorized:
            return "Session expired"
        default:
            return "Unknown error"
        }
    }
}
