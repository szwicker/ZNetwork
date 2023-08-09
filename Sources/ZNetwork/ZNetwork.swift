import Foundation
import Combine

public class ZNetwork {

    // MARK: - Public Properties
    public var logLevel: LogLevel {
        get { return ZNetwork.logger.logLevel }
        set { ZNetwork.logger.logLevel = newValue }
    }

    // MARK: - Static Properties
    static let logger = ZNetworkLog()

    // MARK: - Initialization
    public init(with baseURL: String, timeout: TimeInterval? = nil) {
        ZNetworkService.shared.configure(with: baseURL, timeout: timeout)
    }

    public init(with component: ZNetworkComponent, timeout: TimeInterval? = nil) {
        ZNetworkService.shared.configure(with: component, timeout: timeout)
    }

    public func run<T: Codable>(_ point: ZNetworkPoint) async -> Result<T, ZNetworkError> {
        await ZNetworkService.shared.run(point)
    }
}
