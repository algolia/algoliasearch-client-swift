//
//  Copyright (c) 2016 Algolia
//  http://www.algolia.com/
//
//  Permission is hereby granted, free of charge, to any person obtaining a copy
//  of this software and associated documentation files (the "Software"), to deal
//  in the Software without restriction, including without limitation the rights
//  to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
//  copies of the Software, and to permit persons to whom the Software is
//  furnished to do so, subject to the following conditions:
//
//  The above copyright notice and this permission notice shall be included in
//  all copies or substantial portions of the Software.
//
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
//  IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
//  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
//  AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
//  LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
//  OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
//  THE SOFTWARE.
//

import Foundation


/// A version of a software library.
/// Used to construct the `User-Agent` header.
///
@objc public class LibraryVersion: NSObject {
    /// Library name.
    @objc public let name: String
    
    /// Version string.
    @objc public let version: String
    
    @objc public init(name: String, version: String) {
        self.name = name
        self.version = version
    }
    
    // MARK: Equatable
    
    override public func isEqual(_ object: Any?) -> Bool {
        if let rhs = object as? LibraryVersion {
            return self.name == rhs.name && self.version == rhs.version
        } else {
            return false
        }
    }
}


/// Describes what is the last known status of a given API host.
///
internal struct HostStatus {
    /// Whether the host is "up" or "down".
    /// "Up" means it answers normally, "down" means that it doesn't. This does not distinguish between the different
    /// kinds of retriable failures: it could be DNS resolution failure, no route to host, response timeout, or server 
    /// error. A non-retriable failure (e.g. `400 Bad Request`) is not considered for the "down" state.
    ///
    var up: Bool

    /// When the status was last modified.
    /// This is normally the moment when the client receives the response (or error).
    ///
    var lastModified: Date
}


/// An abstract API client.
///
/// + Warning: Not meant to be used directly. See `Client` or `PlacesClient` instead.
///
/// ## Stateful hosts
///
/// In order to avoid hitting timeouts at every request when one or more hosts are not working properly (whatever the
/// reason: DNS failure, no route to host, server down...), the client maintains a **known status** for each host.
/// That status can be either *up*, *down* or *unknown*. Initially, all hosts are in the *unknown* state. Then a given
/// host's status is updated whenever a request to it returns a response or an error.
///
/// When a host is flagged as *down*, it will not be considered for subsequent requests. However, to avoid discarding
/// hosts permanently, statuses are only remembered for a given timeframe, indicated by `hostStatusTimeout`. (You may
/// adjust it as needed, although the default value `defaultHostStatusTimeout` should make sense for most applications.)
///
@objc public class AbstractClient : NSObject {
    // MARK: Properties
    
    /// HTTP headers that will be sent with every request.
    @objc public var headers = [String:String]()
    
    /// Algolia API key.
    ///
    /// + Note: Optional version, for internal use only.
    ///
    @objc internal var _apiKey: String? {
        didSet {
            updateHeadersFromAPIKey()
        }
    }
    private func updateHeadersFromAPIKey() {
        headers["X-Algolia-API-Key"] = _apiKey
    }
    
    /// The list of libraries used by this client, passed in the `User-Agent` HTTP header of every request.
    /// It is initially set to contain only this API Client, but may be overridden to include other libraries.
    ///
    /// + WARNING: The user agent is crucial to proper statistics in your Algolia dashboard. Please leave it as is.
    /// This field is publicly exposed only for the sake of other Algolia libraries.
    ///
    @objc public var userAgents: [LibraryVersion] = [] {
        didSet {
            updateHeadersFromUserAgents()
        }
    }
    private func updateHeadersFromUserAgents() {
        headers["User-Agent"] = userAgents.map({ return "\($0.name) (\($0.version))"}).joined(separator: "; ")
    }
    
    /// Default timeout for network requests. Default: 30 seconds.
    @objc public var timeout: TimeInterval = 30
    
    /// Specific timeout for search requests. Default: 5 seconds.
    @objc public var searchTimeout: TimeInterval = 5
    
    /// Algolia application ID.
    ///
    /// + Note: Optional version, for internal use only.
    ///
    @objc internal let _appID: String?
    
    /// Hosts for read queries, in priority order.
    /// The first host will always be used, then subsequent hosts in case of retry.
    ///
    /// + Warning: The default values should be appropriate for most use cases.
    /// Change them only if you know what you are doing.
    ///
    @objc public var readHosts: [String] {
        willSet {
            assert(!newValue.isEmpty)
        }
    }
    
    /// Hosts for write queries, in priority order.
    /// The first host will always be used, then subsequent hosts in case of retry.
    ///
    /// + Warning: The default values should be appropriate for most use cases.
    /// Change them only if you know what you are doing.
    ///
    @objc public var writeHosts: [String] {
        willSet {
            assert(!newValue.isEmpty)
        }
    }
    
    /// The last known statuses of hosts.
    /// If a host is absent from this dictionary, it means its status is unknown.
    ///
    /// + Note: Hosts are never removed from this dictionary, which is a potential memory leak in theory, but does not
    ///   matter in practice, because (1) the host arrays are provided at init time and seldom updated and (2) very
    ///   short anyway.
    ///
    internal var hostStatuses: [String: HostStatus] = [:]

    /// The timeout for host statuses.
    @objc public var hostStatusTimeout: TimeInterval = defaultHostStatusTimeout

    /// GCD queue to synchronize access to `hostStatuses`.
    internal var hostStatusQueue = DispatchQueue(label: "AbstractClient.hostStatusQueue")
    
    // NOTE: Not constant only for the sake of mocking during unit tests.
    var session: URLSession
    
    /// Operation queue used to keep track of requests.
    /// `Request` instances are inherently asynchronous, since they are merely wrappers around `NSURLSessionTask`.
    /// The sole purpose of the queue is to retain them for the duration of their execution!
    ///
    let requestQueue: OperationQueue
    
    /// Dispatch queue used to run completion handlers.
    internal var completionQueue = DispatchQueue.main
    
    // MARK: Constant
    
    /// The default timeout for host statuses.
    @objc public static let defaultHostStatusTimeout: TimeInterval = 5 * 60
    
    #if !os(watchOS)
    
    /// Network reachability detecter.
    internal var reachability: NetworkReachability = SystemNetworkReachability()
    // ^ NOTE: Not constant only for the sake of mocking during unit tests.
    
    /// Whether to use network reachability to decide if online requests should be attempted.
    ///
    /// - When `true` (default), if the network reachability (as reported by the System Configuration framework) is
    ///   down, online requests will not be attempted and report to fail immediately.
    /// - When `false`, online requests will always be attempted (if the strategy involves them), even if the network
    ///   does not seem to be reachable.
    ///
    /// + Note: Not available on watchOS (the System Configuration framework is not available there).
    ///
    @objc public var useReachability: Bool = true
    
    #endif // !os(watchOS)

    // MARK: Initialization
    
    internal init(appID: String?, apiKey: String?, readHosts: [String], writeHosts: [String]) {
        self._appID = appID
        self._apiKey = apiKey
        self.readHosts = readHosts
        self.writeHosts = writeHosts
        
        // WARNING: Those headers cannot be changed for the lifetime of the session.
        // Other headers are likely to change during the lifetime of the session: they will be passed at every request.
        var fixedHTTPHeaders: [String: String] = [:]
        fixedHTTPHeaders["X-Algolia-Application-Id"] = self._appID
        let configuration = URLSessionConfiguration.default
        configuration.httpAdditionalHeaders = fixedHTTPHeaders
        session = Foundation.URLSession(configuration: configuration)
        
        requestQueue = OperationQueue()
        requestQueue.maxConcurrentOperationCount = 8
        
        super.init()
        
        // Add this library's version to the user agents.
        let version = Bundle(for: type(of: self)).infoDictionary!["CFBundleShortVersionString"] as! String
        self.userAgents = [ LibraryVersion(name: "Algolia for Swift", version: version) ]
        
        // Add the operating system's version to the user agents.
        if #available(iOS 8.0, OSX 10.0, tvOS 9.0, *) {
            let osVersion = ProcessInfo.processInfo.operatingSystemVersion
            var osVersionString = "\(osVersion.majorVersion).\(osVersion.minorVersion)"
            if osVersion.patchVersion != 0 {
                osVersionString += ".\(osVersion.patchVersion)"
            }
            if let osName = osName {
                self.userAgents.append(LibraryVersion(name: osName, version: osVersionString))
            }
        }
        
        // WARNING: `didSet` not called during initialization => we need to update the headers manually here.
        updateHeadersFromAPIKey()
        updateHeadersFromUserAgents()
    }

    /// Set read and write hosts to the same value (convenience method).
    ///
    /// + Warning: The default values should be appropriate for most use cases.
    /// Change them only if you know what you are doing.
    ///
    @objc(setHosts:)
    public func setHosts(_ hosts: [String]) {
        readHosts = hosts
        writeHosts = hosts
    }
    
    /// Set an HTTP header that will be sent with every request.
    ///
    /// + Note: You may also use the `headers` property directly.
    ///
    /// - parameter name: Header name.
    /// - parameter value: Value for the header. If `nil`, the header will be removed.
    ///
    @objc(setHeaderWithName:to:)
    public func setHeader(withName name: String, to value: String?) {
        headers[name] = value
    }
    
    /// Get an HTTP header.
    ///
    /// + Note: You may also use the `headers` property directly.
    ///
    /// - parameter name: Header name.
    /// - returns: The header's value, or `nil` if the header does not exist.
    ///
    @objc(headerWithName:)
    public func header(withName name: String) -> String? {
        return headers[name]
    }
    
    // MARK: - Operations
    
    /// Ping the server.
    /// This method returns nothing except a message indicating that the server is alive.
    ///
    /// - parameter completionHandler: Completion handler to be notified of the request's outcome.
    /// - returns: A cancellable operation.
    ///
    @objc(isAlive:)
    @discardableResult public func isAlive(completionHandler: @escaping CompletionHandler) -> Operation {
        let path = "1/isalive"
        return performHTTPQuery(path: path, method: .GET, body: nil, hostnames: readHosts, completionHandler: completionHandler)
    }
    
    // MARK: - Network
    
    /// Perform an HTTP Query.
    func performHTTPQuery(path: String, method: HTTPMethod, body: JSONObject?, hostnames: [String], isSearchQuery: Bool = false, completionHandler: CompletionHandler? = nil) -> Operation {
        let request = newRequest(method: method, path: path, body: body, hostnames: hostnames, isSearchQuery: isSearchQuery, completion: completionHandler)
        request.completionQueue = self.completionQueue
        requestQueue.addOperation(request)
        return request
    }
    
    /// Create a request with this client's settings.
    func newRequest(method: HTTPMethod, path: String, body: JSONObject?, hostnames: [String], isSearchQuery: Bool = false, completion: CompletionHandler? = nil) -> Request {
        let currentTimeout = isSearchQuery ? searchTimeout : timeout
        let request = Request(client: self, method: method, hosts: hostnames, firstHostIndex: 0, path: path, headers: headers, jsonBody: body, timeout: currentTimeout, completion:  completion)
        return request
    }

    /// Filter a list of hosts according to the currently known statuses, keeping only those that are up or unknown.
    ///
    /// - parameter hosts: The list of hosts to filter.
    /// - returns: A filtered list of hosts, or the original list if the result of filtering would be empty.
    ///
    func upOrUnknownHosts(_ hosts: [String]) -> [String] {
        assert(!hosts.isEmpty)
        let now = Date()
        let filteredHosts = hostStatusQueue.sync {
            return hosts.filter { (host) -> Bool in
                if let status = self.hostStatuses[host] { // known status
                    return status.up || now.timeIntervalSince(status.lastModified) >= self.hostStatusTimeout // include if up or obsolete
                } else { // unknown status
                    return true // always include
                }
            }
        }
        // Avoid returning an empty list.
        return filteredHosts.isEmpty ? hosts : filteredHosts
    }

    /// Update the status for a given host.
    ///
    /// - parameter host: The name of the host to update.
    /// - parameter up: Whether the host is currently up (true) or down (false).
    ///
    func updateHostStatus(host: String, up: Bool) {
        hostStatusQueue.sync {
            self.hostStatuses[host] = HostStatus(up: up, lastModified: Date())
        }
    }
    
    #if !os(watchOS)
    
    /// Decide whether a network request should be attempted in the current conditions.
    ///
    /// - returns: `true` if a network request should be attempted, `false` if the client should fail fast with a
    ///            network error.
    ///
    func shouldMakeNetworkCall() -> Bool {
        return !useReachability || reachability.isReachable()
    }

    #endif // !os(watchOS)
}
