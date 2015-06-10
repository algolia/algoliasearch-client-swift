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

/// Contains all the functions related to one index
///
/// You can use Client.getIndex(indexName) to retrieve this object
public class Index {
    public let indexName: String
    public let client: Client
    private let urlEncodedIndexName: String
    
    init(client: Client, indexName: String) {
        self.client = client
        self.indexName = indexName
        urlEncodedIndexName = indexName.urlEncode()
    }
    
    /// Add an object in this index
    ///
    /// :param: object The object to add inside the index.
    public func addObject(object: [String: AnyObject], block: CompletionHandler? = nil) {
        let path = "1/indexes/\(urlEncodedIndexName)"
        client.performHTTPQuery(path, method: .POST, body: object, hostnames: client.writeQueryHostnames, block: block)
    }
    
    /// Add an object in this index
    ///
    /// :param: object The object to add inside the index.
    /// :param: withID An objectID you want to attribute to this object (if the attribute already exist, the old object will be overwrite)
    public func addObject(object: [String: AnyObject], withID objectID: String, block: CompletionHandler? = nil) {
        let path = "1/indexes/\(urlEncodedIndexName)/\(objectID.urlEncode())"
        client.performHTTPQuery(path, method: .PUT, body: object, hostnames: client.writeQueryHostnames, block: block)
    }
    
    /// Add several objects in this index
    ///
    /// :param: objects An array of objects to add (Array of Dictionnary object).
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
    /// :param: objectID The unique identifier of object to delete
    public func deleteObject(objectID: String, block: CompletionHandler? = nil) {
        let path = "1/indexes/\(urlEncodedIndexName)/\(objectID.urlEncode())"
        client.performHTTPQuery(path, method: .DELETE, body: nil, hostnames: client.writeQueryHostnames, block: block)
    }
    
    /// Delete several objects
    ///
    /// :param: objectIDs An array of objectID to delete.
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
    /// :param: objectID The unique identifier of the object to retrieve
    public func getObject(objectID: String, block: CompletionHandler) {
        let path = "1/indexes/\(urlEncodedIndexName)/\(objectID.urlEncode())"
        client.performHTTPQuery(path, method: .GET, body: nil, hostnames: client.readQueryHostnames, block: block)
    }
    
    /// Get an object from this index
    ///
    /// :param: objectID The unique identifier of the object to retrieve
    /// :param: attributesToRetrieve The list of attributes to retrieve
    public func getObject(objectID: String, attributesToRetrieve attributes: [String], block: CompletionHandler) {
        let urlEncodedAttributes = Query.encodeForQuery(attributes, withKey: "attributes")
        let path = "1/indexes/\(urlEncodedIndexName)/\(objectID.urlEncode())?\(urlEncodedAttributes)"
        client.performHTTPQuery(path, method: .GET, body: nil, hostnames: client.readQueryHostnames, block: block)
    }
    
    /// Get several objects from this index
    ///
    /// :param: objectIDs The array of unique identifier of objects to retrieve
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
    /// :param: object The object attributes to override, the object must contains an objectID attribute
    public func partialUpdateObject(partialObject: [String: AnyObject], objectID: String, block: CompletionHandler? = nil) {
        let path = "1/indexes/\(urlEncodedIndexName)/\(objectID.urlEncode())/partial"
        client.performHTTPQuery(path, method: .POST, body: partialObject, hostnames: client.writeQueryHostnames, block: block)
    }
    
    /// Update partially the content of several objects
    ///
    /// :param: objects An array of Dictionary to update (each Dictionary must contains an objectID attribute)
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
    /// :param: object The object to override, the object must contains an objectID attribute
    public func saveObject(object: [String: AnyObject], block: CompletionHandler? = nil) {
        if let objectID = object["objectID"] as? String {
            let path = "1/indexes/\(urlEncodedIndexName)/\(objectID.urlEncode())"
            client.performHTTPQuery(path, method: .PUT, body: object, hostnames: client.writeQueryHostnames, block: block)
        }
    }
    
    /// Override the content of several objects
    ///
    /// :param: objects An array of Dictionary to save (each Dictionary must contains an objectID attribute)
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
        client.performHTTPQuery(path, method: .POST, body: request, hostnames: client.readQueryHostnames, isSearchQuery: true, block: block)
    }
    
    /// Delete all previous search queries
    public func cancelPreviousSearch() {
        client.cancelQueries(.POST, path: "1/indexes/\(urlEncodedIndexName)/query")
    }
    
    /// Wait the publication of a task on the server.
    /// All server task are asynchronous and you can check with this method that the task is published.
    ///
    /// :param: taskID The ID of the task returned by server
    public func waitTask(taskID: Int, block: CompletionHandler) {
        let path = "1/indexes/\(urlEncodedIndexName)/task/\(taskID)"
        client.performHTTPQuery(path, method: .GET, body: nil, hostnames: client.readQueryHostnames, block: { (JSON, error) -> Void in
            if let JSON = JSON {
                if (JSON["status"] as? String) == "published" {
                    block(JSON: JSON, error: nil)
                } else {
                    NSThread.sleepForTimeInterval(0.1)
                    self.waitTask(taskID, block: block)
                }
            } else {
                block(JSON: JSON, error: error)
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
    /// :param: settings The settings object
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
    /// :param: acls The list of ACL for this key. The list can contains the following values (as String): search, addObject, deleteObject, deleteIndex, settings, editSettings
    public func addUserKey(acls: [String], block: CompletionHandler? = nil) {
        let path = "1/indexes/\(urlEncodedIndexName)/keys"
        let request = ["acl": acls]
        client.performHTTPQuery(path, method: .POST, body: request, hostnames: client.writeQueryHostnames, block: block)
    }
    
    /// Create a new user key associated to this index
    ///
    /// :param: acls The list of ACL for this key. The list can contains the following values (as String): search, addObject, deleteObject, deleteIndex, settings, editSettings
    /// :param: withValidity The number of seconds after which the key will be automatically removed (0 means no time limit for this key)
    /// :param: maxQueriesPerIPPerHour Specify the maximum number of API calls allowed from an IP address per hour.  Defaults to 0 (unlimited).
    /// :param: maxHitsPerQuery Specify the maximum number of hits this API key can retrieve in one call. Defaults to 0 (unlimited)
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
    /// :param: withACL The list of ACL for this key. The list can contains the following values (as String): search, addObject, deleteObject, deleteIndex, settings, editSettings
    public func updateUserKey(key: String, withACL acls: [String], block: CompletionHandler? = nil) {
        let path = "1/indexes/\(urlEncodedIndexName)/keys/\(key.urlEncode())"
        let request = ["acl": acls]
        client.performHTTPQuery(path, method: .PUT, body: request, hostnames: client.writeQueryHostnames, block: block)
    }
    
    /// Update a user key associated to this index
    ///
    /// :param: withACL The list of ACL for this key. The list can contains the following values (as String): search, addObject, deleteObject, deleteIndex, settings, editSettings
    /// :param: andValidity The number of seconds after which the key will be automatically removed (0 means no time limit for this key)
    /// :param: maxQueriesPerIPPerHour Specify the maximum number of API calls allowed from an IP address per hour.  Defaults to 0 (unlimited).
    /// :param: maxHitsPerQuery Specify the maximum number of hits this API key can retrieve in one call. Defaults to 0 (unlimited)
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
    /// :param: page Pagination parameter used to select the page to retrieve. Page is zero-based and defaults to 0. Thus, to retrieve the 10th page you need to set page=9
    /// :param: hitsPerPage Pagination parameter used to select the number of hits per page. Defaults to 1000.
    public func browse(page: UInt = 0, hitsPerPage: UInt = 1000, block: CompletionHandler) {
        let path = "1/indexes/\(urlEncodedIndexName)/browse?page=\(page)&hitsPerPage=\(hitsPerPage)"
        client.performHTTPQuery(path, method: .GET, body: nil, hostnames: client.readQueryHostnames, block: block)
    }
    
    public typealias BrowseIteratorHandler = (iterator: BrowseIterator, end: Bool, error: NSError?) -> Void
    
    public class BrowseIterator {
        public let index: Index
        public let query: Query
        
        private let path: String
        private let queryURL: String
        private let block: BrowseIteratorHandler
        private var cursor = ""
        private var end = false
        
        public var result: [String: AnyObject]?
        
        init(index: Index, query: Query, block: BrowseIteratorHandler) {
            self.index = index
            self.query = query
            self.block = block
            
            queryURL = query.buildURL()
            path = "1/indexes/\(index.urlEncodedIndexName)/browse?\(queryURL)"
        }
        
        public func next() {
            var requestPath = path
            if cursor != "" {
                if queryURL != "" {
                    requestPath += "&"
                }
                
                requestPath += "cursor=\(cursor.urlEncode())"
            }
            
            index.client.performHTTPQuery(requestPath, method: .GET, body: nil, hostnames: index.client.readQueryHostnames) { (JSON, error) -> Void in
                if let error = error {
                    self.block(iterator: self, end: false, error: error)
                } else {
                    self.result = JSON
                    if let cursor = JSON!["cursor"] as? String {
                        self.cursor = cursor
                    } else {
                        self.end = true
                    }
                    
                    self.block(iterator: self, end: self.end, error: nil)
                }
            }
        }
    }
    
    public func browse(query: Query, block: BrowseIteratorHandler) {
        let iterator = BrowseIterator(index: self, query: query, block: block)
        iterator.next() // first call
    }
}
