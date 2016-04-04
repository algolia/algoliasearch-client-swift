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
    /// HTTP headers that will be sent with every request.
    @objc public var headers = [String:String]()
    
    @objc public var apiKey: String {
        didSet {
            headers["X-Algolia-API-Key"] = apiKey
        }
    }

    private let timeout: NSTimeInterval = 30
    private let searchTimeout: NSTimeInterval = 5

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

    /// Algolia Search initialization.
    ///
    /// - parameter appID: the application ID you have in your admin interface
    /// - parameter apiKey: a valid API key for the service
    @objc public init(appID: String, apiKey: String) {
        self.appID = appID
        self.apiKey = apiKey

        // Initialize hosts to their default values.
        readHosts = [
            "\(appID)-dsn.algolia.net",
            "\(appID)-1.algolianet.com",
            "\(appID)-2.algolianet.com",
            "\(appID)-3.algolianet.com"
        ]
        writeHosts = [
            "\(appID).algolia.net",
            "\(appID)-1.algolianet.com",
            "\(appID)-2.algolianet.com",
            "\(appID)-3.algolianet.com"
        ]
        
        // WARNING: Those headers cannot be changed for the lifetime of the session.
        let version = NSBundle(forClass: self.dynamicType).infoDictionary!["CFBundleShortVersionString"] as! String
        let fixedHTTPHeaders = [
            "User-Agent": "Algolia for Swift \(version)",
            "X-Algolia-Application-Id": self.appID
        ]
        let configuration = NSURLSessionConfiguration.defaultSessionConfiguration()
        configuration.HTTPAdditionalHeaders = fixedHTTPHeaders
        session = NSURLSession(configuration: configuration)
        
        super.init()
        
        // Other headers are likely to change during the lifetime of the session: they will be passed for every request.
        headers["X-Algolia-API-Key"] = self.apiKey // necessary because `didSet` not called during initialization
    }

    /// Allow to set custom extra header.
    /// You may also use the `headers` property directly.
    ///
    /// - parameter value: value of the header
    /// - parameter forKey: key of the header
    @objc public func setExtraHeader(value: String, forKey key: String) {
        headers[key] = value
    }

    // MARK: - Operations

    /// List all existing indexes.
    ///
    /// :return: JSON Object in the handler in the form: { "items": [ {"name": "contacts", "createdAt": "2013-01-18T15:33:13.556Z"}, {"name": "notes", "createdAt": "2013-01-18T15:33:13.556Z"}]}
    @objc public func listIndexes(block: CompletionHandler) -> NSOperation {
        return performHTTPQuery("1/indexes", method: .GET, body: nil, hostnames: readHosts, block: block)
    }

    /// Delete an index.
    ///
    /// - parameter indexName: the name of index to delete
    /// :return: JSON Object in the handler containing a "deletedAt" attribute
    @objc public func deleteIndex(indexName: String, block: CompletionHandler? = nil) -> NSOperation {
        let path = "1/indexes/\(indexName.urlEncode())"
        return performHTTPQuery(path, method: .DELETE, body: nil, hostnames: writeHosts, block: block)
    }

    /// Move an existing index.
    ///
    /// - parameter srcIndexName: the name of index to move.
    /// - parameter dstIndexName: the new index name that will contains sourceIndexName (destination will be overriten if it already exist).
    @objc public func moveIndex(srcIndexName: String, to dstIndexName: String, block: CompletionHandler? = nil) -> NSOperation {
        let path = "1/indexes/\(srcIndexName.urlEncode())/operation"
        let request = [
            "destination": dstIndexName,
            "operation": "move"
        ]

        return performHTTPQuery(path, method: .POST, body: request, hostnames: writeHosts, block: block)
    }

    /// Copy an existing index.
    ///
    /// - parameter srcIndexName: the name of index to copy.
    /// - parameter dstIndexName: the new index name that will contains a copy of sourceIndexName (destination will be overriten if it already exist).
    @objc public func copyIndex(srcIndexName: String, to dstIndexName: String, block: CompletionHandler? = nil) -> NSOperation {
        let path = "1/indexes/\(srcIndexName.urlEncode())/operation"
        let request = [
            "destination": dstIndexName,
            "operation": "copy"
        ]

        return performHTTPQuery(path, method: .POST, body: request, hostnames: writeHosts, block: block)
    }

    /// Get the index object initialized (no server call needed for initialization).
    ///
    /// - parameter indexName: the name of index
    @objc public func getIndex(indexName: String) -> Index {
        return Index(client: self, indexName: indexName)
    }

    /// Query multiple indexes with one API call.
    ///
    /// - parameter queries: An array of queries with the associated index (Array of Dictionnary object ["indexName": "targettedIndex", "query": QueryObject]).
    @objc public func multipleQueries(queries: [AnyObject], block: CompletionHandler? = nil) -> NSOperation {
        let path = "1/indexes/*/queries"

        var convertedQueries = [[String: String]]()
        convertedQueries.reserveCapacity(queries.count)
        for query in queries {
            if let query = query as? [String: AnyObject] {
                convertedQueries.append([
                    "params": (query["query"] as! Query).build(),
                    "indexName": query["indexName"] as! String
                    ])
            }
        }

        let request = ["requests": convertedQueries]
        return performHTTPQuery(path, method: .POST, body: request, hostnames: readHosts, block: block)
    }

    // MARK: - Network

    /// Perform an HTTP Query.
    func performHTTPQuery(path: String, method: HTTPMethod, body: [String: AnyObject]?, hostnames: [String], isSearchQuery: Bool = false, block: CompletionHandler? = nil) -> NSOperation {
        let request = newRequest(method, path: path, body: body, isSearchQuery: isSearchQuery) {
            (content: [String: AnyObject]?, error: NSError?) -> Void in
            if block != nil {
                dispatch_async(dispatch_get_main_queue()) {
                    block!(content: content, error: error)
                }
            }
        }
        request.start()
        return request
    }
    
    /// Create a request with this client's settings.
    func newRequest(method: HTTPMethod, path: String, body: [String: AnyObject]?, isSearchQuery: Bool = false, completion: CompletionHandler? = nil) -> Request {
        let currentTimeout = isSearchQuery ? searchTimeout : timeout
        let hostnames = isSearchQuery ? readHosts : writeHosts
        let request = Request(session: session, method: method, hosts: hostnames, firstHostIndex: 0, path: path, headers: headers, jsonBody: body, timeout: currentTimeout, completion:  completion)
        return request
    }
}
