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
/// # Limitations
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
///
/// ## Operation cancellation
///
/// Just like online indices, an offline index bears *no rollback semantic*: cancelling an operation does **not**
/// prevent the data from being modified. It just prevents the completion handler from being called.
///
@objc public class OfflineIndex : NSObject {
    // TODO: Expose common behavior through a protocol.
    // TODO: Factorize common behavior in a base class.
    
    // MARK: Properties
    
    /// This index's name.
    @objc public let indexName: String
    
    /// API client used by this index.
    @objc public let client: OfflineClient

    /// The local index (lazy instantiated).
    lazy var localIndex: ASLocalIndex! = ASLocalIndex(dataDir: self.client.rootDataDir, appID: self.client.appID, indexName: self.indexName)

    let urlEncodedIndexName: String
    
    var searchCache: ExpiringCache?
    
    // MARK: - Initialization
    
    /// Create a new index proxy.
    @objc internal init(client: OfflineClient, indexName: String) {
        self.client = client
        self.indexName = indexName
        urlEncodedIndexName = indexName.urlEncodedPathComponent()
    }
    
    override public var description: String {
        get {
            // TODO: Move to a higher level.
            return "Index{\"\(indexName)\"}"
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
        assert(object["objectID"] as? String == objectID)
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
            let statusCode = Int(self.localIndex.buildFromSettingsFile(nil, objectFiles: [], clearIndex: false, deletedObjectIDs: objectIDs))
            if statusCode == StatusCode.OK.rawValue {
                completionHandler?(content: [:], error: nil)
            } else {
                completionHandler?(content: nil, error: NSError(domain: ErrorDomain, code: statusCode, userInfo: nil))
            }
        }
        client.buildQueue.addOperation(operation)
        return operation
    }
    
    /// Get an object from this index.
    ///
    /// - parameter objectID: Identifier of the object to retrieve.
    /// - parameter completionHandler: Completion handler to be notified of the request's outcome.
    /// - returns: A cancellable operation.
    ///
    @objc public func getObject(objectID: String, completionHandler: CompletionHandler) -> NSOperation {
        // TODO: Requires support from the Offline Core.
        // TODO: Implement.
        assert(false)
    }
    
    /// Get an object from this index, optionally restricting the retrieved content.
    ///
    /// - parameter objectID: Identifier of the object to retrieve.
    /// - parameter attributesToRetrieve: List of attributes to retrieve.
    /// - parameter completionHandler: Completion handler to be notified of the request's outcome.
    /// - returns: A cancellable operation.
    ///
    @objc public func getObject(objectID: String, attributesToRetrieve attributes: [String], completionHandler: CompletionHandler) -> NSOperation {
        // TODO: Requires support from the Offline Core.
        // TODO: Implement.
        assert(false)
    }
    
    /// Get several objects from this index.
    ///
    /// - parameter objectIDs: Identifiers of objects to retrieve.
    /// - parameter completionHandler: Completion handler to be notified of the request's outcome.
    /// - returns: A cancellable operation.
    ///
    @objc public func getObjects(objectIDs: [String], completionHandler: CompletionHandler) -> NSOperation {
        // TODO: Requires support from the Offline Core.
        // TODO: Implement.
        assert(false)
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
        // TODO: Requires support from the Offline Core.
        // TODO: Implement.
        assert(false)
    }
    
    /// Search this index.
    ///
    /// - parameter query: Search parameters.
    /// - parameter completionHandler: Completion handler to be notified of the request's outcome.
    /// - returns: A cancellable operation.
    ///
    @objc public func search(query: Query, completionHandler: CompletionHandler) -> NSOperation {
        // TODO: Implement.
        assert(false)
    }
    
    /// Get this index's settings.
    ///
    /// - parameter completionHandler: Completion handler to be notified of the request's outcome.
    /// - returns: A cancellable operation.
    ///
    @objc public func getSettings(completionHandler: CompletionHandler) -> NSOperation {
        // TODO: Requires support from the Offline Core.
        // TODO: Implement.
        assert(false)
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
        // TODO: Implement.
        assert(false)
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
        // TODO: Implement.
        assert(false)
    }
    
    /// Delete the index content without removing settings and index specific API keys.
    ///
    /// - parameter completionHandler: Completion handler to be notified of the request's outcome.
    /// - returns: A cancellable operation.
    ///
    @objc public func clearIndex(completionHandler: CompletionHandler? = nil) -> NSOperation {
        // TODO: Implement.
        assert(false)
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
        // TODO: Factorize with `MirroredIndex`?
        assert(false)
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
        // TODO: Factorize with `MirroredIndex`?
        assert(false)
    }
    
    // MARK: - Helpers
    
    /// Wait until the publication of a task on the server (helper).
    /// All server tasks are asynchronous. This method helps you check that a task is published.
    ///
    /// - parameter taskID: Identifier of the task (as returned by the server).
    /// - parameter completionHandler: Completion handler to be notified of the request's outcome.
    /// - returns: A cancellable operation.
    ///
    @objc public func waitTask(taskID: Int, completionHandler: CompletionHandler) -> NSOperation {
        // TODO: Implement locally (the core has no notion of task ID).
        assert(false, "Unsupported")
    }
    
    /// Delete all objects matching a query (helper).
    ///
    /// - parameter query: The query that objects to delete must match.
    /// - parameter completionHandler: Completion handler to be notified of the request's outcome.
    /// - returns: A cancellable operation.
    ///
    @objc public func deleteByQuery(query: Query, completionHandler: CompletionHandler? = nil) -> NSOperation {
        // TODO: Move to a higher level.
        assert(false)
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
        // TODO: Move to a higher level.
        assert(false)
    }
    
    /// Run multiple queries on this index.
    /// This method is a variant of `Client.multipleQueries(...)` where the targeted index is always the receiver.
    ///
    /// - parameter queries: The queries to run.
    /// - parameter completionHandler: Completion handler to be notified of the request's outcome.
    /// - returns: A cancellable operation.
    ///
    @objc public func multipleQueries(queries: [Query], strategy: String?, completionHandler: CompletionHandler) -> NSOperation {
        // TODO: Factorize with `MirroredIndex`.
        assert(false)
    }
    
    // MARK: - Search Cache
    
    @objc public func enableSearchCache(expiringTimeInterval: NSTimeInterval = 120) {
        // TODO: Move to a higher level.
    }
    
    @objc public func disableSearchCache() {
        // TODO: Move to a higher level.
    }
    
    @objc public func clearSearchCache() {
        // TODO: Move to a higher level.
    }
}
