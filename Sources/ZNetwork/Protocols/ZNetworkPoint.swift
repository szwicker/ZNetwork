//
//  File.swift
//  
//
//  Created by Simon Zwicker on 07.08.23.
//

public protocol ZNetworkPoint {
    var path: String { get }
    var method: Method { get }
    var headers: [Header] { get }
    var parameters: [String: String] { get }
    var encoding: Encoding { get }
}
