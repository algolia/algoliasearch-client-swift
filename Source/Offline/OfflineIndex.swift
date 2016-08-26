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

import AlgoliaSearchOfflineCore
import Foundation


/// A purely offline index.
/// Such an index has no online counterpart. It is updated and queried locally.
///
/// + Note: You cannot construct this class directly. Please use `OfflineClient.getOfflineIndex(_:)` to obtain an
///   instance.
///
///
/// # Caveats
///
/// ## Limitations
///
/// Though offline indices support most features of an online index, there are some limitations:
///
/// - Objects **must contain an `objectID`** field. The SDK will refuse to index objects without an ID.
///   As a consequence, `addObject(...)` and `saveObject(...)` are synonyms.
///
/// - **Partial updates** are not supported.
///
/// - **Batch** operations are not supported.
///
/// ## Differences
///
/// - **Settings** are not incremental: the new settings completely replace the previous ones. If a setting
///   is omitted in the new version, it reverts back to its default value. (This is in contrast with the online API,
///   where you can only specify the settings you want to change and omit the others.)
///
///
/// # Operations
///
/// ## Asynchronicity
///
/// **Reminder:** Write operations on an online `Index` are twice asynchronous: the response from the server received
/// by the completion handler is merely an acknowledgement of the task. If you want to detect the end of the write
/// operation, you have to use `waitTask(_:completionHandler:)`.
///
/// In contrast, write operations on an `OfflineIndex` are only once asynchronous: when the completion handler is
/// called, the operation has completed (eitehr successfully or unsuccessfully).
///
/// Read operations behave identically as on online indices.
///
/// ### Cancellation
///
/// Just like online indices, an offline index bears *no rollback semantic*: cancelling an operation does **not**
/// prevent the data from being modified. It just prevents the completion handler from being called.
///
@objc public class OfflineIndex : NSObject {
    // TODO: Expose common behavior through a protocol.
    // TODO: Factorize common behavior in a base class.
    
    // MARK: Properties
    
    /// This index's name.
    @objc public let name: String
    
    /// API client used by this index.
    @objc public let client: OfflineClient

    /// The local index (lazy instantiated).
    lazy var localIndex: ASLocalIndex! = ASLocalIndex(dataDir: self.client.rootDataDir, appID: self.client.appID, indexName: self.name)

    // MARK: - Initialization
    
    /// Create a new offline index.
    ///
    /// - parameter client: The offline client used by this index.
    /// - parameter name: This index's name.
    ///
    @objc public init(client: OfflineClient, name: String) {
        self.client = client
        self.name = name
    }
    
    override public var description: String {
        get {
            // TODO: Move to a higher level.
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
    @objc public func addObject(object: [String: AnyObject], completionHandler: CompletionHandler? = nil) -> NSOperation {
        return saveObject(object, completionHandler: completionHandler)
    }
    
    /// Add an object to this index, assigning it the specified object ID.
    /// If an object already exists with the same object ID, the existing object will be overwritten.
    ///
    /// - parameter object: The object to add.
    /// - parameter withID: Identifier that you want to assign this object.
    /// - parameter completionHandler: Completion handler to be notified of the request's outcome.
    /// - returns: A cancellable operation.
    ///
    @objc public func addObject(object: [String: AnyObject], withID objectID: String, completionHandler: CompletionHandler? = nil) -> NSOperation {
        var object = object
        object["objectID"] = objectID
        return saveObject(object, completionHandler: completionHandler)
    }
    
    /// Add several objects to this index.
    ///
    /// - parameter objects: Objects to add.
    /// - parameter completionHandler: Completion handler to be notified of the request's outcome.
    /// - returns: A cancellable operation.
    ///
    @objc public func addObjects(objects: [[String: AnyObject]], completionHandler: CompletionHandler? = nil) -> NSOperation {
        return saveObjects(objects, completionHandler: completionHandler)
    }
    
    /// Delete an object from this index.
    ///
    /// - parameter objectID: Identifier of object to delete.
    /// - parameter completionHandler: Completion handler to be notified of the request's outcome.
    /// - returns: A cancellable operation.
    ///
    @objc public func deleteObject(objectID: String, completionHandler: CompletionHandler? = nil) -> NSOperation {
        return deleteObjects([objectID], completionHandler: completionHandler)
    }
    
    /// Delete several objects from this index.
    ///
    /// - parameter objectIDs: Identifiers of objects to delete.
    /// - parameter completionHandler: Completion handler to be notified of the request's outcome.
    /// - returns: A cancellable operation.
    ///
    @objc public func deleteObjects(objectIDs: [String], completionHandler: CompletionHandler? = nil) -> NSOperation {
        let operation = NSBlockOperation() {
            let (content, error) = self.deleteObjectsSync(objectIDs)
            self.callCompletionHandler(completionHandler, content: content, error: error)
        }
        client.buildQueue.addOperation(operation)
        return operation
    }
    
    /// Delete several objects from this index (synchronous version).
    ///
    /// + Warning: It is the caller's responsibility to ensure proper serialization of index write operations.
    ///
    /// - parameter objectIDs: Identifiers of objects to delete.
    /// - returns: A mutually exclusive (content, error) pair.
    ///
    private func deleteObjectsSync(objectIDs: [String]) -> (content: [String: AnyObject]?, error: NSError?) {
        var content: [String: AnyObject]?
        var error: NSError?
        let statusCode = Int(self.localIndex.buildFromSettingsFile(nil, objectFiles: [], clearIndex: false, deletedObjectIDs: objectIDs))
        if statusCode == StatusCode.OK.rawValue {
            content = ["objectID": objectIDs]
        } else {
            error = NSError(domain: ErrorDomain, code: statusCode, userInfo: nil)
        }
        return (content, error)
    }
    
    /// Get an object from this index.
    ///
    /// - parameter objectID: Identifier of the object to retrieve.
    /// - parameter completionHandler: Completion handler to be notified of the request's outcome.
    /// - returns: A cancellable operation.
    ///
    @objc public func getObject(objectID: String, completionHandler: CompletionHandler) -> NSOperation {
        return getObject(objectID, attributesToRetrieve: nil, completionHandler: completionHandler)
    }
    
    /// Get an object from this index, optionally restricting the retrieved content.
    ///
    /// - parameter objectID: Identifier of the object to retrieve.
    /// - parameter attributesToRetrieve: List of attributes to retrieve.
    /// - parameter completionHandler: Completion handler to be notified of the request's outcome.
    /// - returns: A cancellable operation.
    ///
    @objc public func getObject(objectID: String, attributesToRetrieve: [String]?, completionHandler: CompletionHandler) -> NSOperation {
        let operation = NSBlockOperation() {
            let (content, error) = self.getObject(objectID, attributesToRetrieve: attributesToRetrieve)
            self.callCompletionHandler(completionHandler, content: content, error: error)
        }
        client.searchQueue.addOperation(operation)
        return operation
    }
    
    private func getObject(objectID: String, attributesToRetrieve: [String]?) -> (content: [String: AnyObject]?, error: NSError?) {
        var content: [String: AnyObject]?
        var error: NSError?
        let query = Query()
        query.attributesToRetrieve = attributesToRetrieve
        let searchResults = self.localIndex.getObjects([objectID], parameters: query.build())
        (content, error) = OfflineClient.parseSearchResults(searchResults)
        if let content = content {
            guard let results = content["results"] as? [[String: AnyObject]] else {
                return (nil, NSError(domain: ErrorDomain, code: StatusCode.InternalServerError.rawValue, userInfo: nil)) // should never happen
            }
            guard results.count == 1 else {
                return (nil, NSError(domain: ErrorDomain, code: StatusCode.InternalServerError.rawValue, userInfo: nil)) // should never happen
            }
            let object = results[0]
            return (object, nil)
        }
        return (nil, error)
    }
    
    /// Get several objects from this index.
    ///
    /// - parameter objectIDs: Identifiers of objects to retrieve.
    /// - parameter completionHandler: Completion handler to be notified of the request's outcome.
    /// - returns: A cancellable operation.
    ///
    @objc public func getObjects(objectIDs: [String], completionHandler: CompletionHandler) -> NSOperation {
        let operation = NSBlockOperation() {
            var content: [String: AnyObject]?
            var error: NSError?
            let searchResults = self.localIndex.getObjects(objectIDs, parameters: nil)
            (content, error) = OfflineClient.parseSearchResults(searchResults)
            self.callCompletionHandler(completionHandler, content: content, error: error)
        }
        client.searchQueue.addOperation(operation)
        return operation
    }
    
    /// Update an object.
    ///
    /// - parameter object: New version of the object to update. Must contain an `objectID` attribute.
    /// - parameter completionHandler: Completion handler to be notified of the request's outcome.
    /// - returns: A cancellable operation.
    ///
    @objc public func saveObject(object: [String: AnyObject], completionHandler: CompletionHandler? = nil) -> NSOperation {
        return saveObjects([object], completionHandler: completionHandler)
    }
    
    /// Update several objects.
    ///
    /// - parameter objects: New versions of the objects to update. Each one must contain an `objectID` attribute.
    /// - parameter completionHandler: Completion handler to be notified of the request's outcome.
    /// - returns: A cancellable operation.
    ///
    @objc public func saveObjects(objects: [[String: AnyObject]], completionHandler: CompletionHandler? = nil) -> NSOperation {
        let operation = NSBlockOperation() {
            var content: [String: AnyObject]?
            var error: NSError?
            do {
                let jsonFilePath = try self.writeTempJSONFile(objects)
                let statusCode = Int(self.localIndex.buildFromSettingsFile(nil, objectFiles: [jsonFilePath], clearIndex: false, deletedObjectIDs: nil))
                if statusCode == StatusCode.OK.rawValue {
                    content = [:]
                } else {
                    error = NSError(domain: ErrorDomain, code: statusCode, userInfo: nil)
                }
                try NSFileManager.defaultManager().removeItemAtPath(jsonFilePath)
            } catch let e as NSError {
                error = e
            }
            self.callCompletionHandler(completionHandler, content: content, error: error)
        }
        client.buildQueue.addOperation(operation)
        return operation
    }
    
    /// Search this index.
    ///
    /// - parameter query: Search parameters.
    /// - parameter completionHandler: Completion handler to be notified of the request's outcome.
    /// - returns: A cancellable operation.
    ///
    @objc public func search(query: Query, completionHandler: CompletionHandler) -> NSOperation {
        let operation = NSBlockOperation() {
            var content: [String: AnyObject]?
            var error: NSError?
            let searchResults = self.localIndex.search(query.build())
            (content, error) = OfflineClient.parseSearchResults(searchResults)
            self.callCompletionHandler(completionHandler, content: content, error: error)
        }
        client.searchQueue.addOperation(operation)
        return operation
    }
    
    /// Get this index's settings.
    ///
    /// - parameter completionHandler: Completion handler to be notified of the request's outcome.
    /// - returns: A cancellable operation.
    ///
    @objc public func getSettings(completionHandler: CompletionHandler) -> NSOperation {
        let operation = NSBlockOperation() {
            var content: [String: AnyObject]?
            var error: NSError?
            let searchResults = self.localIndex.getSettings()
            (content, error) = OfflineClient.parseSearchResults(searchResults)
            self.callCompletionHandler(completionHandler, content: content, error: error)
        }
        client.searchQueue.addOperation(operation)
        return operation
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
    @objc public func setSettings(settings: [String: AnyObject], completionHandler: CompletionHandler? = nil) -> NSOperation {
        let operation = NSBlockOperation() {
            var content: [String: AnyObject]?
            var error: NSError?
            do {
                let jsonFilePath = try self.writeTempJSONFile(settings)
                let statusCode = Int(self.localIndex.buildFromSettingsFile(jsonFilePath, objectFiles: [], clearIndex: false, deletedObjectIDs: nil))
                if statusCode == StatusCode.OK.rawValue {
                    content = [:]
                } else {
                    error = NSError(domain: ErrorDomain, code: statusCode, userInfo: nil)
                }
                try NSFileManager.defaultManager().removeItemAtPath(jsonFilePath)
            } catch let e as NSError {
                error = e
            }
            self.callCompletionHandler(completionHandler, content: content, error: error)
        }
        client.buildQueue.addOperation(operation)
        return operation
    }
    
    /// Set this index's settings, optionally forwarding the change to slave indices.
    ///
    /// Please refer to our [API documentation](https://www.algolia.com/doc/swift#index-settings) for the list of
    /// supported settings.
    ///
    /// - parameter settings: New settings.
    /// - parameter forwardToSlaves: When true, the change is also applied to slaves of this index.
    /// - parameter completionHandler: Completion handler to be notified of the request's outcome.
    /// - returns: A cancellable operation.
    ///
    @objc public func setSettings(settings: [String: AnyObject], forwardToSlaves: Bool, completionHandler: CompletionHandler? = nil) -> NSOperation {
        assert(forwardToSlaves == false, "Slaves are not supported by offline indices")
        return setSettings(settings, completionHandler: completionHandler)
    }
    
    /// Delete the index content without removing settings.
    ///
    /// - parameter completionHandler: Completion handler to be notified of the request's outcome.
    /// - returns: A cancellable operation.
    ///
    @objc public func clearIndex(completionHandler: CompletionHandler? = nil) -> NSOperation {
        let operation = NSBlockOperation() {
            var content: [String: AnyObject]?
            var error: NSError?
            let statusCode = Int(self.localIndex.buildFromSettingsFile(nil, objectFiles: [], clearIndex: true, deletedObjectIDs: nil))
            if statusCode == StatusCode.OK.rawValue {
                content = [:]
            } else {
                error = NSError(domain: ErrorDomain, code: statusCode, userInfo: nil)
            }
            self.callCompletionHandler(completionHandler, content: content, error: error)
        }
        client.buildQueue.addOperation(operation)
        return operation
    }
    
    /// Browse all index content (initial call).
    /// This method should be called once to initiate a browse. It will return the first page of results and a cursor,
    /// unless the end of the index has been reached. To retrieve subsequent pages, call `browseFrom` with that cursor.
    ///
    /// - parameter query: The query parameters for the browse.
    /// - parameter completionHandler: Completion handler to be notified of the request's outcome.
    /// - returns: A cancellable operation.
    ///
    @objc public func browse(query: Query, completionHandler: CompletionHandler) -> NSOperation {
        let operation = NSBlockOperation() {
            var content: [String: AnyObject]?
            var error: NSError?
            let searchResults = self.localIndex.browse(query.build())
            (content, error) = OfflineClient.parseSearchResults(searchResults)
            self.callCompletionHandler(completionHandler, content: content, error: error)
        }
        client.searchQueue.addOperation(operation)
        return operation
    }
    
    /// Browse the index from a cursor.
    /// This method should be called after an initial call to `browse()`. It returns a cursor, unless the end of the
    /// index has been reached.
    ///
    /// - parameter cursor: The cursor of the next page to retrieve
    /// - parameter completionHandler: Completion handler to be notified of the request's outcome.
    /// - returns: A cancellable operation.
    ///
    @objc public func browseFrom(cursor: String, completionHandler: CompletionHandler) -> NSOperation {
        let operation = NSBlockOperation() {
            var content: [String: AnyObject]?
            var error: NSError?
            let searchResults = self.localIndex.browse(Query(parameters: ["cursor": cursor]).build())
            (content, error) = OfflineClient.parseSearchResults(searchResults)
            self.callCompletionHandler(completionHandler, content: content, error: error)
        }
        client.searchQueue.addOperation(operation)
        return operation
    }
    
    // MARK: - Helpers
    
    /// Delete all objects matching a query (helper).
    ///
    /// - parameter query: The query that objects to delete must match.
    /// - parameter completionHandler: Completion handler to be notified of the request's outcome.
    /// - returns: A cancellable operation.
    ///
    @objc public func deleteByQuery(query: Query, completionHandler: CompletionHandler? = nil) -> NSOperation {
        let operation = NSBlockOperation() {
            let (content, error) = self.deleteByQuerySync(query)
            self.callCompletionHandler(completionHandler, content: content, error: error)
        }
        client.buildQueue.addOperation(operation)
        return operation
    }
    
    private func deleteByQuerySync(query: Query) -> (content: [String: AnyObject]?, error: NSError?) {
        let browseQuery = Query(copy: query)
        browseQuery.attributesToRetrieve = ["objectID"]
        let queryParameters = browseQuery.build()
        
        // Gather object IDs to delete.
        var objectIDsToDelete: [String] = []
        var hasMore = true
        while hasMore {
            let (content, error) = OfflineClient.parseSearchResults(self.localIndex.browse(queryParameters))
            guard let returnedContent = content else {
                return (content, error)
            }
            guard let hits = content!["hits"] as? [AnyObject] else {
                return (nil, NSError(domain: Client.ErrorDomain, code: -1, userInfo: [NSLocalizedDescriptionKey: "No hits returned when browsing"]))
            }
            // Retrieve object IDs.
            for hit in hits {
                if let objectID = (hit as? [String: AnyObject])?["objectID"] as? String {
                    objectIDsToDelete.append(objectID)
                }
            }
            hasMore = returnedContent["cursor"] != nil
        }

        // Delete objects.
        return self.deleteObjectsSync(objectIDsToDelete)
    }
    
    /// Perform a search with disjunctive facets, generating as many queries as number of disjunctive facets (helper).
    ///
    /// - parameter query: The query.
    /// - parameter disjunctiveFacets: List of disjunctive facets.
    /// - parameter refinements: The current refinements, mapping facet names to a list of values.
    /// - parameter completionHandler: Completion handler to be notified of the request's outcome.
    /// - returns: A cancellable operation.
    ///
    @objc public func searchDisjunctiveFaceting(query: Query, disjunctiveFacets: [String], refinements: [String: [String]], completionHandler: CompletionHandler) -> NSOperation {
        return DisjunctiveFaceting(multipleQuerier: { (queries: [Query], completionHandler: CompletionHandler) in
            return self.multipleQueries(queries, completionHandler: completionHandler)
        }).searchDisjunctiveFaceting(query, disjunctiveFacets: disjunctiveFacets, refinements: refinements, completionHandler: completionHandler)
    }
    
    /// Run multiple queries on this index.
    ///
    /// - parameter queries: The queries to run.
    /// - parameter completionHandler: Completion handler to be notified of the request's outcome.
    /// - returns: A cancellable operation.
    ///
    @objc public func multipleQueries(queries: [Query], strategy: String?, completionHandler: CompletionHandler) -> NSOperation {
        let emulator = MultipleQueryEmulator(indexName: self.name, querier: { (query: Query) in
            let searchResults = self.localIndex.search(query.build())
            return OfflineClient.parseSearchResults(searchResults)
        })
        let operation = NSBlockOperation() {
            let (content, error) = emulator.multipleQueries(queries, strategy: strategy)
            self.callCompletionHandler(completionHandler, content: content, error: error)
        }
        client.searchQueue.addOperation(operation)
        return operation
    }
    
    /// Run multiple queries on this index.
    ///
    /// - parameter queries: The queries to run.
    /// - parameter strategy: The strategy to use.
    /// - parameter completionHandler: Completion handler to be notified of the request's outcome.
    /// - returns: A cancellable operation.
    ///
    public func multipleQueries(queries: [Query], strategy: Client.MultipleQueriesStrategy? = nil, completionHandler: CompletionHandler) -> NSOperation {
        return self.multipleQueries(queries, strategy: strategy?.rawValue, completionHandler: completionHandler)
    }
    
    // MARK: - Utils
    
    /// Call a completion handler on the main queue.
    ///
    /// - parameter completionHandler: The completion handler to call. If `nil`, this function does nothing.
    /// - parameter content: The content to pass as a first argument to the completion handler.
    /// - parameter error: The error to pass as a second argument to the completion handler.
    ///
    private func callCompletionHandler(completionHandler: CompletionHandler?, content: [String: AnyObject]?, error: NSError?) {
        if let completionHandler = completionHandler {
            dispatch_async(dispatch_get_main_queue(), {
                completionHandler(content: content, error: error)
            })
        }
    }
    
    /// Write a JSON object/array to a temporary file.
    /// The path of the file is computed automatically.
    ///
    /// - parameters json: A JSON object or array.
    /// - returns: The created file path.
    ///
    private func writeTempJSONFile(json: AnyObject) throws -> String {
        // Create temporary directory if necessary.
        let tmpDirPath = NSTemporaryDirectory() + "/algolia"
        try NSFileManager.defaultManager().createDirectoryAtPath(tmpDirPath, withIntermediateDirectories: true, attributes: nil)
        
        // Create unique file path.
        // TODO: We could use `mktemp()`, but passing a mutable C string is, well... daunting.
        let tmpFilePath = tmpDirPath + "/" + NSUUID().UUIDString + ".json"
        
        // Write results to disk.
        let data = try NSJSONSerialization.dataWithJSONObject(json, options: [])
        data.writeToFile(tmpFilePath, atomically: false)
        return tmpFilePath
    }
}
