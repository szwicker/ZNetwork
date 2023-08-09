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

    func run<T: Codable>(_ point: ZNetworkPoint) async -> Result<T, ZNetworkError> {
        return await call(point)
    }
}

// MARK: - Service Runable Commands
extension ZNetworkService {
    private func call<T: Codable>(_ point: ZNetworkPoint) async -> Result<T, ZNetworkError> {
        guard var baseComponent else { return .failure(.invalidURL(0)) }
        if !point.parameters.isEmpty, point.encoding == .url {
            baseComponent.queryItems = encodeUrl(params: point.parameters)
        }
        baseComponent.path += point.path
        guard let urlString = baseComponent.url?.absoluteString, let url = URL(string: urlString) else { return .failure(.invalidURL(0)) }

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
                return .failure(.noResponse(0))
            }
            ZNetwork.logger.log(response, data: data)
            switch response.statusCode {
            case 200...299:
                guard let decodedResponse = try? JSONDecoder().decode(T.self, from: data) else {
                    return .failure(.decode(response.statusCode))
                }
                return .success(decodedResponse)
            case 401:
                return .failure(.unauthorized(response.statusCode))

            case 404:
                return .failure(.noData(response.statusCode))

            default:
                return .failure(.unexpectedStatusCode(response.statusCode))
            }
        } catch {
            return .failure(.unknown(0))
        }
    }

    private func encodeJson(params: [String: String]) -> Data? {
        return try? JSONSerialization.data(withJSONObject: params, options: [])
    }

    private func encodeUrl(params: [String: String]) -> [URLQueryItem] {
        return params.map { URLQueryItem(name: $0.key, value: $0.value) }
    }
}
