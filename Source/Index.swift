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

/// A proxy to an Algolia index.
///
/// + Note: You cannot construct this class directly. Please use `Client.index(withName:)` to obtain an instance.
///
@objc public class Index : NSObject {
    // MARK: Properties
    
    /// This index's name.
    @objc public let name: String
    
    /// API client used by this index.
    @objc public let client: Client
    
    let urlEncodedName: String
    
    var searchCache: ExpiringCache?
    
    // MAR: - Initialization
    
    /// Create a new index proxy.
    @objc init(client: Client, name: String) {
        self.client = client
        self.name = name
        urlEncodedName = name.urlEncodedPathComponent()
    }

    override public var description: String {
        get {
            return "Index{\"\(name)\"}"
        }
    }
    
    // MARK: - Operations

    /// Add an object to this index.
    ///
    /// - parameter object: The object to add.
    /// - parameter completionHandler: Completion handler to be notified of the request's outcome.
    /// - returns: A cancellable operation.
    ///
    @objc
    @discardableResult public func addObject(_ object: JSONObject, completionHandler: CompletionHandler? = nil) -> Operation {
        let path = "1/indexes/\(urlEncodedName)"
        return client.performHTTPQuery(path: path, method: .POST, body: object, hostnames: client.writeHosts, completionHandler: completionHandler)
    }
    
    /// Add an object to this index, assigning it the specified object ID.
    /// If an object already exists with the same object ID, the existing object will be overwritten.
    ///
    /// - parameter object: The object to add.
    /// - parameter objectID: Identifier that you want to assign this object.
    /// - parameter completionHandler: Completion handler to be notified of the request's outcome.
    /// - returns: A cancellable operation.
    ///
    @objc
    @discardableResult public func addObject(_ object: JSONObject, withID objectID: String, completionHandler: CompletionHandler? = nil) -> Operation {
        let path = "1/indexes/\(urlEncodedName)/\(objectID.urlEncodedPathComponent())"
        return client.performHTTPQuery(path: path, method: .PUT, body: object, hostnames: client.writeHosts, completionHandler: completionHandler)
    }
    
    /// Add several objects to this index.
    ///
    /// - parameter objects: Objects to add.
    /// - parameter completionHandler: Completion handler to be notified of the request's outcome.
    /// - returns: A cancellable operation.
    ///
    @objc
    @discardableResult public func addObjects(_ objects: [JSONObject], completionHandler: CompletionHandler? = nil) -> Operation {
        let path = "1/indexes/\(urlEncodedName)/batch"
        
        var requests = [Any]()
        requests.reserveCapacity(objects.count)
        for object in objects {
            requests.append(["action": "addObject", "body": object])
        }
        let request = ["requests": requests]
        
        return client.performHTTPQuery(path: path, method: .POST, body: request, hostnames: client.writeHosts, completionHandler: completionHandler)
    }
    
    /// Delete an object from this index.
    ///
    /// - parameter objectID: Identifier of object to delete.
    /// - parameter completionHandler: Completion handler to be notified of the request's outcome.
    /// - returns: A cancellable operation.
    ///
    @objc
    @discardableResult public func deleteObject(withID objectID: String, completionHandler: CompletionHandler? = nil) -> Operation {
        let path = "1/indexes/\(urlEncodedName)/\(objectID.urlEncodedPathComponent())"
        return client.performHTTPQuery(path: path, method: .DELETE, body: nil, hostnames: client.writeHosts, completionHandler: completionHandler)
    }
    
    /// Delete several objects from this index.
    ///
    /// - parameter objectIDs: Identifiers of objects to delete.
    /// - parameter completionHandler: Completion handler to be notified of the request's outcome.
    /// - returns: A cancellable operation.
    ///
    @objc
    @discardableResult public func deleteObjects(withIDs objectIDs: [String], completionHandler: CompletionHandler? = nil) -> Operation {
        let path = "1/indexes/\(urlEncodedName)/batch"
        
        var requests = [Any]()
        requests.reserveCapacity(objectIDs.count)
        for id in objectIDs {
            requests.append(["action": "deleteObject", "objectID": id])
        }
        let request = ["requests": requests]
        
        return client.performHTTPQuery(path: path, method: .POST, body: request, hostnames: client.writeHosts, completionHandler: completionHandler)
    }
    
    /// Get an object from this index.
    ///
    /// - parameter objectID: Identifier of the object to retrieve.
    /// - parameter completionHandler: Completion handler to be notified of the request's outcome.
    /// - returns: A cancellable operation.
    ///
    @objc
    @discardableResult public func getObject(withID objectID: String, completionHandler: @escaping CompletionHandler) -> Operation {
        let path = "1/indexes/\(urlEncodedName)/\(objectID.urlEncodedPathComponent())"
        return client.performHTTPQuery(path: path, method: .GET, body: nil, hostnames: client.readHosts, completionHandler: completionHandler)
    }
    
    /// Get an object from this index, optionally restricting the retrieved content.
    ///
    /// - parameter objectID: Identifier of the object to retrieve.
    /// - parameter attributesToRetrieve: List of attributes to retrieve.
    /// - parameter completionHandler: Completion handler to be notified of the request's outcome.
    /// - returns: A cancellable operation.
    ///
    @objc
    @discardableResult public func getObject(withID objectID: String, attributesToRetrieve: [String], completionHandler: @escaping CompletionHandler) -> Operation {
        let query = Query()
        query.attributesToRetrieve = attributesToRetrieve
        let path = "1/indexes/\(urlEncodedName)/\(objectID.urlEncodedPathComponent())?\(query.build())"
        return client.performHTTPQuery(path: path, method: .GET, body: nil, hostnames: client.readHosts, completionHandler: completionHandler)
    }
    
    /// Get several objects from this index.
    ///
    /// - parameter objectIDs: Identifiers of objects to retrieve.
    /// - parameter completionHandler: Completion handler to be notified of the request's outcome.
    /// - returns: A cancellable operation.
    ///
    @objc
    @discardableResult public func getObjects(withIDs objectIDs: [String], completionHandler: @escaping CompletionHandler) -> Operation {
        let path = "1/indexes/*/objects"
        
        var requests = [Any]()
        requests.reserveCapacity(objectIDs.count)
        for id in objectIDs {
            requests.append(["indexName": self.name, "objectID": id])
        }
        let request = ["requests": requests]
        
        return client.performHTTPQuery(path: path, method: .POST, body: request, hostnames: client.readHosts, completionHandler: completionHandler)
    }

    /// Get several objects from this index, optionally restricting the retrieved content.
    ///
    /// - parameter objectIDs: Identifiers of objects to retrieve.
    /// - parameter attributesToRetrieve: List of attributes to retrieve. If `nil`, all attributes are retrieved.
    ///                                   If one of the elements is `"*"`, all attributes are retrieved.
    /// - parameter completionHandler: Completion handler to be notified of the request's outcome.
    /// - returns: A cancellable operation.
    ///
    @objc
    @discardableResult public func getObjects(withIDs objectIDs: [String], attributesToRetrieve: [String], completionHandler: @escaping CompletionHandler) -> Operation {
        let path = "1/indexes/*/objects"
        var requests = [Any]()
        requests.reserveCapacity(objectIDs.count)
        for id in objectIDs {
            let request = [
                "indexName": self.name,
                "objectID": id,
                "attributesToRetrieve": attributesToRetrieve.joined(separator: ",")
            ]
            requests.append(request as Any)
        }
        return client.performHTTPQuery(path: path, method: .POST, body: ["requests": requests], hostnames: client.readHosts, completionHandler: completionHandler)
    }
    
    /// Partially update an object.
    ///
    /// - parameter partialObject: New values/operations for the object.
    /// - parameter objectID: Identifier of object to be updated.
    /// - parameter completionHandler: Completion handler to be notified of the request's outcome.
    /// - returns: A cancellable operation.
    ///
    /// + Note: If the object does not exist, it will be created. You can avoid automatic creation of the object by
    ///   passing `false` to `createIfNotExists` in `partialUpdateObject(_:withID:createIfNotExists:completionHandler:)`.
    ///
    @objc
    @discardableResult public func partialUpdateObject(_ partialObject: JSONObject, withID objectID: String, completionHandler: CompletionHandler? = nil) -> Operation {
        let path = "1/indexes/\(urlEncodedName)/\(objectID.urlEncodedPathComponent())/partial"
        return client.performHTTPQuery(path: path, method: .POST, body: partialObject, hostnames: client.writeHosts, completionHandler: completionHandler)
    }
    
    /// Partially update an object.
    ///
    /// - parameter partialObject: New values/operations for the object.
    /// - parameter objectID: Identifier of object to be updated.
    /// - parameter createIfNotExists: Whether an update on a nonexistent object ID should create the object.
    /// - parameter completionHandler: Completion handler to be notified of the request's outcome.
    /// - returns: A cancellable operation.
    ///
    @objc
    @discardableResult public func partialUpdateObject(_ partialObject: JSONObject, withID objectID: String, createIfNotExists: Bool, completionHandler: CompletionHandler? = nil) -> Operation {
        let path = "1/indexes/\(urlEncodedName)/\(objectID.urlEncodedPathComponent())/partial?createIfNotExists=\(String(createIfNotExists).urlEncodedQueryParam())"
        return client.performHTTPQuery(path: path, method: .POST, body: partialObject, hostnames: client.writeHosts, completionHandler: completionHandler)
    }

    /// Partially update several objects.
    ///
    /// - parameter objects: New values/operations for the objects. Each object must contain an `objectID` attribute.
    /// - parameter completionHandler: Completion handler to be notified of the request's outcome.
    /// - returns: A cancellable operation.
    ///
    /// + Note: If an object does not exist, it will be created. You can avoid automatic creation of objects by
    ///   passing `false` to `createIfNotExists` in `partialUpdateObjects(_:createIfNotExists:completionHandler:)`.
    ///
    @objc
    @discardableResult public func partialUpdateObjects(_ objects: [JSONObject], completionHandler: CompletionHandler? = nil) -> Operation {
        let path = "1/indexes/\(urlEncodedName)/batch"
        
        var requests = [Any]()
        requests.reserveCapacity(objects.count)
        for object in objects {
            requests.append([
                "action": "partialUpdateObject",
                "objectID": object["objectID"] as! String,
                "body": object
            ])
        }
        let request = ["requests": requests]
        
        return client.performHTTPQuery(path: path, method: .POST, body: request, hostnames: client.writeHosts, completionHandler: completionHandler)
    }

    /// Partially update several objects.
    ///
    /// - parameter objects: New values/operations for the objects. Each object must contain an `objectID` attribute.
    /// - parameter createIfNotExists: Whether an update on a nonexistent object ID should create the object.
    /// - parameter completionHandler: Completion handler to be notified of the request's outcome.
    /// - returns: A cancellable operation.
    ///
    @objc
    @discardableResult public func partialUpdateObjects(_ objects: [JSONObject], createIfNotExists: Bool, completionHandler: CompletionHandler? = nil) -> Operation {
        let path = "1/indexes/\(urlEncodedName)/batch"
        let action = createIfNotExists ? "partialUpdateObject" : "partialUpdateObjectNoCreate"
        var requests = [Any]()
        requests.reserveCapacity(objects.count)
        for object in objects {
            requests.append([
                "action": action,
                "objectID": object["objectID"] as! String,
                "body": object
                ])
        }
        let request = ["requests": requests]
        
        return client.performHTTPQuery(path: path, method: .POST, body: request, hostnames: client.writeHosts, completionHandler: completionHandler)
    }

    /// Update an object.
    ///
    /// - parameter object: New version of the object to update. Must contain an `objectID` attribute.
    /// - parameter completionHandler: Completion handler to be notified of the request's outcome.
    /// - returns: A cancellable operation.
    ///
    @objc
    @discardableResult public func saveObject(_ object: JSONObject, completionHandler: CompletionHandler? = nil) -> Operation {
        let objectID = object["objectID"] as! String
        let path = "1/indexes/\(urlEncodedName)/\(objectID.urlEncodedPathComponent())"
        return client.performHTTPQuery(path: path, method: .PUT, body: object, hostnames: client.writeHosts, completionHandler: completionHandler)
    }
    
    /// Update several objects.
    ///
    /// - parameter objects: New versions of the objects to update. Each one must contain an `objectID` attribute.
    /// - parameter completionHandler: Completion handler to be notified of the request's outcome.
    /// - returns: A cancellable operation.
    ///
    @objc
    @discardableResult public func saveObjects(_ objects: [JSONObject], completionHandler: CompletionHandler? = nil) -> Operation {
        let path = "1/indexes/\(urlEncodedName)/batch"
        
        var requests = [Any]()
        requests.reserveCapacity(objects.count)
        for object in objects {
            requests.append([
                "action": "updateObject",
                "objectID": object["objectID"] as! String,
                "body": object
            ])
        }
        let request = ["requests": requests]
        
        return client.performHTTPQuery(path: path, method: .POST, body: request, hostnames: client.writeHosts, completionHandler: completionHandler)
    }
    
    /// Search this index.
    ///
    /// - parameter query: Search parameters.
    /// - parameter completionHandler: Completion handler to be notified of the request's outcome.
    /// - returns: A cancellable operation.
    ///
    @objc
    @discardableResult public func search(_ query: Query, completionHandler: @escaping CompletionHandler) -> Operation {
        let path = "1/indexes/\(urlEncodedName)/query"
        let request = ["params": query.build()]
        
        // First try the in-memory query cache.
        let cacheKey = "\(path)_body_\(request)"
        if let content = searchCache?.objectForKey(cacheKey) {
            // We *have* to return something, so we create a simple operation.
            // Note that its execution will be deferred until the next iteration of the main run loop.
            let operation = AsyncBlockOperation(completionHandler: completionHandler) {
                return (content, nil)
            }
            operation.completionQueue = client.completionQueue
            OperationQueue.main.addOperation(operation)
            return operation
        }
        // Otherwise, run an online query.
        else {
            return client.performHTTPQuery(path: path, method: .POST, body: request, hostnames: client.readHosts, isSearchQuery: true) {
                (content, error) -> Void in
                assert(content != nil || error != nil)
                
                // Update local cache in case of success.
                if content != nil {
                    self.searchCache?.setObject(content!, forKey: cacheKey)
                }
                completionHandler(content, error)
            }
        }
    }
    
    /// Search for facet values.
    /// This searches inside a facet's values, optionally restricting the returned values to those contained in objects
    /// matching other (regular) search criteria.
    ///
    /// - parameter facetName: Name of the facet to search. It must have been declared in the index's
    ///       `attributesForFaceting` setting with the `searchable()` modifier.
    /// - parameter text: Text to search for in the facet's values.
    /// - parameter query: An optional query to take extra search parameters into account. These parameters apply to
    ///       index objects like in a regular search query. Only facet values contained in the matched objects will be
    ///       returned.
    /// - parameter completionHandler: Completion handler to be notified of the request's outcome.
    /// - returns: A cancellable operation.
    ///
    @objc(searchForFacetValuesOf:matching:query:completionHandler:)
    @discardableResult public func searchForFacetValues(of facetName: String, matching text: String, query: Query? = nil, completionHandler: @escaping CompletionHandler) -> Operation {
        let path = "1/indexes/\(urlEncodedName)/facets/\(facetName.urlEncodedPathComponent())/query"
        let params = query != nil ? Query(copy: query!) : Query()
        params["facetQuery"] = text
        let requestBody = [
            "params": params.build()
        ]
        return client.performHTTPQuery(path: path, method: .POST, body: requestBody, hostnames: client.readHosts, isSearchQuery: true, completionHandler: completionHandler)
    }
    
    /// Get this index's settings.
    ///
    /// - parameter completionHandler: Completion handler to be notified of the request's outcome.
    /// - returns: A cancellable operation.
    ///
    @objc(getSettings:)
    @discardableResult public func getSettings(completionHandler: @escaping CompletionHandler) -> Operation {
        let path = "1/indexes/\(urlEncodedName)/settings?getVersion=2"
        return client.performHTTPQuery(path: path, method: .GET, body: nil, hostnames: client.readHosts, completionHandler: completionHandler)
    }
    
    /// Set this index's settings.
    ///
    /// Please refer to our [API documentation](https://www.algolia.com/doc/swift#index-settings) for the list of
    /// supported settings.
    ///
    /// - parameter settings: New settings.
    /// - parameter completionHandler: Completion handler to be notified of the request's outcome.
    /// - returns: A cancellable operation.
    ///
    @objc
    @discardableResult public func setSettings(_ settings: JSONObject, completionHandler: CompletionHandler? = nil) -> Operation {
        let path = "1/indexes/\(urlEncodedName)/settings"
        return client.performHTTPQuery(path: path, method: .PUT, body: settings, hostnames: client.writeHosts, completionHandler: completionHandler)
    }

    /// Set this index's settings, optionally forwarding the change to replicas.
    ///
    /// Please refer to our [API documentation](https://www.algolia.com/doc/swift#index-settings) for the list of
    /// supported settings.
    ///
    /// - parameter settings: New settings.
    /// - parameter forwardToReplicas: When true, the change is also applied to replicas of this index.
    /// - parameter completionHandler: Completion handler to be notified of the request's outcome.
    /// - returns: A cancellable operation.
    ///
    @objc
    @discardableResult public func setSettings(_ settings: JSONObject, forwardToReplicas: Bool, completionHandler: CompletionHandler? = nil) -> Operation {
        let path = "1/indexes/\(urlEncodedName)/settings?forwardToReplicas=\(forwardToReplicas)"
        return client.performHTTPQuery(path: path, method: .PUT, body: settings, hostnames: client.writeHosts, completionHandler: completionHandler)
    }

    /// Delete the index content without removing settings and index specific API keys.
    ///
    /// - parameter completionHandler: Completion handler to be notified of the request's outcome.
    /// - returns: A cancellable operation.
    ///
    @objc(clearIndex:)
    @discardableResult public func clearIndex(completionHandler: CompletionHandler? = nil) -> Operation {
        let path = "1/indexes/\(urlEncodedName)/clear"
        return client.performHTTPQuery(path: path, method: .POST, body: nil, hostnames: client.writeHosts, completionHandler: completionHandler)
    }
    
    /// Batch operations.
    ///
    /// - parameter operations: The array of actions.
    /// - parameter completionHandler: Completion handler to be notified of the request's outcome.
    /// - returns: A cancellable operation.
    ///
    @objc(batchOperations:completionHandler:)
    @discardableResult public func batch(operations: [JSONObject], completionHandler: CompletionHandler? = nil) -> Operation {
        let path = "1/indexes/\(urlEncodedName)/batch"
        let body = ["requests": operations]
        return client.performHTTPQuery(path: path, method: .POST, body: body, hostnames: client.writeHosts, completionHandler: completionHandler)
    }
    
    /// Browse all index content (initial call).
    /// This method should be called once to initiate a browse. It will return the first page of results and a cursor,
    /// unless the end of the index has been reached. To retrieve subsequent pages, call `browseFrom` with that cursor.
    ///
    /// - parameter query: The query parameters for the browse.
    /// - parameter completionHandler: Completion handler to be notified of the request's outcome.
    /// - returns: A cancellable operation.
    ///
    @objc(browseWithQuery:completionHandler:)
    @discardableResult public func browse(query: Query, completionHandler: @escaping CompletionHandler) -> Operation {
        let path = "1/indexes/\(urlEncodedName)/browse"
        let body = [
            "params": query.build()
        ]
        return client.performHTTPQuery(path: path, method: .POST, body: body, hostnames: client.readHosts, completionHandler: completionHandler)
    }
    
    /// Browse the index from a cursor.
    /// This method should be called after an initial call to `browse()`. It returns a cursor, unless the end of the
    /// index has been reached.
    ///
    /// - parameter cursor: The cursor of the next page to retrieve
    /// - parameter completionHandler: Completion handler to be notified of the request's outcome.
    /// - returns: A cancellable operation.
    ///
    @objc(browseFromCursor:completionHandler:)
    @discardableResult public func browse(from cursor: String, completionHandler: @escaping CompletionHandler) -> Operation {
        let path = "1/indexes/\(urlEncodedName)/browse?cursor=\(cursor.urlEncodedQueryParam())"
        return client.performHTTPQuery(path: path, method: .GET, body: nil, hostnames: client.readHosts, completionHandler: completionHandler)
    }
    
    // MARK: - Helpers
    
    /// Wait until the publication of a task on the server (helper).
    /// All server tasks are asynchronous. This method helps you check that a task is published.
    ///
    /// - parameter taskID: Identifier of the task (as returned by the server).
    /// - parameter completionHandler: Completion handler to be notified of the request's outcome.
    /// - returns: A cancellable operation.
    ///
    @objc
    @discardableResult public func waitTask(withID taskID: Int, completionHandler: @escaping CompletionHandler) -> Operation {
        let operation = WaitOperation(index: self, taskID: taskID, completionHandler: completionHandler)
        operation.start()
        return operation
    }
    
    private class WaitOperation: AsyncOperationWithCompletion {
        let index: Index
        let taskID: Int
        let path: String
        var iteration: Int = 0
        var operation: Operation?
        
        static let BASE_DELAY = 0.1     ///< Minimum wait delay.
        static let MAX_DELAY  = 5.0     ///< Maximum wait delay.
        
        init(index: Index, taskID: Int, completionHandler: @escaping CompletionHandler) {
            self.index = index
            self.taskID = taskID
            path = "1/indexes/\(index.urlEncodedName)/task/\(taskID)"
            super.init(completionHandler: completionHandler)
            self.completionQueue = index.client.completionQueue
        }
        
        override func start() {
            super.start()
            startNext()
        }
        
        override func cancel() {
            operation?.cancel()
            super.cancel()
        }
        
        private func startNext() {
            if isCancelled {
                return
            }
            iteration += 1
            operation = index.client.performHTTPQuery(path: path, method: .GET, body: nil, hostnames: index.client.writeHosts) {
                (content, error) -> Void in
                if let content = content {
                    if (content["status"] as? String) == "published" {
                        self.callCompletion(content: content, error: nil)
                        self.finish()
                    } else {
                        // The delay between polls increases quadratically from the base delay up to the max delay.
                        let delay = min(WaitOperation.BASE_DELAY * Double(self.iteration * self.iteration), WaitOperation.MAX_DELAY)
                        Thread.sleep(forTimeInterval: delay)
                        self.startNext()
                    }
                } else {
                    self.callCompletion(content: content, error: error)
                    self.finish()
                }
            }
        }
    }

    /// Delete all objects matching a query (helper).
    ///
    /// - parameter query: The query that objects to delete must match.
    /// - parameter completionHandler: Completion handler to be notified of the request's outcome.
    /// - returns: A cancellable operation.
    ///
    @objc
    @discardableResult public func deleteByQuery(_ query: Query, completionHandler: CompletionHandler? = nil) -> Operation {
        let operation = DeleteByQueryOperation(index: self, query: query, completionHandler: completionHandler)
        operation.start()
        return operation
    }
    
    private class DeleteByQueryOperation: AsyncOperationWithCompletion {
        let index: Index
        let query: Query
        
        init(index: Index, query: Query, completionHandler: CompletionHandler?) {
            self.index = index
            self.query = Query(copy: query)
            super.init(completionHandler: completionHandler)
            self.completionQueue = index.client.completionQueue
        }
        
        override func start() {
            super.start()
            // Save bandwidth by retrieving only the `objectID` attribute.
            query.attributesToRetrieve = ["objectID"]
            index.browse(query: query, completionHandler: self.handleResult)
        }
        
        private func handleResult(_ content: JSONObject?, error: Error?) {
            if self.isCancelled {
                return
            }
            var finalError: Error? = error
            if finalError == nil {
                let hasMoreContent = content!["cursor"] != nil
                if let hits = content!["hits"] as? [Any] {
                    // Fetch IDs of objects to delete.
                    var objectIDs: [String] = []
                    for hit in hits {
                        if let objectID = (hit as? JSONObject)?["objectID"] as? String {
                            objectIDs.append(objectID)
                        }
                    }
                    // Delete the objects.
                    self.index.deleteObjects(withIDs: objectIDs, completionHandler: { (content, error) in
                        if self.isCancelled {
                            return
                        }
                        var finalError: Error? = error
                        if finalError == nil {
                            if let taskID = content?["taskID"] as? Int {
                                // Wait for the deletion to be effective.
                                self.index.waitTask(withID: taskID, completionHandler: { (content, error) in
                                    if self.isCancelled {
                                        return
                                    }
                                    if error != nil || !hasMoreContent {
                                        self.callCompletion(content: content, error: error)
                                    } else {
                                        // Browse again *from the beginning*, since the deletion invalidated the cursor.
                                        self.index.browse(query: self.query, completionHandler: self.handleResult)
                                    }
                                })
                            } else {
                                finalError = InvalidJSONError(description: "No task ID returned when deleting")
                            }
                        }
                        if finalError != nil {
                            self.callCompletion(content: nil, error: finalError)
                        }
                    })
                } else {
                    finalError = InvalidJSONError(description: "No hits returned when browsing")
                }
            }
            if finalError != nil {
                self.callCompletion(content: nil, error: finalError)
            }
        }
    }
    
    /// Perform a search with disjunctive facets, generating as many queries as number of disjunctive facets (helper).
    ///
    /// - parameter query: The query.
    /// - parameter disjunctiveFacets: List of disjunctive facets.
    /// - parameter refinements: The current refinements, mapping facet names to a list of values.
    /// - parameter completionHandler: Completion handler to be notified of the request's outcome.
    /// - returns: A cancellable operation.
    ///
    @objc
    @discardableResult public func searchDisjunctiveFaceting(_ query: Query, disjunctiveFacets: [String], refinements: [String: [String]], completionHandler: @escaping CompletionHandler) -> Operation {
        return DisjunctiveFaceting(multipleQuerier: { (queries, completionHandler) in
            return self.multipleQueries(queries, completionHandler: completionHandler)
        }).searchDisjunctiveFaceting(query, disjunctiveFacets: disjunctiveFacets, refinements: refinements, completionHandler: completionHandler)
    }
    
    /// Run multiple queries on this index.
    /// This method is a variant of `Client.multipleQueries(...)` where the targeted index is always the receiver.
    ///
    /// - parameter queries: The queries to run.
    /// - parameter completionHandler: Completion handler to be notified of the request's outcome.
    /// - returns: A cancellable operation.
    ///
    @objc
    @discardableResult public func multipleQueries(_ queries: [Query], strategy: String?, completionHandler: @escaping CompletionHandler) -> Operation {
        var requests = [IndexQuery]()
        for query in queries {
            requests.append(IndexQuery(index: self, query: query))
        }
        return client.multipleQueries(requests, strategy: strategy, completionHandler: completionHandler)
    }
    
    /// Run multiple queries on this index.
    /// This method is a variant of `Client.multipleQueries(...)` where the targeted index is always the receiver.
    ///
    /// - parameter queries: The queries to run.
    /// - parameter strategy: The strategy to use.
    /// - parameter completionHandler: Completion handler to be notified of the request's outcome.
    /// - returns: A cancellable operation.
    ///
    @discardableResult public func multipleQueries(_ queries: [Query], strategy: Client.MultipleQueriesStrategy? = nil, completionHandler: @escaping CompletionHandler) -> Operation {
        return self.multipleQueries(queries, strategy: strategy?.rawValue, completionHandler: completionHandler)
    }

    // MARK: - Search Cache
    
    /// Whether the search cache is enabled on this index. Default: `false`.
    ///
    @objc public var searchCacheEnabled: Bool = false {
        didSet(wasEnabled) {
            if !wasEnabled && searchCacheEnabled {
                enableSearchCache()
            } else if wasEnabled && !searchCacheEnabled {
                disableSearchCache()
            }
        }
    }
    
    /// Expiration delay for items in the search cache. Default: 2 minutes.
    ///
    /// + Note: The delay is a minimum threshold. Items may survive longer in cache.
    ///
    @objc public var searchCacheExpiringTimeInterval: TimeInterval = 120 {
        didSet {
            searchCache?.expiringTimeInterval = searchCacheExpiringTimeInterval
        }
    }
    
    /// Enable the search cache.
    ///
    private func enableSearchCache() {
        searchCache = ExpiringCache(expiringTimeInterval: searchCacheExpiringTimeInterval)
    }
    
    /// Disable the search cache.
    ///
    private func disableSearchCache() {
        searchCache?.clearCache()
        searchCache = nil
    }
    
    /// Clear the search cache.
    ///
    @objc public func clearSearchCache() {
        searchCache?.clearCache()
    }
}
