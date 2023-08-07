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
    }

    func run<T: Codable>(_ point: ZNetworkPoint) -> AnyPublisher<T, Error> {
        switch point.method {
        case .GET: return get(point)
        default: return Fail(error: ZNetworkError.BadRequest).eraseToAnyPublisher()
        }
    }
}

// MARK: - Service Runable Commands
extension ZNetworkService {
    private func get<T: Codable>(_ point: ZNetworkPoint) -> AnyPublisher<T, Error> {
        let requestString = "\(baseURLString ?? "")\(point.path)"
        guard let url = URL(string: requestString) else { return Fail(error: ZNetworkError.BadRequest).eraseToAnyPublisher() }
        var request = URLRequest(url: url)
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
}
