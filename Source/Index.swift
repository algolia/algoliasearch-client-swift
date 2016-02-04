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

#if ALGOLIA_SDK
    import AlgoliaSearchSDK
#endif

/// Contains all the functions related to one index
///
/// You can use Client.getIndex(indexName) to retrieve this object
public class Index : NSObject {
    public let indexName: String
    public let client: Client
    private let urlEncodedIndexName: String
    
    private var searchCache: ExpiringCache?
    
    public init(client: Client, indexName: String) {
        self.client = client
        self.indexName = indexName
        urlEncodedIndexName = indexName.urlEncode()
    }
    
    /// Add an object in this index
    ///
    /// - parameter object: The object to add inside the index.
    public func addObject(object: [String: AnyObject], block: CompletionHandler? = nil) {
        let path = "1/indexes/\(urlEncodedIndexName)"
        client.performHTTPQuery(path, method: .POST, body: object, hostnames: client.writeQueryHostnames, block: block)
    }
    
    /// Add an object in this index
    ///
    /// - parameter object: The object to add inside the index.
    /// - parameter withID: An objectID you want to attribute to this object (if the attribute already exist, the old object will be overwrite)
    public func addObject(object: [String: AnyObject], withID objectID: String, block: CompletionHandler? = nil) {
        let path = "1/indexes/\(urlEncodedIndexName)/\(objectID.urlEncode())"
        client.performHTTPQuery(path, method: .PUT, body: object, hostnames: client.writeQueryHostnames, block: block)
    }
    
    /// Add several objects in this index
    ///
    /// - parameter objects: An array of objects to add (Array of Dictionnary object).
    public func addObjects(objects: [AnyObject], block: CompletionHandler? = nil) {
        let path = "1/indexes/\(urlEncodedIndexName)/batch"
        
        var requests = [AnyObject]()
        requests.reserveCapacity(objects.count)
        for object in objects {
            requests.append(["action": "addObject", "body": object])
        }
        let request = ["requests": requests]
        
        client.performHTTPQuery(path, method: .POST, body: request, hostnames: client.writeQueryHostnames, block: block)
    }
    
    /// Delete an object from the index
    ///
    /// - parameter objectID: The unique identifier of object to delete
    public func deleteObject(objectID: String, block: CompletionHandler? = nil) {
        let path = "1/indexes/\(urlEncodedIndexName)/\(objectID.urlEncode())"
        client.performHTTPQuery(path, method: .DELETE, body: nil, hostnames: client.writeQueryHostnames, block: block)
    }
    
    /// Delete several objects
    ///
    /// - parameter objectIDs: An array of objectID to delete.
    public func deleteObjects(objectIDs: [String], block: CompletionHandler? = nil) {
        let path = "1/indexes/\(urlEncodedIndexName)/batch"
        
        var requests = [AnyObject]()
        requests.reserveCapacity(objectIDs.count)
        for id in objectIDs {
            requests.append(["action": "deleteObject", "objectID": id])
        }
        let request = ["requests": requests]
        
        client.performHTTPQuery(path, method: .POST, body: request, hostnames: client.writeQueryHostnames, block: block)
    }
    
    /// Get an object from this index
    ///
    /// - parameter objectID: The unique identifier of the object to retrieve
    public func getObject(objectID: String, block: CompletionHandler) {
        let path = "1/indexes/\(urlEncodedIndexName)/\(objectID.urlEncode())"
        client.performHTTPQuery(path, method: .GET, body: nil, hostnames: client.readQueryHostnames, block: block)
    }
    
    /// Get an object from this index
    ///
    /// - parameter objectID: The unique identifier of the object to retrieve
    /// - parameter attributesToRetrieve: The list of attributes to retrieve
    public func getObject(objectID: String, attributesToRetrieve attributes: [String], block: CompletionHandler) {
        let urlEncodedAttributes = Query.encodeForQuery(attributes, withKey: "attributes")
        let path = "1/indexes/\(urlEncodedIndexName)/\(objectID.urlEncode())?\(urlEncodedAttributes)"
        client.performHTTPQuery(path, method: .GET, body: nil, hostnames: client.readQueryHostnames, block: block)
    }
    
    /// Get several objects from this index
    ///
    /// - parameter objectIDs: The array of unique identifier of objects to retrieve
    public func getObjects(objectIDs: [String], block: CompletionHandler) {
        let path = "1/indexes/*/objects"
        
        var requests = [AnyObject]()
        requests.reserveCapacity(objectIDs.count)
        for id in objectIDs {
            requests.append(["indexName": indexName, "objectID": id])
        }
        let request = ["requests": requests]
        
        client.performHTTPQuery(path, method: .POST, body: request, hostnames: client.readQueryHostnames, block: block)
    }
    
    /// Update partially an object (only update attributes passed in argument)
    ///
    /// - parameter object: The object attributes to override, the object must contains an objectID attribute
    public func partialUpdateObject(partialObject: [String: AnyObject], objectID: String, block: CompletionHandler? = nil) {
        let path = "1/indexes/\(urlEncodedIndexName)/\(objectID.urlEncode())/partial"
        client.performHTTPQuery(path, method: .POST, body: partialObject, hostnames: client.writeQueryHostnames, block: block)
    }
    
    /// Update partially the content of several objects
    ///
    /// - parameter objects: An array of Dictionary to update (each Dictionary must contains an objectID attribute)
    public func partialUpdateObjects(objects: [AnyObject], block: CompletionHandler? = nil) {
        let path = "1/indexes/\(urlEncodedIndexName)/batch"
        
        var requests = [AnyObject]()
        requests.reserveCapacity(objects.count)
        for object in objects {
            if let object = object as? [String: AnyObject] {
                requests.append([
                    "action": "partialUpdateObject",
                    "objectID": object["objectID"] as! String,
                    "body": object
                    ])
            }
        }
        let request = ["requests": requests]
        
        client.performHTTPQuery(path, method: .POST, body: request, hostnames: client.writeQueryHostnames, block: block)
    }
    
    /// Override the content of object
    ///
    /// - parameter object: The object to override, the object must contains an objectID attribute
    public func saveObject(object: [String: AnyObject], block: CompletionHandler? = nil) {
        if let objectID = object["objectID"] as? String {
            let path = "1/indexes/\(urlEncodedIndexName)/\(objectID.urlEncode())"
            client.performHTTPQuery(path, method: .PUT, body: object, hostnames: client.writeQueryHostnames, block: block)
        }
    }
    
    /// Override the content of several objects
    ///
    /// - parameter objects: An array of Dictionary to save (each Dictionary must contains an objectID attribute)
    public func saveObjects(objects: [AnyObject], block: CompletionHandler? = nil) {
        let path = "1/indexes/\(urlEncodedIndexName)/batch"
        
        var requests = [AnyObject]()
        requests.reserveCapacity(objects.count)
        for object in objects {
            if let object = object as? [String: AnyObject] {
                requests.append([
                    "action": "updateObject",
                    "objectID": object["objectID"] as! String,
                    "body": object
                    ])
            }
        }
        let request = ["requests": requests]
        
        client.performHTTPQuery(path, method: .POST, body: request, hostnames: client.writeQueryHostnames, block: block)
    }
    
    /// Search inside the index
    public func search(query: Query, block: CompletionHandler) {
        let path = "1/indexes/\(urlEncodedIndexName)/query"
        let request = ["params": query.buildURL()]
        
        // First try the in-memory query cache.
        let cacheKey = "\(path)_body_\(request)"
        if let content = searchCache?.objectForKey(cacheKey) {
            block(content: content, error: nil)
        }
        // Otherwise, run an online query.
        else {
            client.performHTTPQuery(path, method: .POST, body: request, hostnames: client.readQueryHostnames, isSearchQuery: true) { (content, error) -> Void in
                assert(content != nil || error != nil)
                if content != nil {
                    self.searchCache?.setObject(content!, forKey: cacheKey)
                    block(content: content, error: error)
                } else if isErrorTransient(error!) && self.mirrored {
                    self.searchMirror(query, block: block)
                }
                else {
                    block(content: content, error: error)
                }
            }
        }
    }
    
    /// Delete all previous search queries
    public func cancelPreviousSearch() {
        client.cancelQueries(.POST, path: "1/indexes/\(urlEncodedIndexName)/query")
    }
    
    /// Wait the publication of a task on the server.
    /// All server task are asynchronous and you can check with this method that the task is published.
    ///
    /// - parameter taskID: The ID of the task returned by server
    public func waitTask(taskID: Int, block: CompletionHandler) {
        let path = "1/indexes/\(urlEncodedIndexName)/task/\(taskID)"
        client.performHTTPQuery(path, method: .GET, body: nil, hostnames: client.readQueryHostnames, block: { (content, error) -> Void in
            if let content = content {
                if (content["status"] as? String) == "published" {
                    block(content: content, error: nil)
                } else {
                    NSThread.sleepForTimeInterval(0.1)
                    self.waitTask(taskID, block: block)
                }
            } else {
                block(content: content, error: error)
            }
        })
    }
    
    /// Get settings of this index
    public func getSettings(block: CompletionHandler) {
        let path = "1/indexes/\(urlEncodedIndexName)/settings"
        client.performHTTPQuery(path, method: .GET, body: nil, hostnames: client.readQueryHostnames, block: block)
    }
    
    /// Set settings for this index
    ///
    /// - parameter settings: The settings object
    ///
    /// NB: The settings object can contains :
    ///
    /// - minWordSizefor1Typo: (integer) the minimum number of characters to accept one typo (default = 3).
    /// - minWordSizefor2Typos: (integer) the minimum number of characters to accept two typos (default = 7).
    /// - hitsPerPage: (integer) the number of hits per page (default = 10).
    /// - attributesToRetrieve: (array of strings) default list of attributes to retrieve in objects. If set to null, all attributes are retrieved.
    /// - attributesToHighlight: (array of strings) default list of attributes to highlight. If set to null, all indexed attributes are highlighted.
    /// - attributesToSnippet: (array of strings) default list of attributes to snippet alongside the number of words to return (syntax is attributeName:nbWords). By default no snippet is computed. If set to null, no snippet is computed.
    /// - attributesToIndex: (array of strings) the list of fields you want to index. If set to null, all textual and numerical attributes of your objects are indexed, but you should update it to get optimal results. This parameter has two important uses:
    ///     - Limit the attributes to index: For example if you store a binary image in base64, you want to store it and be able to retrieve it but you don't want to search in the base64 string.
    ///     - Control part of the ranking*: (see the ranking parameter for full explanation) Matches in attributes at the beginning of the list will be considered more important than matches in attributes further down the list. In one attribute, matching text at the beginning of the attribute will be considered more important than text after, you can disable this behavior if you add your attribute inside `unordered(AttributeName)`, for example attributesToIndex: ["title", "unordered(text)"].
    /// - attributesForFaceting: (array of strings) The list of fields you want to use for faceting. All strings in the attribute selected for faceting are extracted and added as a facet. If set to null, no attribute is used for faceting.
    /// - ranking: (array of strings) controls the way results are sorted. We have six available criteria:
    ///     - typo: sort according to number of typos,
    ///     - geo: sort according to decreassing distance when performing a geo-location based search,
    ///     - proximity: sort according to the proximity of query words in hits,
    ///     - attribute: sort according to the order of attributes defined by attributesToIndex,
    ///     - exact: sort according to the number of words that are matched identical to query word (and not as a prefix),
    ///     - custom: sort according to a user defined formula set in customRanking attribute. The standard order is ["typo", "geo", "proximity", "attribute", "exact", "custom"]
    /// - customRanking: (array of strings) lets you specify part of the ranking. The syntax of this condition is an array of strings containing attributes prefixed by asc (ascending order) or desc (descending order) operator. For example `"customRanking" => ["desc(population)", "asc(name)"]`
    /// - queryType: Select how the query words are interpreted, it can be one of the following value:
    ///     - prefixAll: all query words are interpreted as prefixes,
    ///     - prefixLast: only the last word is interpreted as a prefix (default behavior),
    ///     - prefixNone: no query word is interpreted as a prefix. This option is not recommended.
    /// - highlightPreTag: (string) Specify the string that is inserted before the highlighted parts in the query result (default to "<em>").
    /// - highlightPostTag: (string) Specify the string that is inserted after the highlighted parts in the query result (default to "</em>").
    /// - optionalWords: (array of strings) Specify a list of words that should be considered as optional when found in the query.
    public func setSettings(settings: [String: AnyObject], block: CompletionHandler? = nil) {
        let path = "1/indexes/\(urlEncodedIndexName)/settings"
        client.performHTTPQuery(path, method: .PUT, body: settings, hostnames: client.writeQueryHostnames, block: block)
    }
    
    /// Delete the index content without removing settings and index specific API keys.
    public func clearIndex(block: CompletionHandler? = nil) {
        let path = "1/indexes/\(urlEncodedIndexName)/clear"
        client.performHTTPQuery(path, method: .POST, body: nil, hostnames: client.writeQueryHostnames, block: block)
    }
    
    /// List all existing user keys associated to this index
    public func listUserKeys(block: CompletionHandler) {
        let path = "1/indexes/\(urlEncodedIndexName)/keys"
        client.performHTTPQuery(path, method: .GET, body: nil, hostnames: client.readQueryHostnames, block: block)
    }
    
    /// List all existing user keys associated to this index
    public func getUserKeyACL(key: String, block: CompletionHandler) {
        let path = "1/indexes/\(urlEncodedIndexName)/keys/\(key.urlEncode())"
        client.performHTTPQuery(path, method: .GET, body: nil, hostnames: client.readQueryHostnames, block: block)
    }
    
    /// Delete an existing user key associated to this index
    public func deleteUserKey(key: String, block: CompletionHandler? = nil) {
        let path = "1/indexes/\(urlEncodedIndexName)/keys/\(key.urlEncode())"
        client.performHTTPQuery(path, method: .DELETE, body: nil, hostnames: client.writeQueryHostnames, block: block)
    }
    
    /// Create a new user key associated to this index
    ///
    /// - parameter acls: The list of ACL for this key. The list can contains the following values (as String): search, addObject, deleteObject, deleteIndex, settings, editSettings
    public func addUserKey(acls: [String], block: CompletionHandler? = nil) {
        let path = "1/indexes/\(urlEncodedIndexName)/keys"
        let request = ["acl": acls]
        client.performHTTPQuery(path, method: .POST, body: request, hostnames: client.writeQueryHostnames, block: block)
    }
    
    /// Create a new user key associated to this index
    ///
    /// - parameter acls: The list of ACL for this key. The list can contains the following values (as String): search, addObject, deleteObject, deleteIndex, settings, editSettings
    /// - parameter withValidity: The number of seconds after which the key will be automatically removed (0 means no time limit for this key)
    /// - parameter maxQueriesPerIPPerHour: Specify the maximum number of API calls allowed from an IP address per hour.  Defaults to 0 (unlimited).
    /// - parameter maxHitsPerQuery: Specify the maximum number of hits this API key can retrieve in one call. Defaults to 0 (unlimited)
    public func addUserKey(acls: [String], withValidity validity: UInt, maxQueriesPerIPPerHour maxQueries: UInt, maxHitsPerQuery maxHits: UInt, block: CompletionHandler? = nil) {
        let path = "1/indexes/\(urlEncodedIndexName)/keys"
        let request: [String: AnyObject] = [
            "acl": acls,
            "validity": validity,
            "maxQueriesPerIPPerHour": maxQueries,
            "maxHitsPerQuery": maxHits,
        ]
        
        client.performHTTPQuery(path, method: .POST, body: request, hostnames: client.writeQueryHostnames, block: block)
    }
    
    /// Update a user key associated to this index
    ///
    /// - parameter withACL: The list of ACL for this key. The list can contains the following values (as String): search, addObject, deleteObject, deleteIndex, settings, editSettings
    public func updateUserKey(key: String, withACL acls: [String], block: CompletionHandler? = nil) {
        let path = "1/indexes/\(urlEncodedIndexName)/keys/\(key.urlEncode())"
        let request = ["acl": acls]
        client.performHTTPQuery(path, method: .PUT, body: request, hostnames: client.writeQueryHostnames, block: block)
    }
    
    /// Update a user key associated to this index
    ///
    /// - parameter withACL: The list of ACL for this key. The list can contains the following values (as String): search, addObject, deleteObject, deleteIndex, settings, editSettings
    /// - parameter andValidity: The number of seconds after which the key will be automatically removed (0 means no time limit for this key)
    /// - parameter maxQueriesPerIPPerHour: Specify the maximum number of API calls allowed from an IP address per hour.  Defaults to 0 (unlimited).
    /// - parameter maxHitsPerQuery: Specify the maximum number of hits this API key can retrieve in one call. Defaults to 0 (unlimited)
    public func updateUserKey(key: String, withACL acls: [String], andValidity validity: UInt, maxQueriesPerIPPerHour maxQueries: UInt, maxHitsPerQuery maxHits: UInt, block: CompletionHandler? = nil) {
        let path = "1/indexes/\(urlEncodedIndexName)/keys/\(key.urlEncode())"
        let request: [String: AnyObject] = [
            "acl": acls,
            "validity": validity,
            "maxQueriesPerIPPerHour": maxQueries,
            "maxHitsPerQuery": maxHits,
        ]
        
        client.performHTTPQuery(path, method: .PUT, body: request, hostnames: client.writeQueryHostnames, block: block)
    }
    
    /// Browse all index content
    ///
    /// - parameter page: Pagination parameter used to select the page to retrieve. Page is zero-based and defaults to 0. Thus, to retrieve the 10th page you need to set page=9
    /// - parameter hitsPerPage: Pagination parameter used to select the number of hits per page. Defaults to 1000.
    public func browse(page: UInt = 0, hitsPerPage: UInt = 1000, block: CompletionHandler) {
        let path = "1/indexes/\(urlEncodedIndexName)/browse?page=\(page)&hitsPerPage=\(hitsPerPage)"
        client.performHTTPQuery(path, method: .GET, body: nil, hostnames: client.readQueryHostnames, block: block)
    }
    
    // MARK: - Browse
    
    public typealias BrowseIteratorHandler = (iterator: BrowseIterator, end: Bool, error: NSError?) -> Void
    
    public class BrowseIterator {
        public let index: Index
        public var cursor: String
        
        public var result: [String: AnyObject]?
        
        private let path: String
        private let queryURL: String
        private let block: BrowseIteratorHandler
        private var end = false
        
        private init(index: Index, query: Query?, cursor: String?, block: BrowseIteratorHandler) {
            self.index = index
            self.cursor = cursor ?? ""
            self.block = block
            
            queryURL = query?.buildURL() ?? ""
            path = "1/indexes/\(index.urlEncodedIndexName)/browse?"
        }
        
        convenience init(index: Index, query: Query, block: BrowseIteratorHandler) {
            self.init(index: index, query: query, cursor: nil, block: block)
        }
        
        convenience init(index: Index, cursor: String, block: BrowseIteratorHandler) {
            self.init(index: index, query: nil, cursor: cursor, block: block)
        }
        
        public func next() {
            let requestPath: String
            if cursor == "" {
                requestPath = "\(path)\(queryURL)"
            } else {
                requestPath = "\(path)cursor=\(cursor.urlEncode())"
            }
            
            index.client.performHTTPQuery(requestPath, method: .GET, body: nil, hostnames: index.client.readQueryHostnames) { (content, error) -> Void in
                if let error = error {
                    self.block(iterator: self, end: false, error: error)
                } else {
                    self.result = content
                    if let cursor = content!["cursor"] as? String {
                        self.cursor = cursor
                    } else {
                        self.end = true
                    }
                    
                    self.block(iterator: self, end: self.end, error: nil)
                }
            }
        }
    }
    
    /// Browse all index content.
    ///
    /// The iterator object has a parameter `result` that contains the result of the current page.
    /// At the end of the block handler, call the method `next()` of the iterator object to get the next page.
    /// The parameter `end` is set to true when all the index was browsed.
    ///
    /// - parameter query: The query parameters for the browse.
    public func browse(query: Query, block: BrowseIteratorHandler) {
        let iterator = BrowseIterator(index: self, query: query, block: block)
        iterator.next() // first call
    }
    
    /// Browse the index from a cursor.
    ///
    /// The iterator object has a parameter `result` that contains the result of the current page.
    /// At the end of the block handler, call the method `next()` of the iterator object to get the next page.
    /// The parameter `end` is set to true when all the index was browsed.
    ///
    /// - parameter cursor: The cursor of the next page to retrieve
    public func browseFrom(cursor: String, block: BrowseIteratorHandler) {
        let iterator = BrowseIterator(index: self, cursor: cursor, block: block)
        iterator.next()
    }
    
    // MARK: - Search Cache
    
    /// Enable search cache.
    ///
    /// - parameter expiringTimeInterval: Each cached search will be valid during this interval of time
    public func enableSearchCache(expiringTimeInterval: NSTimeInterval = 120) {
        searchCache = ExpiringCache(expiringTimeInterval: expiringTimeInterval)
    }
    
    /// Disable search cache
    public func disableSearchCache() {
        searchCache?.clearCache()
        searchCache = nil
    }
    
    /// Clear search cache
    public func clearSearchCache() {
        searchCache?.clearCache()
    }

// ----------------------------------------------------------------------
// NOTICE: Start of SDK-dependent code
// ----------------------------------------------------------------------

#if ALGOLIA_SDK
    /// The local index mirroring this remote index (lazy instantiated, only if mirroring is activated).
    lazy var localIndex: ASLocalIndex? = ASLocalIndex(dataDir: self.client.rootDataDir!, appID: self.client.appID, indexName: self.indexName)

    /// The mirrored index settings.
    let mirrorSettings = MirrorSettings()
    
    /// Whether the index is mirrored locally. Default = false.
    public var mirrored: Bool = false {
        didSet {
            if (mirrored) {
                do {
                    try NSFileManager.defaultManager().createDirectoryAtPath(self.indexDataDir, withIntermediateDirectories: true, attributes: nil)
                } catch _ {
                    // Ignore
                }
                mirrorSettings.load(self.mirrorSettingsFilePath)
            }
        }
    }
    
    /// Data selection queries.
    public var queries: [String] {
        get { return mirrorSettings.queries }
        set {
            mirrorSettings.queries = newValue
            mirrorSettings.queriesModificationDate = NSDate()
            mirrorSettings.save(mirrorSettingsFilePath)
        }
    }
    
    /// Time interval between two syncs. Default = 1 hour.
    public var delayBetweenSyncs : NSTimeInterval = 60 * 60
    
    // Sync status:

    /// Syncing indicator.
    /// NOTE: To prevent concurrent access to this variable, we always access it from the main thread.
    private var syncing: Bool = false
    
    private var tmpDir : String?
    private var syncError : Bool = false
    private var settingsFilePath: String?
    private var objectsFilePaths: [String]?
    
    private var mirrorSettingsFilePath: String {
        get { return "\(self.indexDataDir)/mirror.plist" }
    }
    
    private var indexDataDir: String {
        get { return "\(self.client.rootDataDir!)/\(self.client.appID)/\(self.indexName)" }
    }
    
    // TODO: Move to top-level/other file?
    class MirrorSettings {
        var lastSyncDate: NSDate = NSDate(timeIntervalSince1970: 0)
        var queries : [String] = [] ///< Data selection queries.
        var queriesModificationDate: NSDate = NSDate(timeIntervalSince1970: 0)
        
        func save(filePath: String) {
            let settings = [
                "lastSyncDate": lastSyncDate,
                "queries": queries,
                "queriesModificationDate": queriesModificationDate
            ]
            (settings as NSDictionary).writeToFile(filePath, atomically: true)
        }
        
        func load(filePath: String) {
            if let settings = NSDictionary(contentsOfFile: filePath) {
                if let lastSyncDate = settings["lastSyncDate"] as? NSDate {
                    self.lastSyncDate = lastSyncDate
                }
                if let queries = settings["queries"] as? [String] {
                    self.queries = queries
                }
                if let queriesModificationDate = settings["queriesModificationDate"] as? NSDate {
                    self.queriesModificationDate = queriesModificationDate
                }
            }
        }
    }
    
    /// Add a data selection query to the local mirror.
    /// The query is not run immediately. It will be run during the subsequent refreshes.
    /// @pre The index must have been marked as mirrored.
    public func addDataSelectionQuery(query: Query) {
        assert(mirrored);
        _addQuery(query)
        mirrorSettings.queriesModificationDate = NSDate()
        mirrorSettings.save(self.mirrorSettingsFilePath)
    }

    /// Add any number of data selection queries to the local mirror.
    /// The query is not run immediately. It will be run during the subsequent refreshes.
    /// @pre The index must have been marked as mirrored.
    public func addDataSelectionQueries(queries: [Query]) {
        assert(mirrored);
        for query in queries {
            _addQuery(query)
        }
        mirrorSettings.queriesModificationDate = NSDate()
        mirrorSettings.save(self.mirrorSettingsFilePath)
    }
    
    private func _addQuery(originalQuery: Query) {
        // Make sure we don't retrieve unnecessary information.
        let query = Query(copy: originalQuery)
        query.attributesToHighlight = []
        query.attributesToSnippet = []
        query.getRankingInfo = false
        mirrorSettings.queries.append(query.buildURL())
    }

    public func sync() {
        assert(NSThread.isMainThread(), "Should only be called from the main thread")
        if syncing {
            return
        }
        syncing = true
        dispatch_async(dispatch_get_global_queue(QOS_CLASS_BACKGROUND, 0)) {
            self._sync()
        }
    }
    
    public func syncIfNeeded() {
        assert(NSThread.isMainThread(), "Should only be called from the main thread")
        let currentDate = NSDate()
        if currentDate.timeIntervalSinceDate(mirrorSettings.lastSyncDate) > self.delayBetweenSyncs
            || mirrorSettings.queriesModificationDate.compare(mirrorSettings.lastSyncDate) == .OrderedDescending {
            sync()
        }
    }
    
    /// Refresh the local mirror.
    private func _sync() {
        assert(!NSThread.isMainThread()) // make sure it's run in the background
        assert(self.mirrored, "Mirroring not activated on this index")
        assert(client.rootDataDir != nil, "Please enable offline mode in client first")
    
        // Create temporary directory.
        do {
            self.tmpDir = NSTemporaryDirectory() + "/algolia/" + NSUUID().UUIDString
            try NSFileManager.defaultManager().createDirectoryAtPath(self.tmpDir!, withIntermediateDirectories: true, attributes: nil)
        } catch _ {
            NSLog("ERROR: Could not create temporary directory '%@'", self.tmpDir!)
        }
        
        // NOTE: We use `NSOperation`s to handle dependencies between tasks.
        syncError = false
        
        // Task: Download index settings.
        // TODO: Set a different timeout.
        // TODO: Should we use host retry like for realtime queries? Not sure it's necessary.
        // TODO: Factorize query construction with regular code.
        let path = "1/indexes/\(urlEncodedIndexName)/settings"
        let urlString = "https://\(client.readQueryHostnames.first!)/\(path)"
        let url = NSURL(string: urlString)
        let request = NSURLRequest(URL: url!)
        let settingsOperation = URLSessionOperation(session: client.manager.session, request: request) {
            (data: NSData?, response: NSURLResponse?, error: NSError?) in
            if (data != nil) {
                self.settingsFilePath = "\(self.tmpDir!)/settings.json"
                data!.writeToFile(self.settingsFilePath!, atomically: false)
            } else {
                self.syncError = true
            }
        }
        client.buildQueue.addOperation(settingsOperation)

        // Tasks: Perform data selection queries.
        var queryNo = 0
        self.objectsFilePaths = []
        var objectOperations: [NSOperation] = []
        for query in mirrorSettings.queries {
            let thisQueryNo = ++queryNo
            let path = "1/indexes/\(urlEncodedIndexName)/query"
            let urlString = "https://\(client.readQueryHostnames.first!)/\(path)"
            let request = client.manager.encodeParameter(CreateNSURLRequest(.POST, URL: urlString), parameters: ["params": query])
            let operation = URLSessionOperation(session: client.manager.session, request: request) {
                (data: NSData?, response: NSURLResponse?, error: NSError?) in
                if (data != nil) {
                    let objectFilePath = "\(self.tmpDir!)/\(thisQueryNo).json"
                    self.objectsFilePaths?.append(objectFilePath)
                    data!.writeToFile(objectFilePath, atomically: false)
                } else {
                    self.syncError = true
                }
            }
            objectOperations.append(operation)
            client.buildQueue.addOperation(operation)
        }
        
        // Task: build the index using the downloaded files.
        let buildIndexOperation = NSBlockOperation() {
            if !self.syncError {
                let status = self.localIndex!.buildFromSettingsFile(self.settingsFilePath!, objectFiles: self.objectsFilePaths!)
                if status != 200 {
                    NSLog("Error %d building index %@", status, self.indexName)
                } else {
                    // Remember the sync's date
                    self.mirrorSettings.lastSyncDate = NSDate()
                    self.mirrorSettings.save(self.mirrorSettingsFilePath)
                }
            }
            
            // Mark the sync as finished.
            dispatch_async(dispatch_get_main_queue()) {
                self.syncing = false
            }
        }
        // Make sure this task is run after all the download tasks.
        buildIndexOperation.addDependency(settingsOperation)
        for operation in objectOperations {
            buildIndexOperation.addDependency(operation)
        }
        client.buildQueue.addOperation(buildIndexOperation)
    }
    
    /// Search the local mirror.
    // TODO: Should be called from regular search
    public func searchMirror(query: Query, block: CompletionHandler) {
        let callingQueue = NSOperationQueue.currentQueue() ?? NSOperationQueue.mainQueue()
        client.searchQueue.addOperationWithBlock() {
            self._searchMirror(query) {
                (content, error) -> Void in
                callingQueue.addOperationWithBlock() {
                    block(content: content, error: error)
                }
            }
        }
    }
    
    private func _searchMirror(query: Query, block: CompletionHandler) {
        assert(!NSThread.isMainThread()) // make sure it's run in the background
        assert(self.mirrored, "Mirroring not activated on this index")

        var content: [String: AnyObject]?
        var error: NSError?

        let searchResults = localIndex!.search(query.buildURL())
        if searchResults.statusCode == 200 {
            assert(searchResults.data != nil)
            do {
                let json = try NSJSONSerialization.JSONObjectWithData(searchResults.data!, options: NSJSONReadingOptions(rawValue: 0))
                if json is [String: AnyObject] {
                    content = (json as! [String: AnyObject])
                } else {
                    error = NSError(domain: AlgoliaSearchErrorDomain, code: 500, userInfo: [NSLocalizedDescriptionKey: "Invalid JSON returned"])
                }
            } catch let _error as NSError {
                error = _error
            }
        } else {
            error = NSError(domain: AlgoliaSearchErrorDomain, code: Int(searchResults.statusCode), userInfo: nil)
        }
        assert(content != nil || error != nil)
        block(content: content, error: error)
    }

#endif // ALGOLIA_SDK

// ----------------------------------------------------------------------
// NOTICE: End of SDK-dependent code
// ----------------------------------------------------------------------

}
