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
    public var apiKey: String {
        didSet {
            setExtraHeader(apiKey, forKey: "X-Algolia-API-Key")
        }
    }
    
    /// Security tag header
    public var queryParameters: String? {
        didSet {
            if let queryParameters = queryParameters {
                setExtraHeader(queryParameters, forKey: "X-Algolia-QueryParameters")
            } else {
                manager.session.configuration.HTTPAdditionalHeaders?.removeValueForKey("X-Algolia-QueryParameters")
            }
        }
    }

    /// Security tag header (deprecated)
    public var tagFilters: String? {
        didSet {
            if let tagFilters = tagFilters {
                setExtraHeader(tagFilters, forKey: "X-Algolia-TagFilters")
            } else {
                manager.session.configuration.HTTPAdditionalHeaders?.removeValueForKey("X-Algolia-TagFilters")
            }
        }
    }

    /// User-token header
    public var userToken: String? {
        didSet {
            if let userToken = userToken {
                setExtraHeader(userToken, forKey: "X-Algolia-UserToken")
            } else {
                manager.session.configuration.HTTPAdditionalHeaders?.removeValueForKey("X-Algolia-UserToken")
            }
        }
    }

    private let timeout: NSTimeInterval = 30
    private let searchTimeout: NSTimeInterval = 5
    private let incrementTimeout: NSTimeInterval = 10

    public let appID: String

    let readQueryHostnames: [String]
    let writeQueryHostnames: [String]

    private let manager: Manager
    private var requestBuffer = RingBuffer<Request>(maxCapacity: 10)

    /// Algolia Search initialization.
    ///
    /// - parameter appID: the application ID you have in your admin interface
    /// - parameter apiKey: a valid API key for the service
    /// - parameter queryParameters: value of the header X-Algolia-QueryParameters
    /// - parameter tagFilters: value of the header X-Algolia-TagFilters (deprecated)
    /// - parameter userToken: value of the header X-Algolia-UserToken
    /// - parameter hostnames: the list of hosts that you have received for the service
    public init(appID: String, apiKey: String, queryParameters: String? = nil, tagFilters: String? = nil, userToken: String? = nil, hostnames: [String]? = nil) {
        self.appID = appID
        self.apiKey = apiKey
        self.tagFilters = tagFilters
        self.userToken = userToken
        self.queryParameters = queryParameters

        if let hostnames = hostnames {
            readQueryHostnames = hostnames
            writeQueryHostnames = hostnames
        } else {
            readQueryHostnames = [
                "\(appID)-dsn.algolia.net",
                "\(appID)-1.algolianet.com",
                "\(appID)-2.algolianet.com",
                "\(appID)-3.algolianet.com"
            ]
            
            writeQueryHostnames = [
                "\(appID).algolia.net",
                "\(appID)-1.algolianet.com",
                "\(appID)-2.algolianet.com",
                "\(appID)-3.algolianet.com"
            ]
        }
        
        let version = NSBundle(forClass: self.dynamicType).infoDictionary!["CFBundleShortVersionString"] as! String

        var HTTPHeaders = [
            "X-Algolia-API-Key": self.apiKey,
            "X-Algolia-Application-Id": self.appID,
            "User-Agent": "Algolia for Swift \(version)"
        ]

        if let queryParameters = self.queryParameters {
            HTTPHeaders["X-Algolia-QueryParameters"] = queryParameters
        }
        if let tagFilters = self.tagFilters {
            HTTPHeaders["X-Algolia-TagFilters"] = tagFilters
        }
        if let userToken = self.userToken {
            HTTPHeaders["X-Algolia-UserToken"] = userToken
        }

        manager = Manager(HTTPHeaders: HTTPHeaders)
    }
    
    // Helper for Obj-C
    public class func clientWithAppID(appID: String, apiKey: String) -> Client {
        return Client(appID: appID, apiKey: apiKey)
    }
    
    // Helper for Obj-C
    public class func clientWithQueryParameters(queryParameters: String, appID: String, apiKey: String) -> Client {
        return Client(appID: appID, apiKey: apiKey, queryParameters: queryParameters)
    }

    /// Allow to set custom extra header.
    ///
    /// - parameter value: value of the header
    /// - parameter forKey: key of the header
    public func setExtraHeader(value: String, forKey key: String) {
        if (manager.session.configuration.HTTPAdditionalHeaders != nil) {
            manager.session.configuration.HTTPAdditionalHeaders!.updateValue(value, forKey: key)
        } else {
            let HTTPHeader = [key: value]
            manager.session.configuration.HTTPAdditionalHeaders = HTTPHeader
        }
    }

    // MARK: - Operations

    /// List all existing indexes.
    ///
    /// :return: JSON Object in the handler in the form: { "items": [ {"name": "contacts", "createdAt": "2013-01-18T15:33:13.556Z"}, {"name": "notes", "createdAt": "2013-01-18T15:33:13.556Z"}]}
    public func listIndexes(block: CompletionHandler) {
        performHTTPQuery("1/indexes", method: .GET, body: nil, hostnames: readQueryHostnames, block: block)
    }

    /// Delete an index.
    ///
    /// - parameter indexName: the name of index to delete
    /// :return: JSON Object in the handler containing a "deletedAt" attribute
    public func deleteIndex(indexName: String, block: CompletionHandler? = nil) {
        let path = "1/indexes/\(indexName.urlEncode())"
        performHTTPQuery(path, method: .DELETE, body: nil, hostnames: writeQueryHostnames, block: block)
    }

    /// Move an existing index.
    ///
    /// - parameter srcIndexName: the name of index to move.
    /// - parameter dstIndexName: the new index name that will contains sourceIndexName (destination will be overriten if it already exist).
    public func moveIndex(srcIndexName: String, to dstIndexName: String, block: CompletionHandler? = nil) {
        let path = "1/indexes/\(srcIndexName.urlEncode())/operation"
        let request = [
            "destination": dstIndexName,
            "operation": "move"
        ]

        performHTTPQuery(path, method: .POST, body: request, hostnames: writeQueryHostnames, block: block)
    }

    /// Copy an existing index.
    ///
    /// - parameter srcIndexName: the name of index to copy.
    /// - parameter dstIndexName: the new index name that will contains a copy of sourceIndexName (destination will be overriten if it already exist).
    public func copyIndex(srcIndexName: String, to dstIndexName: String, block: CompletionHandler? = nil) {
        let path = "1/indexes/\(srcIndexName.urlEncode())/operation"
        let request = [
            "destination": dstIndexName,
            "operation": "copy"
        ]

        performHTTPQuery(path, method: .POST, body: request, hostnames: writeQueryHostnames, block: block)
    }

    /// Return 10 last log entries.
    public func getLogs(block: CompletionHandler) {
        performHTTPQuery("1/logs", method: .GET, body: nil, hostnames: writeQueryHostnames, block: block)
    }

    /// Return last logs entries.
    ///
    /// - parameter offset: Specify the first entry to retrieve (0-based, 0 is the most recent log entry).
    /// - parameter length: Specify the maximum number of entries to retrieve starting at offset. Maximum allowed value: 1000.
    public func getLogsWithOffset(offset: UInt, length: UInt, block: CompletionHandler) {
        let path = "1/logs?offset=\(offset)&length=\(length)"
        performHTTPQuery(path, method: .GET, body: nil, hostnames: readQueryHostnames, block: block)
    }

    /// Return last logs entries.
    ///
    /// - parameter offset: Specify the first entry to retrieve (0-based, 0 is the most recent log entry).
    /// - parameter length: Specify the maximum number of entries to retrieve starting at offset. Maximum allowed value: 1000.
    public func getLogsWithType(type: String, offset: UInt, length: UInt, block: CompletionHandler) {
        let path = "1/logs?offset=\(offset)&length=\(length)&type=\(type)"
        performHTTPQuery(path, method: .GET, body: nil, hostnames: readQueryHostnames, block: block)
    }

    /// Get the index object initialized (no server call needed for initialization).
    ///
    /// - parameter indexName: the name of index
    public func getIndex(indexName: String) -> Index {
        return Index(client: self, indexName: indexName)
    }

    /// List all existing user keys with their associated ACLs.
    public func listUserKeys(block: CompletionHandler) {
        performHTTPQuery("1/keys", method: .GET, body: nil, hostnames: readQueryHostnames, block: block)
    }

    /// Get ACL of a user key.
    public func getUserKeyACL(key: String, block: CompletionHandler) {
        let path = "1/keys/\(key)"
        performHTTPQuery(path, method: .GET, body: nil, hostnames: readQueryHostnames, block: block)
    }

    /// Delete an existing user key.
    public func deleteUserKey(key: String, block: CompletionHandler? = nil) {
        let path = "1/keys/\(key)"
        performHTTPQuery(path, method: .DELETE, body: nil, hostnames: writeQueryHostnames, block: block)
    }

    /// Create a new user key
    ///
    /// - parameter acls: The list of ACL for this key. The list can contains the following values (as String): search, addObject, deleteObject, deleteIndex, settings, editSettings
    public func addUserKey(acls: [String], block: CompletionHandler? = nil) {
        let request = ["acl": acls]
        performHTTPQuery("1/keys", method: .POST, body: request, hostnames: writeQueryHostnames, block: block)
    }

    /// Create a new user key
    ///
    /// - parameter acls: The list of ACL for this key. The list can contains the following values (as String): search, addObject, deleteObject, deleteIndex, settings, editSettings
    /// - parameter withValidity: The number of seconds after which the key will be automatically removed (0 means no time limit for this key)
    /// - parameter maxQueriesPerIPPerHour: Specify the maximum number of API calls allowed from an IP address per hour.  Defaults to 0 (unlimited).
    /// - parameter maxHitsPerQuery: Specify the maximum number of hits this API key can retrieve in one call. Defaults to 0 (unlimited)
    public func addUserKey(acls: [String], withValidity validity: UInt, maxQueriesPerIPPerHour maxQueries: UInt, maxHitsPerQuery maxHits: UInt, block: CompletionHandler? = nil) {
        let request: [String: AnyObject] = [
            "acl": acls,
            "validity": validity,
            "maxQueriesPerIPPerHour": maxQueries,
            "maxHitsPerQuery": maxHits,
        ]

        performHTTPQuery("1/keys", method: .POST, body: request, hostnames: writeQueryHostnames, block: block)
    }

    /// Create a new user key
    ///
    /// - parameter acls: The list of ACL for this key. The list can contains the following values (as String): search, addObject, deleteObject, deleteIndex, settings, editSettings
    /// - parameter forIndexes: restrict this new API key to specific index names
    /// - parameter withValidity: The number of seconds after which the key will be automatically removed (0 means no time limit for this key)
    /// - parameter maxQueriesPerIPPerHour: Specify the maximum number of API calls allowed from an IP address per hour.  Defaults to 0 (unlimited).
    /// - parameter maxHitsPerQuery: Specify the maximum number of hits this API key can retrieve in one call. Defaults to 0 (unlimited)
    public func addUserKey(acls: [String], forIndexes indexes: [String], withValidity validity: UInt, maxQueriesPerIPPerHour maxQueries: UInt, maxHitsPerQuery maxHits: UInt, block: CompletionHandler? = nil) {
        let request: [String: AnyObject] = [
            "acl": acls,
            "indexes": indexes,
            "validity": validity,
            "maxQueriesPerIPPerHour": maxQueries,
            "maxHitsPerQuery": maxHits,
        ]

        performHTTPQuery("1/keys", method: .POST, body: request, hostnames: writeQueryHostnames, block: block)
    }

    /// Update a user key
    ///
    /// - parameter key: The key to update
    /// - parameter withAcls: The list of ACL for this key. The list can contains the following values (as String): search, addObject, deleteObject, deleteIndex, settings, editSettings
    public func updateUserKey(key: String, withACL acls: [String], block: CompletionHandler? = nil) {
        let path = "1/keys/\(key)"
        let request = ["acl": acls]
        performHTTPQuery(path, method: .PUT, body: request, hostnames: writeQueryHostnames, block: block)
    }

    /// Update a user key
    ///
    /// - parameter key: The key to update
    /// - parameter withAcls: The list of ACL for this key. The list can contains the following values (as String): search, addObject, deleteObject, deleteIndex, settings, editSettings
    /// - parameter andValidity: The number of seconds after which the key will be automatically removed (0 means no time limit for this key)
    /// - parameter maxQueriesPerIPPerHour: Specify the maximum number of API calls allowed from an IP address per hour.  Defaults to 0 (unlimited).
    /// - parameter maxHitsPerQuery: Specify the maximum number of hits this API key can retrieve in one call. Defaults to 0 (unlimited)
    public func updateUserKey(key: String, withACL acls: [String], andValidity validity: UInt, maxQueriesPerIPPerHour maxQueries: UInt, maxHitsPerQuery maxHits: UInt, block: CompletionHandler? = nil) {
        let path = "1/keys/\(key)"
        let request: [String: AnyObject] = [
            "acl": acls,
            "validity": validity,
            "maxQueriesPerIPPerHour": maxQueries,
            "maxHitsPerQuery": maxHits,
        ]

        performHTTPQuery(path, method: .PUT, body: request, hostnames: writeQueryHostnames, block: block)
    }

    /// Update a user key
    ///
    /// - parameter key: The key to update
    /// - parameter withAcls: The list of ACL for this key. The list can contains the following values (as String): search, addObject, deleteObject, deleteIndex, settings, editSettings
    /// - parameter andValidity: The number of seconds after which the key will be automatically removed (0 means no time limit for this key)
    /// - parameter forIndexes: restrict this API key to specific index names
    /// - parameter maxQueriesPerIPPerHour: Specify the maximum number of API calls allowed from an IP address per hour.  Defaults to 0 (unlimited).
    /// - parameter maxHitsPerQuery: Specify the maximum number of hits this API key can retrieve in one call. Defaults to 0 (unlimited)
    public func updateUserKey(key: String, withACL acls: [String], andValidity validity: UInt, forIndexes indexes: [String], maxQueriesPerIPPerHour maxQueries: UInt, maxHitsPerQuery maxHits: UInt, block: CompletionHandler? = nil) {
        let path = "1/keys/\(key)"
        let request: [String: AnyObject] = [
            "acl": acls,
            "indexes": indexes,
            "validity": validity,
            "maxQueriesPerIPPerHour": maxQueries,
            "maxHitsPerQuery": maxHits,
        ]

        performHTTPQuery(path, method: .PUT, body: request, hostnames: writeQueryHostnames, block: block)
    }

    /// Query multiple indexes with one API call.
    ///
    /// - parameter queries: An array of queries with the associated index (Array of Dictionnary object ["indexName": "targettedIndex", "query": QueryObject]).
    public func multipleQueries(queries: [AnyObject], block: CompletionHandler? = nil) {
        let path = "1/indexes/*/queries"

        var convertedQueries = [[String: String]]()
        convertedQueries.reserveCapacity(queries.count)
        for query in queries {
            if let query = query as? [String: AnyObject] {
                convertedQueries.append([
                    "params": (query["query"] as! Query).buildURL(),
                    "indexName": query["indexName"] as! String
                    ])
            }
        }

        let request = ["requests": convertedQueries]
        performHTTPQuery(path, method: .POST, body: request, hostnames: readQueryHostnames, block: block)
    }

    // MARK: - Network

    /// Perform an HTTP Query.
    func performHTTPQuery(path: String, method: HTTPMethod, body: [String: AnyObject]?, hostnames: [String], isSearchQuery: Bool = false, index: Int = 0, block: CompletionHandler? = nil) {
        assert(index < hostnames.count, "\(index) < \(hostnames.count) !")

        var currentTimeout = (isSearchQuery) ? searchTimeout : timeout
        if index > 1 {
            currentTimeout += incrementTimeout
        }
        manager.session.configuration.timeoutIntervalForRequest = currentTimeout

        let request = manager.request(method, "https://\(hostnames[index])/\(path)", parameters: body) { (response, data, error) -> Void in
            if let statusCode = response?.statusCode {
                if let block = block {
                    switch(statusCode) {
                    case 200..<300 where data is [String: AnyObject]:
                        block(content: (data as! [String: AnyObject]), error: nil)
                    default:
                        if let data = data as? [String: AnyObject], errorMessage = data["message"] as? String {
                            block(content: nil, error: NSError(domain: errorMessage, code: statusCode, userInfo: nil))
                        } else {
                            block(content: nil, error: NSError(domain: "No error message", code: 0, userInfo: nil))
                        }
                    }
                }
            } else {
                if (index + 1) < hostnames.count {
                    self.performHTTPQuery(path, method: method, body: body, hostnames: hostnames, isSearchQuery: isSearchQuery, index: index + 1, block: block)
                } else {
                    block?(content: nil, error: error)
                }
            }
        }

        requestBuffer.append(request)
    }

    /// Cancel a queries. Only the last ten queries can be cancelled.
    func cancelQueries(method: HTTPMethod, path: String) {
        for request in requestBuffer {
            if request.request.URL!.path! == path {
                if request.request.HTTPMethod == method.rawValue {
                    request.cancel()
                }
            }
        }
    }
}
