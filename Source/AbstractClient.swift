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


/// An abstract API client.
///
/// + Warning: Not meant to be used directly. See `Client` or `PlacesClient` instead.
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
    
    // NOTE: Not constant only for the sake of mocking during unit tests.
    var session: URLSession
    
    /// Operation queue used to keep track of requests.
    /// `Request` instances are inherently asynchronous, since they are merely wrappers around `NSURLSessionTask`.
    /// The sole purpose of the queue is to retain them for the duration of their execution!
    ///
    let requestQueue: OperationQueue
    
    /// Dispatch queue used to run completion handlers.
    internal var completionQueue = DispatchQueue.main
    
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
        let request = Request(session: session, method: method, hosts: hostnames, firstHostIndex: 0, path: path, headers: headers, jsonBody: body, timeout: currentTimeout, completion:  completion)
        return request
    }
}
