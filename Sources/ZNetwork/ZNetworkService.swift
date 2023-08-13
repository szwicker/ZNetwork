//
//  File.swift
//  
//
//  Created by Simon Zwicker on 07.08.23.
//

import Foundation
import Combine

class ZNetworkService {

    // MARK: - Static Properties
    static let shared = ZNetworkService()

    // MARK: - Private Properties
    private var baseURL: URL?
    private var baseURLString: String?
    private var baseComponent: URLComponents?
    private var timeout: TimeInterval?

    // MARK: - BaseURL
    func configure(with url: String, timeout: TimeInterval? = nil) {
        self.baseURL = URL(string: url)
        self.baseURLString = url
        self.timeout = timeout
    }

    func configure(with component: ZNetworkComponent, timeout: TimeInterval? = nil) {
        var urlComp = URLComponents()
        urlComp.scheme = component.scheme
        urlComp.host = component.host
        urlComp.path = component.path

        self.baseURL = urlComp.url
        self.baseURLString = urlComp.string
        self.timeout = timeout
        self.baseComponent = urlComp
    }

    func run<T: Codable>(_ point: ZNetworkPoint, error: Codable.Type) async -> Result<T?, ZNetworkError> {
        return await call(point, error: error)
    }
}

// MARK: - Service Runable Commands
extension ZNetworkService {
    private func call<T: Codable>(_ point: ZNetworkPoint, error: Codable.Type) async -> Result<T?, ZNetworkError> {
        guard var baseComponent else { return .failure(.invalidURL) }
        if !point.parameters.isEmpty, point.encoding == .url {
            baseComponent.queryItems = encodeUrl(params: point.parameters)
        }
        baseComponent.path += point.path
        guard let urlString = baseComponent.url?.absoluteString, let url = URL(string: urlString) else { return .failure(.invalidURL) }

        var request = URLRequest(url: url)
        if !point.parameters.isEmpty, point.encoding == .json {
            request.httpBody = encodeJson(params: point.parameters)
        }
        request.httpMethod = point.method.rawValue
        point.headers.forEach { request.setValue($0.value, forHTTPHeaderField: $0.key) }
        ZNetwork.logger.log(request)

        do {
            let (data, response) = try await URLSession.shared.data(for: request, delegate: nil)
            guard let response = response as? HTTPURLResponse else {
                return .failure(.noResponse)
            }
            ZNetwork.logger.log(response, data: data)
            switch response.statusCode {
            case 204:
                let emptyResponse = try? JSONDecoder().decode(T.self, from: Data())
                return .success(emptyResponse)
            case 200...299:
                guard let decodedResponse = try? JSONDecoder().decode(T.self, from: data) else {
                    return .failure(.decode)
                }
                return .success(decodedResponse)
            case 401:
                guard let decodedError = try? JSONDecoder().decode(error, from: data) else {
                    return .failure(.decode)
                }
                return .failure(.unauthorized(decodedError))

            case 404:
                guard let decodedError = try? JSONDecoder().decode(error, from: data) else {
                    return .failure(.decode)
                }
                return .failure(.noData(decodedError))

            default:
                guard let decodedError = try? JSONDecoder().decode(error, from: data) else {
                    return .failure(.decode)
                }
                return .failure(.unexpectedStatusCode(decodedError))
            }
        } catch {
            return .failure(.unknown)
        }
    }

    private func encodeJson(params: [String: String]) -> Data? {
        return try? JSONSerialization.data(withJSONObject: params, options: [])
    }

    private func encodeUrl(params: [String: String]) -> [URLQueryItem] {
        return params.map { URLQueryItem(name: $0.key, value: $0.value) }
    }
}
