//
//  File.swift
//  
//
//  Created by Simon Zwicker on 07.08.23.
//

public struct ZNetworkComponent {
    var scheme: String
    var host: String
    var path: String

    public init(scheme: String, host: String, path: String) {
        self.scheme = scheme
        self.host = host
        self.path = path
    }
}
