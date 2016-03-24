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
public class Client : NSObject {
    /// HTTP headers that will be sent with every request.
    public var headers = [String:String]()
    
    public var apiKey: String {
        didSet {
            headers["X-Algolia-API-Key"] = apiKey
        }
    }

    private let timeout: NSTimeInterval = 30
    private let searchTimeout: NSTimeInterval = 5
    private let incrementTimeout: NSTimeInterval = 10

    public let appID: String

    /// Hosts for read queries, in priority order.
    /// The first host will always be used, then subsequent hosts in case of retry.
    ///
    /// WARNING: The default values should be appropriate for most use cases.
    /// Change them only if you know what you are doing.
    ///
    public var readHosts: [String] {
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
    public var writeHosts: [String] {
        willSet {
            assert(!newValue.isEmpty)
        }
    }
    
    /// Set read and write hosts to the same value (convenience method).
    public func setHosts(hosts: [String]) {
        readHosts = hosts
        writeHosts = hosts
    }

    let session: NSURLSession

    /// Algolia Search initialization.
    ///
    /// - parameter appID: the application ID you have in your admin interface
    /// - parameter apiKey: a valid API key for the service
    public init(appID: String, apiKey: String) {
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
    public func setExtraHeader(value: String, forKey key: String) {
        headers[key] = value
    }

    // MARK: - Operations

    /// List all existing indexes.
    ///
    /// :return: JSON Object in the handler in the form: { "items": [ {"name": "contacts", "createdAt": "2013-01-18T15:33:13.556Z"}, {"name": "notes", "createdAt": "2013-01-18T15:33:13.556Z"}]}
    public func listIndexes(block: CompletionHandler) -> NSOperation {
        return performHTTPQuery("1/indexes", method: .GET, body: nil, hostnames: readHosts, block: block)
    }

    /// Delete an index.
    ///
    /// - parameter indexName: the name of index to delete
    /// :return: JSON Object in the handler containing a "deletedAt" attribute
    public func deleteIndex(indexName: String, block: CompletionHandler? = nil) -> NSOperation {
        let path = "1/indexes/\(indexName.urlEncode())"
        return performHTTPQuery(path, method: .DELETE, body: nil, hostnames: writeHosts, block: block)
    }

    /// Move an existing index.
    ///
    /// - parameter srcIndexName: the name of index to move.
    /// - parameter dstIndexName: the new index name that will contains sourceIndexName (destination will be overriten if it already exist).
    public func moveIndex(srcIndexName: String, to dstIndexName: String, block: CompletionHandler? = nil) -> NSOperation {
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
    public func copyIndex(srcIndexName: String, to dstIndexName: String, block: CompletionHandler? = nil) -> NSOperation {
        let path = "1/indexes/\(srcIndexName.urlEncode())/operation"
        let request = [
            "destination": dstIndexName,
            "operation": "copy"
        ]

        return performHTTPQuery(path, method: .POST, body: request, hostnames: writeHosts, block: block)
    }

    /// Return 10 last log entries.
    public func getLogs(block: CompletionHandler) -> NSOperation {
        return performHTTPQuery("1/logs", method: .GET, body: nil, hostnames: writeHosts, block: block)
    }

    /// Return last logs entries.
    ///
    /// - parameter offset: Specify the first entry to retrieve (0-based, 0 is the most recent log entry).
    /// - parameter length: Specify the maximum number of entries to retrieve starting at offset. Maximum allowed value: 1000.
    public func getLogsWithOffset(offset: UInt, length: UInt, block: CompletionHandler) -> NSOperation {
        let path = "1/logs?offset=\(offset)&length=\(length)"
        return performHTTPQuery(path, method: .GET, body: nil, hostnames: readHosts, block: block)
    }

    /// Return last logs entries.
    ///
    /// - parameter offset: Specify the first entry to retrieve (0-based, 0 is the most recent log entry).
    /// - parameter length: Specify the maximum number of entries to retrieve starting at offset. Maximum allowed value: 1000.
    public func getLogsWithType(type: String, offset: UInt, length: UInt, block: CompletionHandler) -> NSOperation {
        let path = "1/logs?offset=\(offset)&length=\(length)&type=\(type)"
        return performHTTPQuery(path, method: .GET, body: nil, hostnames: readHosts, block: block)
    }

    /// Get the index object initialized (no server call needed for initialization).
    ///
    /// - parameter indexName: the name of index
    public func getIndex(indexName: String) -> Index {
        return Index(client: self, indexName: indexName)
    }

    /// List all existing user keys with their associated ACLs.
    public func listUserKeys(block: CompletionHandler) -> NSOperation {
        return performHTTPQuery("1/keys", method: .GET, body: nil, hostnames: readHosts, block: block)
    }

    /// Get ACL of a user key.
    public func getUserKeyACL(key: String, block: CompletionHandler) -> NSOperation {
        let path = "1/keys/\(key)"
        return performHTTPQuery(path, method: .GET, body: nil, hostnames: readHosts, block: block)
    }

    /// Delete an existing user key.
    public func deleteUserKey(key: String, block: CompletionHandler? = nil) -> NSOperation {
        let path = "1/keys/\(key)"
        return performHTTPQuery(path, method: .DELETE, body: nil, hostnames: writeHosts, block: block)
    }

    /// Create a new user key
    ///
    /// - parameter acls: The list of ACL for this key. The list can contains the following values (as String): search, addObject, deleteObject, deleteIndex, settings, editSettings
    public func addUserKey(acls: [String], block: CompletionHandler? = nil) -> NSOperation {
        let request = ["acl": acls]
        return performHTTPQuery("1/keys", method: .POST, body: request, hostnames: writeHosts, block: block)
    }

    /// Create a new user key
    ///
    /// - parameter acls: The list of ACL for this key. The list can contains the following values (as String): search, addObject, deleteObject, deleteIndex, settings, editSettings
    /// - parameter withValidity: The number of seconds after which the key will be automatically removed (0 means no time limit for this key)
    /// - parameter maxQueriesPerIPPerHour: Specify the maximum number of API calls allowed from an IP address per hour.  Defaults to 0 (unlimited).
    /// - parameter maxHitsPerQuery: Specify the maximum number of hits this API key can retrieve in one call. Defaults to 0 (unlimited)
    public func addUserKey(acls: [String], withValidity validity: UInt, maxQueriesPerIPPerHour maxQueries: UInt, maxHitsPerQuery maxHits: UInt, block: CompletionHandler? = nil) -> NSOperation {
        let request: [String: AnyObject] = [
            "acl": acls,
            "validity": validity,
            "maxQueriesPerIPPerHour": maxQueries,
            "maxHitsPerQuery": maxHits,
        ]

        return performHTTPQuery("1/keys", method: .POST, body: request, hostnames: writeHosts, block: block)
    }

    /// Create a new user key
    ///
    /// - parameter acls: The list of ACL for this key. The list can contains the following values (as String): search, addObject, deleteObject, deleteIndex, settings, editSettings
    /// - parameter forIndexes: restrict this new API key to specific index names
    /// - parameter withValidity: The number of seconds after which the key will be automatically removed (0 means no time limit for this key)
    /// - parameter maxQueriesPerIPPerHour: Specify the maximum number of API calls allowed from an IP address per hour.  Defaults to 0 (unlimited).
    /// - parameter maxHitsPerQuery: Specify the maximum number of hits this API key can retrieve in one call. Defaults to 0 (unlimited)
    public func addUserKey(acls: [String], forIndexes indexes: [String], withValidity validity: UInt, maxQueriesPerIPPerHour maxQueries: UInt, maxHitsPerQuery maxHits: UInt, block: CompletionHandler? = nil) -> NSOperation {
        let request: [String: AnyObject] = [
            "acl": acls,
            "indexes": indexes,
            "validity": validity,
            "maxQueriesPerIPPerHour": maxQueries,
            "maxHitsPerQuery": maxHits,
        ]

        return performHTTPQuery("1/keys", method: .POST, body: request, hostnames: writeHosts, block: block)
    }

    /// Update a user key
    ///
    /// - parameter key: The key to update
    /// - parameter withAcls: The list of ACL for this key. The list can contains the following values (as String): search, addObject, deleteObject, deleteIndex, settings, editSettings
    public func updateUserKey(key: String, withACL acls: [String], block: CompletionHandler? = nil) -> NSOperation {
        let path = "1/keys/\(key)"
        let request = ["acl": acls]
        return performHTTPQuery(path, method: .PUT, body: request, hostnames: writeHosts, block: block)
    }

    /// Update a user key
    ///
    /// - parameter key: The key to update
    /// - parameter withAcls: The list of ACL for this key. The list can contains the following values (as String): search, addObject, deleteObject, deleteIndex, settings, editSettings
    /// - parameter andValidity: The number of seconds after which the key will be automatically removed (0 means no time limit for this key)
    /// - parameter maxQueriesPerIPPerHour: Specify the maximum number of API calls allowed from an IP address per hour.  Defaults to 0 (unlimited).
    /// - parameter maxHitsPerQuery: Specify the maximum number of hits this API key can retrieve in one call. Defaults to 0 (unlimited)
    public func updateUserKey(key: String, withACL acls: [String], andValidity validity: UInt, maxQueriesPerIPPerHour maxQueries: UInt, maxHitsPerQuery maxHits: UInt, block: CompletionHandler? = nil) -> NSOperation {
        let path = "1/keys/\(key)"
        let request: [String: AnyObject] = [
            "acl": acls,
            "validity": validity,
            "maxQueriesPerIPPerHour": maxQueries,
            "maxHitsPerQuery": maxHits,
        ]

        return performHTTPQuery(path, method: .PUT, body: request, hostnames: writeHosts, block: block)
    }

    /// Update a user key
    ///
    /// - parameter key: The key to update
    /// - parameter withAcls: The list of ACL for this key. The list can contains the following values (as String): search, addObject, deleteObject, deleteIndex, settings, editSettings
    /// - parameter andValidity: The number of seconds after which the key will be automatically removed (0 means no time limit for this key)
    /// - parameter forIndexes: restrict this API key to specific index names
    /// - parameter maxQueriesPerIPPerHour: Specify the maximum number of API calls allowed from an IP address per hour.  Defaults to 0 (unlimited).
    /// - parameter maxHitsPerQuery: Specify the maximum number of hits this API key can retrieve in one call. Defaults to 0 (unlimited)
    public func updateUserKey(key: String, withACL acls: [String], andValidity validity: UInt, forIndexes indexes: [String], maxQueriesPerIPPerHour maxQueries: UInt, maxHitsPerQuery maxHits: UInt, block: CompletionHandler? = nil) -> NSOperation {
        let path = "1/keys/\(key)"
        let request: [String: AnyObject] = [
            "acl": acls,
            "indexes": indexes,
            "validity": validity,
            "maxQueriesPerIPPerHour": maxQueries,
            "maxHitsPerQuery": maxHits,
        ]

        return performHTTPQuery(path, method: .PUT, body: request, hostnames: writeHosts, block: block)
    }

    /// Query multiple indexes with one API call.
    ///
    /// - parameter queries: An array of queries with the associated index (Array of Dictionnary object ["indexName": "targettedIndex", "query": QueryObject]).
    public func multipleQueries(queries: [AnyObject], block: CompletionHandler? = nil) -> NSOperation {
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
        // TODO: Remember host failures to restart at the first working host.
        let request = Request(session: session, method: method, hosts: hostnames, firstHostIndex: 0, path: path, headers: headers, jsonBody: body, timeout: currentTimeout, completion:  completion)
        return request
    }
}
