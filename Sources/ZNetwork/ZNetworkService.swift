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
    private var allowedCharacterSet = CharacterSet.urlQueryAllowed

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
        self.allowedCharacterSet.remove(charactersIn: "=")
    }

    func run<T: Codable>(_ point: ZNetworkPoint) -> AnyPublisher<T, Error> {
        return call(point)
    }
}

// MARK: - Service Runable Commands
extension ZNetworkService {
    private func call<T: Codable>(_ point: ZNetworkPoint) -> AnyPublisher<T, Error> {
        guard var baseComponent else { fatalError() }
        if !point.parameters.isEmpty, point.encoding == .url {
            baseComponent.queryItems = encodeUrl(params: point.parameters)
        }
        baseComponent.path += point.path
        guard let urlString = baseComponent.url?.absoluteString, let url = URL(string: urlString) else { fatalError() }
        var request = URLRequest(url: url)

        if !point.parameters.isEmpty, point.encoding == .json {
            request.httpBody = encodeJson(params: point.parameters)
        }

        request.httpMethod = point.method.rawValue
        point.headers.forEach { request.setValue($0.value, forHTTPHeaderField: $0.key) }
        ZNetwork.logger.log(request)

        return URLSession.shared
            .dataTaskPublisher(for: request)
            .map { data, response in
                ZNetwork.logger.log(response, data: data)
                return data
            }
            .decode(type: T.self, decoder: JSONDecoder())
            .receive(on: DispatchQueue.main)
            .eraseToAnyPublisher()
    }

    private func encodeJson(params: [String: String]) -> Data? {
        return try? JSONSerialization.data(withJSONObject: params, options: [])
    }

    private func encodeUrl(params: [String: String]) -> [URLQueryItem] {
        return params.map { URLQueryItem(name: $0.key, value: $0.value.addingPercentEncoding(withAllowedCharacters: allowedCharacterSet)) }
    }
}
