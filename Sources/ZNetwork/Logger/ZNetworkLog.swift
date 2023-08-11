//
//  File.swift
//  
//
//  Created by Simon Zwicker on 07.08.23.
//

import Foundation

class ZNetworkLog {
    var logLevel: LogLevel = .none

    func log(_ request: URLRequest) {
        guard logLevel != .none else { return }

        if let method = request.httpMethod, let url = request.url {
            print("ZNetwork Networkcall: \(method) - '\(url.absoluteString)'")
            logHeaders(request)
            logBody(request)
        }

        if logLevel == .debugCurl {
            logCurl(request)
        }
    }

    func log(_ response: URLResponse, data: Data) {
        guard logLevel != .none else { return }
        if let response = response as? HTTPURLResponse {
            logStatusCodeUrl(response)
        }

        if logLevel == .debug {
            print("ZNetwork Response:")
            print(String(decoding: data, as: UTF8.self))
        }
    }

    // MARK: - Private Functions
    private func logHeaders(_ request: URLRequest) {
        guard let headerFields = request.allHTTPHeaderFields else { return }
        print("ZNetwork Headers:")
        headerFields.forEach { print("[key: \"\($0.key)\"]: \"\($0.value)\"") }
    }

    private func logBody(_ request: URLRequest) {
        guard let body = request.httpBody, let string = String(data: body, encoding: .utf8) else { return }
        print("ZNetwork Body:")
        print(string)
    }

    private func logStatusCodeUrl(_ response: HTTPURLResponse) {
        print("ZNetwork StatusCode: \(response.statusCode)")
    }

    private func logCurl(_ request: URLRequest) {
        print("ZNetwork Curl Command: \(request.curlCommand())")
    }
}
