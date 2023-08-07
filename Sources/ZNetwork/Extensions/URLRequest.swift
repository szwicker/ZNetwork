//
//  File.swift
//  
//
//  Created by Simon Zwicker on 07.08.23.
//

import Foundation

extension URLRequest {
    public func curlCommand() -> String {
        guard let url else { return "" }
        var command = ["curl \"\(url.absoluteString)\""]

        if let httpMethod, httpMethod != Method.GET.rawValue, httpMethod != Method.HEAD.rawValue {
            command.append("-x \(httpMethod)")
        }

        allHTTPHeaderFields?
            .filter { $0.key != Header.Cookie.key }
            .forEach { command.append("-H '\($0.key): \($0.value)'") }

        if let httpBody, let body = String(data: httpBody, encoding: .utf8) {
            command.append("-d \(body)")
        }

        return command.joined(separator: " \\\n\t")
    }
}
