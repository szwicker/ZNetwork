//
//  File.swift
//  
//
//  Created by Simon Zwicker on 07.08.23.
//

public enum ZNetworkError: Error {
    case decode(Int)
    case invalidURL(Int)
    case noResponse(Int)
    case noData(Int)
    case unauthorized(Int)
    case unexpectedStatusCode(Int)
    case unknown(Int)

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

    var statusCode: Int {
        switch self {
        case .decode(let int):
            return int
        case .invalidURL(let int):
            return int
        case .noResponse(let int):
            return int
        case .noData(let int):
            return int
        case .unauthorized(let int):
            return int
        case .unexpectedStatusCode(let int):
            return int
        case .unknown(let int):
            return int
        }
    }
}
