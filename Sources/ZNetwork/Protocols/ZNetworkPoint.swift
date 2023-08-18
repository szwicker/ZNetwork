//
//  File.swift
//  
//
//  Created by Simon Zwicker on 07.08.23.
//

public protocol ZNetworkPoint {
    var path: String { get }
    var method: ZNMethod { get }
    var headers: [ZNHeader] { get }
    var parameters: [String: Any] { get }
    var encoding: ZNEncoding { get }
    var boundary: String { get }
}
