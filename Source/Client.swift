//
//  Copyright (c) 2015 Algolia
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


/// Signature of most completion handlers used by this library.
///
/// - parameter content: The JSON response (in case of success) or `nil` (in case of error).
/// - parameter error: The encountered error (in case of error) or `nil` (in case of success).
///
/// + Note: `content` and `error` are mutually exclusive: only one will be non-nil.
///
public typealias CompletionHandler = (content: [String: AnyObject]?, error: NSError?) -> Void


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
}

public func ==(lhs: LibraryVersion, rhs: LibraryVersion) -> Bool {
    return lhs.name == rhs.name && lhs.version == rhs.version
}


/// Error domain used for errors raised by this module.
public let ErrorDomain = "AlgoliaSearch"


/// Entry point into the Swift API.
///
@objc public class Client : NSObject {
    // MARK: Constants
    
    /// Error domain used for errors raised by this module.
    ///
    /// + Note: This shortcut is provided for Objective-C bridging. See the top-level `ErrorDomain` constant.
    ///
    @objc public static let ErrorDomain = AlgoliaSearch.ErrorDomain
    
    // MARK: Properties
    
    /// HTTP headers that will be sent with every request.
    @objc public var headers = [String:String]()

    /// Algolia API key.
    @objc public var apiKey: String {
        didSet {
            updateHeadersFromAPIKey()
        }
    }
    private func updateHeadersFromAPIKey() {
        headers["X-Algolia-API-Key"] = apiKey
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
        headers["User-Agent"] = userAgents.map({ return "\($0.name) (\($0.version))"}).joinWithSeparator("; ")
    }

    /// Default timeout for network requests. Default: 30 seconds.
    @objc public let timeout: NSTimeInterval = 30
    
    /// Timeout for search requests. Default: 5 seconds.
    @objc public let searchTimeout: NSTimeInterval = 5

    /// Algolia application ID.
    @objc public let appID: String

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
    let requestQueue: NSOperationQueue
    
    /// Dispatch queue used to run completion handlers.
    private var completionQueue = dispatch_get_main_queue()
    
    // MARK: Initialization
    
    /// Create a new Algolia Search client.
    ///
    /// - parameter appID:  The application ID (available in your Algolia Dashboard).
    /// - parameter apiKey: A valid API key for the service.
    ///
    @objc public init(appID: String, apiKey: String) {
        self.appID = appID
        self.apiKey = apiKey

        // Initialize hosts to their default values.
        //
        // NOTE: The host list comes in two parts:
        //
        // 1. The fault-tolerant, load-balanced DNS host.
        // 2. The non-fault-tolerant hosts. Those hosts must be randomized to ensure proper load balancing in case
        //    of the first host's failure.
        //
        let fallbackHosts = [
            "\(appID)-1.algolianet.com",
            "\(appID)-2.algolianet.com",
            "\(appID)-3.algolianet.com"
        ].shuffle()
        readHosts = [ "\(appID)-dsn.algolia.net" ] + fallbackHosts
        writeHosts = [ "\(appID).algolia.net" ] + fallbackHosts
        
        // WARNING: Those headers cannot be changed for the lifetime of the session.
        // Other headers are likely to change during the lifetime of the session: they will be passed at every request.
        let fixedHTTPHeaders = [
            "X-Algolia-Application-Id": self.appID
        ]
        let configuration = NSURLSessionConfiguration.defaultSessionConfiguration()
        configuration.HTTPAdditionalHeaders = fixedHTTPHeaders
        session = NSURLSession(configuration: configuration)
        
        requestQueue = NSOperationQueue()
        requestQueue.maxConcurrentOperationCount = 8
        
        super.init()
        
        // Add this library's version to the user agents.
        let version = NSBundle(forClass: self.dynamicType).infoDictionary!["CFBundleShortVersionString"] as! String
        self.userAgents = [ LibraryVersion(name: "Algolia for Swift", version: version) ]
        
        // Add the operating system's version to the user agents.
        if #available(iOS 8.0, OSX 10.0, tvOS 9.0, *) {
            let osVersion = NSProcessInfo.processInfo().operatingSystemVersion
            var osVersionString = "\(osVersion.majorVersion).\(osVersion.minorVersion)"
            if osVersion.patchVersion != 0 {
                osVersionString += ".\(osVersion.patchVersion)"
            }
            if let osName = getOSName() {
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
    @objc public func setHosts(hosts: [String]) {
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
    @objc public func setHeader(name: String, value: String?) {
        headers[name] = value
    }
    
    /// Get an HTTP header.
    ///
    /// + Note: You may also use the `headers` property directly.
    ///
    /// - parameter name: Header name.
    /// - returns: The header's value, or `nil` if the header does not exist.
    ///
    @objc public func getHeader(name: String) -> String? {
        return headers[name]
    }

    // MARK: - Operations

    /// List existing indexes.
    ///
    /// - parameter completionHandler: Completion handler to be notified of the request's outcome.
    /// - returns: A cancellable operation.
    ///
    @objc public func listIndexes(completionHandler: CompletionHandler) -> NSOperation {
        return performHTTPQuery("1/indexes", method: .GET, body: nil, hostnames: readHosts, completionHandler: completionHandler)
    }

    /// Delete an index.
    ///
    /// - parameter indexName: Name of the index to delete.
    /// - parameter completionHandler: Completion handler to be notified of the request's outcome.
    /// - returns: A cancellable operation.
    ///
    @objc public func deleteIndex(indexName: String, completionHandler: CompletionHandler? = nil) -> NSOperation {
        let path = "1/indexes/\(indexName.urlEncodedPathComponent())"
        return performHTTPQuery(path, method: .DELETE, body: nil, hostnames: writeHosts, completionHandler: completionHandler)
    }

    /// Move an existing index.
    ///
    /// If the destination index already exists, its specific API keys will be preserved and the source index specific
    /// API keys will be added.
    ///
    /// - parameter srcIndexName: Name of index to move.
    /// - parameter dstIndexName: The new index name.
    /// - parameter completionHandler: Completion handler to be notified of the request's outcome.
    /// - returns: A cancellable operation.
    ///
    @objc public func moveIndex(srcIndexName: String, to dstIndexName: String, completionHandler: CompletionHandler? = nil) -> NSOperation {
        let path = "1/indexes/\(srcIndexName.urlEncodedPathComponent())/operation"
        let request = [
            "destination": dstIndexName,
            "operation": "move"
        ]

        return performHTTPQuery(path, method: .POST, body: request, hostnames: writeHosts, completionHandler: completionHandler)
    }

    /// Copy an existing index.
    ///
    /// If the destination index already exists, its specific API keys will be preserved and the source index specific
    /// API keys will be added.
    ///
    /// - parameter srcIndexName: Name of the index to copy.
    /// - parameter dstIndexName: The new index name.
    /// - parameter completionHandler: Completion handler to be notified of the request's outcome.
    /// - returns: A cancellable operation.
    ///
    @objc public func copyIndex(srcIndexName: String, to dstIndexName: String, completionHandler: CompletionHandler? = nil) -> NSOperation {
        let path = "1/indexes/\(srcIndexName.urlEncodedPathComponent())/operation"
        let request = [
            "destination": dstIndexName,
            "operation": "copy"
        ]

        return performHTTPQuery(path, method: .POST, body: request, hostnames: writeHosts, completionHandler: completionHandler)
    }

    /// Create a proxy to an Algolia index (no server call required by this method).
    ///
    /// - parameter indexName: The name of the index.
    /// - returns: A new proxy to the specified index.
    ///
    @objc public func getIndex(indexName: String) -> Index {
        // IMPLEMENTATION NOTE: This method is called `initIndex` in other clients, which better conveys its semantics.
        // However, methods prefixed by `init` are automatically considered as initializers by the Objective-C bridge.
        // Therefore, `initIndex` would fail to compile in Objective-C, because its return type is not `instancetype`.
        return Index(client: self, indexName: indexName)
    }
    
    /// Strategy when running multiple queries. See `Client.multipleQueries(...)`.
    ///
    public enum MultipleQueriesStrategy: String {
        /// Execute the sequence of queries until the end.
        case None = "none"
        /// Execute the sequence of queries until the number of hits is reached by the sum of hits.
        case StopIfEnoughMatches = "stopIfEnoughMatches"
    }

    /// Query multiple indexes with one API call.
    ///
    /// - parameter queries: List of queries.
    /// - parameter strategy: The strategy to use.
    /// - parameter completionHandler: Completion handler to be notified of the request's outcome.
    /// - returns: A cancellable operation.
    ///
    @objc public func multipleQueries(queries: [IndexQuery], strategy: String?, completionHandler: CompletionHandler) -> NSOperation {
        // IMPLEMENTATION NOTE: Objective-C bridgeable alternative.
        let path = "1/indexes/*/queries"
        var requests = [[String: AnyObject]]()
        requests.reserveCapacity(queries.count)
        for query in queries {
            requests.append([
                "indexName": query.indexName,
                "params": query.query.build()
            ])
        }
        var request = [String: AnyObject]()
        request["requests"] = requests
        if strategy != nil {
            request["strategy"] = strategy
        }
        return performHTTPQuery(path, method: .POST, body: request, hostnames: readHosts, completionHandler: completionHandler)
    }
    
    /// Query multiple indexes with one API call.
    ///
    /// - parameter queries: List of queries.
    /// - parameter strategy: The strategy to use.
    /// - parameter completionHandler: Completion handler to be notified of the request's outcome.
    /// - returns: A cancellable operation.
    ///
    public func multipleQueries(queries: [IndexQuery], strategy: MultipleQueriesStrategy? = nil, completionHandler: CompletionHandler) -> NSOperation {
        // IMPLEMENTATION NOTE: Not Objective-C bridgeable because of enum.
        return multipleQueries(queries, strategy: strategy?.rawValue, completionHandler: completionHandler)
    }
    
    /// Batch operations.
    ///
    /// - parameter operations: List of operations.
    /// - parameter completionHandler: Completion handler to be notified of the request's outcome.
    /// - returns: A cancellable operation.
    ///
    @objc public func batch(operations: [AnyObject], completionHandler: CompletionHandler? = nil) -> NSOperation {
        let path = "1/indexes/*/batch"
        let body = ["requests": operations]
        return performHTTPQuery(path, method: .POST, body: body, hostnames: writeHosts, completionHandler: completionHandler)
    }
    
    /// Ping the server.
    /// This method returns nothing except a message indicating that the server is alive.
    ///
    /// - parameter completionHandler: Completion handler to be notified of the request's outcome.
    /// - returns: A cancellable operation.
    ///
    @objc public func isAlive(completionHandler: CompletionHandler) -> NSOperation {
        let path = "1/isalive"
        return performHTTPQuery(path, method: .GET, body: nil, hostnames: readHosts, completionHandler: completionHandler)
    }

    // MARK: - Network

    /// Perform an HTTP Query.
    func performHTTPQuery(path: String, method: HTTPMethod, body: [String: AnyObject]?, hostnames: [String], isSearchQuery: Bool = false, completionHandler: CompletionHandler? = nil) -> NSOperation {
        var request: Request!
        request = newRequest(method, path: path, body: body, hostnames: hostnames, isSearchQuery: isSearchQuery, completion: completionHandler)
        request.completionQueue = self.completionQueue
        requestQueue.addOperation(request)
        return request
    }
    
    /// Create a request with this client's settings.
    func newRequest(method: HTTPMethod, path: String, body: [String: AnyObject]?, hostnames: [String], isSearchQuery: Bool = false, completion: CompletionHandler? = nil) -> Request {
        let currentTimeout = isSearchQuery ? searchTimeout : timeout
        let request = Request(session: session, method: method, hosts: hostnames, firstHostIndex: 0, path: path, headers: headers, jsonBody: body, timeout: currentTimeout, completion:  completion)
        return request
    }
}
