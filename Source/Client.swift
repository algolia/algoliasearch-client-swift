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


/// Entry point in the Swift API.
///
/// You should instantiate a Client object with your AppID, ApiKey and Hosts
/// to start using Algolia Search API.
@objc public class Client : NSObject {
    // MARK: Constants
    
    /// Error domain used for errors raised by this module.
    @objc public static let ErrorDomain = "Client.ErrorDomain"
    
    // MARK: Properties
    
    /// HTTP headers that will be sent with every request.
    @objc public var headers = [String:String]()
    
    @objc public var apiKey: String {
        didSet {
            headers["X-Algolia-API-Key"] = apiKey
        }
    }

    /// Default timeout for network requests. Default: 30".
    @objc public let timeout: NSTimeInterval = 30
    
    /// Timeout for search requests. Default: 5".
    @objc public let searchTimeout: NSTimeInterval = 5

    @objc public let appID: String

    /// Hosts for read queries, in priority order.
    /// The first host will always be used, then subsequent hosts in case of retry.
    ///
    /// WARNING: The default values should be appropriate for most use cases.
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
    /// WARNING: The default values should be appropriate for most use cases.
    /// Change them only if you know what you are doing.
    ///
    @objc public var writeHosts: [String] {
        willSet {
            assert(!newValue.isEmpty)
        }
    }
    
    /// Set read and write hosts to the same value (convenience method).
    @objc public func setHosts(hosts: [String]) {
        readHosts = hosts
        writeHosts = hosts
    }

    // NOTE: Not constant only for the sake of mocking during unit tests.
    var session: URLSession
    
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
        let version = NSBundle(forClass: self.dynamicType).infoDictionary!["CFBundleShortVersionString"] as! String
        let fixedHTTPHeaders = [
            "X-Algolia-Application-Id": self.appID
        ]
        let configuration = NSURLSessionConfiguration.defaultSessionConfiguration()
        configuration.HTTPAdditionalHeaders = fixedHTTPHeaders
        session = NSURLSession(configuration: configuration)
        
        super.init()
        
        // Other headers are likely to change during the lifetime of the session: they will be passed for every request.
        headers["X-Algolia-API-Key"] = self.apiKey // necessary because `didSet` not called during initialization
        // NOTE: This one will not change... except it can be overridden by the offline client:
        headers["User-Agent"] = "Algolia for Swift \(version)"
    }

    /// Set an HTTP header that will be sent with every request.
    ///
    /// NOTE: You may also use the `headers` property directly.
    ///
    /// - parameter name: Header name.
    /// - parameter value: Value for the header. If nil, the header will be removed.
    ///
    @objc public func setHeader(name: String!, value: String) {
        headers[name] = value
    }
    
    /// Get an HTTP header.
    ///
    /// NOTE: You may also use the `headers` property directly.
    ///
    /// - parameter name: Header name.
    /// - returns: The header's value, or nil if the header does not exist.
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
        let path = "1/indexes/\(indexName.urlEncode())"
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
        let path = "1/indexes/\(srcIndexName.urlEncode())/operation"
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
        let path = "1/indexes/\(srcIndexName.urlEncode())/operation"
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
    
    /// Strategy when running multiple queries. See `Client.multipleQueries()`.
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
    /// - param strategy: The strategy to use.
    /// - parameter completionHandler: Completion handler to be notified of the request's outcome.
    /// - returns: A cancellable operation.
    ///
    @objc public func multipleQueries(queries: [IndexQuery], strategy: String?, completionHandler: CompletionHandler? = nil) -> NSOperation {
        // IMPLEMENTATION NOTE: Objective-C bridgeable alternative.
        var path = "1/indexes/*/queries"
        if strategy != nil {
            path += "?strategy=\(strategy!.urlEncode())"
        }
        var requests = [[String: AnyObject]]()
        requests.reserveCapacity(queries.count)
        for query in queries {
            requests.append([
                "indexName": query.indexName,
                "params": query.query.build()
            ])
        }
        let request = ["requests": requests]
        return performHTTPQuery(path, method: .POST, body: request, hostnames: readHosts, completionHandler: completionHandler)
    }
    
    /// Query multiple indexes with one API call.
    ///
    /// - parameter queries: List of queries.
    /// - param strategy: The strategy to use.
    /// - parameter completionHandler: Completion handler to be notified of the request's outcome.
    /// - returns: A cancellable operation.
    ///
    public func multipleQueries(queries: [IndexQuery], strategy: MultipleQueriesStrategy? = nil, completionHandler: CompletionHandler? = nil) -> NSOperation {
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

    // MARK: - Network

    /// Perform an HTTP Query.
    func performHTTPQuery(path: String, method: HTTPMethod, body: [String: AnyObject]?, hostnames: [String], isSearchQuery: Bool = false, completionHandler: CompletionHandler? = nil) -> NSOperation {
        let request = newRequest(method, path: path, body: body, hostnames: hostnames, isSearchQuery: isSearchQuery) {
            (content: [String: AnyObject]?, error: NSError?) -> Void in
            if completionHandler != nil {
                dispatch_async(dispatch_get_main_queue()) {
                    completionHandler!(content: content, error: error)
                }
            }
        }
        request.start()
        return request
    }
    
    #if DEBUG
    /// [debug] Artificial delay introduced in responses. Disabled by default.
    public var debugResponseDelay: NSTimeInterval?
    #endif
    
    /// Create a request with this client's settings.
    func newRequest(method: HTTPMethod, path: String, body: [String: AnyObject]?, hostnames: [String], isSearchQuery: Bool = false, completion: CompletionHandler? = nil) -> Request {
        let currentTimeout = isSearchQuery ? searchTimeout : timeout
        let request = Request(session: session, method: method, hosts: hostnames, firstHostIndex: 0, path: path, headers: headers, jsonBody: body, timeout: currentTimeout, completion:  completion)
        #if DEBUG
        request.debugResponseDelay = self.debugResponseDelay
        #endif
        return request
    }
}
