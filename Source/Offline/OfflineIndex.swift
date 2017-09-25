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


public struct IOError: CustomNSError {
    /// Further description of this error.
    public let description: String
    
    public init(description: String) {
        self.description = description
    }
    
    // MARK: CustomNSError protocol
    // ... for Objective-C bridging.
    
    public static var errorDomain: String = String(reflecting: InvalidJSONError.self)
    
    public var errorCode: Int { return 601 }
    
    public var errorUserInfo: [String : Any] {
        return [
            NSLocalizedDescriptionKey: description
        ]
    }
}


/// A purely offline index.
/// Such an index has no online counterpart. It is updated and queried locally.
///
/// + Note: You cannot construct this class directly. Please use `OfflineClient.offlineIndex(withName:)` to obtain an
///   instance.
///
/// + Note: Requires Algolia Offline Core. `OfflineClient.enableOfflineMode(...)` must be called with a valid license
///   key prior to calling any offline-related method.
///
///
/// ## Reading
///
/// Read operations behave identically as with online indices.
///
///
/// ## Writing
///
/// Updating an index involves rebuilding it, which is an expensive and potentially lengthy operation. Therefore, all
/// updates must be wrapped inside a **transaction**.
///
/// The procedure to update an index is as follows:
///
/// - Create a transaction by calling `newTransaction()`.
///
/// - Populate the transaction: call the various write methods on the `WriteTransaction` class.
///
/// - Either `commit()` or `rollback()` the transaction.
///
/// ### Synchronous vs asynchronous updates
///
/// Any write operation, especially (but not limited to) the final commit, is potentially lengthy. This is why all
/// operations provide an asynchronous version, which accepts an optional completion handler that will be notified of
/// the operation's completion (either successful or erroneous).
///
/// If you already have a background thread/queue performing data-handling tasks, you may find it more convenient to
/// use the synchronous versions of the write methods. They are named after the asynchronous versions, suffixed by
/// `Sync`. The flow is identical to the asynchronous version (see above).
///
/// + Warning: You must not call synchronous methods from the main thread. The methods will assert if you do so.
///
/// + Note: The synchronous methods can throw; you have to catch and handle the error.
///
/// ### Parallel transactions
///
/// While it is possible to create parallel transactions, there is little interest in doing so, since each committed
/// transaction results in an index rebuild. Multiplying transactions therefore only degrades performance.
///
/// Also, transactions are serially executed in the order they were committed, the latest transaction potentially
/// overwriting the previous transactions' result.
///
/// ### Manual build
///
/// As an alternative to using write transactions, `OfflineIndex` also offers a **manual build** feature. Provided that
/// you have:
///
/// - the **index settings** (one JSON file); and
/// - the **objects** (as many JSON files as needed, each containing an array of objects)
///
/// ... available as local files on disk, you can replace the index's content with that data by calling `build(...)`.
///
///
/// ## Caveats
///
/// ### Limitations
///
/// Though offline indices support most features of an online index, there are some limitations:
///
/// - Objects **must contain an `objectID`** field. The SDK will refuse to index objects without an ID.
///
/// - **Partial updates** are not supported.
///
/// - **Replica indices** are not supported.
///
/// ### Differences
///
/// - **Settings** are not incremental: the new settings completely replace the previous ones. If a setting
///   is omitted in the new version, it reverts back to its default value. (This is in contrast with the online API,
///   where you can only specify the settings you want to change and omit the others.)
///
/// - You cannot batch arbitrary write operations in a single method call (as you would do with `Index.batch(...)`).
///   However, all write operations are *de facto* batches, since they must be wrapped inside a transaction (see below).
///
@objc public class OfflineIndex : NSObject, Searchable {
    // TODO: Expose common behavior through a protocol.
    // TODO: Factorize common behavior in a base class.
    
    // ----------------------------------------------------------------------
    // MARK: Properties
    // ----------------------------------------------------------------------
    
    /// This index's name.
    @objc public let name: String
    
    /// API client used by this index.
    @objc public let client: OfflineClient

    /// The local index.
    var localIndex: LocalIndex

    /// Queue used to run transaction bodies (but not the build).
    private let transactionQueue: OperationQueue
    
    /// Serial number for transactions.
    private var transactionSeqNo: Int = 0

    /// Dispatch queue used to serialize access to `transactionSeqNo`.
    private let transactionSeqNo_lock = DispatchQueue(label: "OfflineIndex.transactionSeqNo.lock")
    
    /// Whether this index has offline data on disk.
    ///
    @objc public var hasOfflineData: Bool {
        get {
            return localIndex.exists()
        }
    }
    
    // ----------------------------------------------------------------------
    // MARK: - Initialization
    // ----------------------------------------------------------------------
    
    /// Create a new offline index.
    ///
    /// - parameter client: The offline client used by this index.
    /// - parameter name: This index's name.
    ///
    internal init(client: OfflineClient, name: String) {
        self.client = client
        self.name = name
        self.transactionQueue = OperationQueue()
        self.transactionQueue.maxConcurrentOperationCount = 1
        self.localIndex = LocalIndex(dataDir: self.client.rootDataDir, appID: self.client.appID, indexName: self.name)
    }
    
    override public var description: String {
        get {
            // TODO: Move to a higher level.
            return "Index{\"\(name)\"}"
        }
    }
    
    // ----------------------------------------------------------------------
    // MARK: - Read operations
    // ----------------------------------------------------------------------
    
    /// Get an object from this index.
    ///
    /// - parameter objectID: Identifier of the object to retrieve.
    /// - parameter completionHandler: Completion handler to be notified of the request's outcome.
    /// - returns: A cancellable operation.
    ///
    @discardableResult
    @objc public func getObject(withID objectID: String, completionHandler: @escaping CompletionHandler) -> Operation {
        return getObject(withID: objectID, attributesToRetrieve: nil, completionHandler: completionHandler)
    }
    
    /// Get an object from this index, optionally restricting the retrieved content.
    ///
    /// - parameter objectID: Identifier of the object to retrieve.
    /// - parameter attributesToRetrieve: List of attributes to retrieve.
    ///                                   If `nil`, all (retrievable) attributes will be retrieved.
    /// - parameter completionHandler: Completion handler to be notified of the request's outcome.
    /// - returns: A cancellable operation.
    ///
    @discardableResult
    @objc public func getObject(withID objectID: String, attributesToRetrieve: [String]?, completionHandler: @escaping CompletionHandler) -> Operation {
        let operation = BlockOperation() {
            let (content, error) = self.getObjectSync(withID: objectID, attributesToRetrieve: attributesToRetrieve)
            self.callCompletionHandler(completionHandler, content: content, error: error)
        }
        client.offlineSearchQueue.addOperation(operation)
        return operation
    }
    
    /// Get an object from this index (synchronous version).
    ///
    /// - parameter objectID: Identifier of the object to retrieve.
    /// - parameter attributesToRetrieve: List of attributes to retrieve.
    ///                                   If `nil`, all (retrievable) attributes will be retrieved.
    /// - returns: A mutually exclusive (content, error) pair.
    ///
    private func getObjectSync(withID objectID: String, attributesToRetrieve: [String]?) -> APIResponse {
        var content: JSONObject?
        var error: Error?
        let query = Query()
        query.attributesToRetrieve = attributesToRetrieve
        let searchResults = self.localIndex.getObjects(withIDs: [objectID], parameters: query.build())
        (content, error) = OfflineClient.parseResponse(searchResults)
        if let content = content {
            guard let results = content["results"] as? [JSONObject] else {
                return (nil, InvalidJSONError(description: "Invalid results returned")) // should never happen
            }
            guard results.count == 1 else {
                return (nil, InvalidJSONError(description: "Invalid results returned")) // should never happen
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
    @discardableResult
    @objc public func getObjects(withIDs objectIDs: [String], completionHandler: @escaping CompletionHandler) -> Operation {
        return getObjects(withIDs: objectIDs, attributesToRetrieve: nil, completionHandler: completionHandler)
    }
    
    /// Get several objects from this index (synchronous version).
    ///
    /// - parameter objectIDs: Identifiers of objects to retrieve.
    /// - returns: A mutually exclusive (content, error) pair.
    ///
    private func getObjectsSync(withIDs objectIDs: [String]) -> APIResponse {
        return getObjectsSync(withIDs: objectIDs, attributesToRetrieve: nil)
    }

    /// Get several objects from this index, optionally restricting the retrieved content.
    ///
    /// - parameter objectIDs: Identifiers of objects to retrieve.
    /// - parameter attributesToRetrieve: List of attributes to retrieve.
    ///                                   If `nil`, all (retrievable) attributes will be retrieved.
    /// - parameter completionHandler: Completion handler to be notified of the request's outcome.
    /// - returns: A cancellable operation.
    ///
    @discardableResult
    @objc public func getObjects(withIDs objectIDs: [String], attributesToRetrieve: [String]?, completionHandler: @escaping CompletionHandler) -> Operation {
        let operation = BlockOperation() {
            let (content, error) = self.getObjectsSync(withIDs: objectIDs, attributesToRetrieve: attributesToRetrieve)
            self.callCompletionHandler(completionHandler, content: content, error: error)
        }
        client.offlineSearchQueue.addOperation(operation)
        return operation
    }
    
    /// Get several objects from this index, optionally restricting the retrieved content (synchronous version).
    ///
    /// - parameter objectIDs: Identifiers of objects to retrieve.
    /// - parameter attributesToRetrieve: List of attributes to retrieve.
    ///                                   If `nil`, all (retrievable) attributes will be retrieved.
    /// - returns: A mutually exclusive (content, error) pair.
    ///
    private func getObjectsSync(withIDs objectIDs: [String], attributesToRetrieve: [String]?) -> APIResponse {
        let query = Query()
        query.attributesToRetrieve = attributesToRetrieve
        let searchResults = self.localIndex.getObjects(withIDs: objectIDs, parameters: query.build())
        return OfflineClient.parseResponse(searchResults)
    }

    /// Search this index.
    ///
    /// - parameter query: Search parameters.
    /// - parameter completionHandler: Completion handler to be notified of the request's outcome.
    /// - returns: A cancellable operation.
    ///
    @discardableResult
    @objc public func search(_ query: Query, requestOptions: RequestOptions? = nil, completionHandler: @escaping CompletionHandler) -> Operation {
        let operation = BlockOperation() {
            let (content, error) = self.searchSync(Query(copy: query))
            self.callCompletionHandler(completionHandler, content: content, error: error)
        }
        client.offlineSearchQueue.addOperation(operation)
        return operation
    }
    
    @objc(search:completionHandler:)
    @discardableResult public func z_objc_search(_ query: Query, completionHandler: @escaping CompletionHandler) -> Operation {
        return self.search(query, completionHandler: completionHandler)
    }
    
    /// Search this index (synchronous version).
    ///
    /// - parameter query: Search parameters.
    /// - returns: A mutually exclusive (content, error) pair.
    ///
    private func searchSync(_ query: Query) -> APIResponse {
        let searchResults = self.localIndex.search(query.build())
        return OfflineClient.parseResponse(searchResults)
    }

    /// Get this index's settings.
    ///
    /// - parameter completionHandler: Completion handler to be notified of the request's outcome.
    /// - returns: A cancellable operation.
    ///
    @discardableResult
    @objc(getSettings:)
    public func getSettings(completionHandler: @escaping CompletionHandler) -> Operation {
        let operation = BlockOperation() {
            let (content, error) = self.getSettingsSync()
            self.callCompletionHandler(completionHandler, content: content, error: error)
        }
        client.offlineSearchQueue.addOperation(operation)
        return operation
    }
    
    /// Get this index's settings (synchronous version).
    ///
    /// - returns: A mutually exclusive (content, error) pair.
    ///
    private func getSettingsSync() -> APIResponse {
        let searchResults = self.localIndex.getSettings()
        return OfflineClient.parseResponse(searchResults)
    }
    
    /// Browse all index content (initial call).
    /// This method should be called once to initiate a browse. It will return the first page of results and a cursor,
    /// unless the end of the index has been reached. To retrieve subsequent pages, call `browseFrom` with that cursor.
    ///
    /// - parameter query: The query parameters for the browse.
    /// - parameter completionHandler: Completion handler to be notified of the request's outcome.
    /// - returns: A cancellable operation.
    ///
    @discardableResult
    @objc public func browse(query: Query, completionHandler: @escaping CompletionHandler) -> Operation {
        let operation = BlockOperation() {
            let (content, error) = self.browseSync(query: Query(copy: query))
            self.callCompletionHandler(completionHandler, content: content, error: error)
        }
        client.offlineSearchQueue.addOperation(operation)
        return operation
    }
    
    /// Browse all index content (initial call) (synchronous version).
    /// This method should be called once to initiate a browse. It will return the first page of results and a cursor,
    /// unless the end of the index has been reached. To retrieve subsequent pages, call `browseFrom` with that cursor.
    ///
    /// - parameter query: The query parameters for the browse.
    /// - returns: A mutually exclusive (content, error) pair.
    ///
    private func browseSync(query: Query) -> APIResponse {
        let searchResults = self.localIndex.browse(query.build())
        return OfflineClient.parseResponse(searchResults)
    }
    
    /// Browse the index from a cursor.
    /// This method should be called after an initial call to `browse(...)`. It returns a cursor, unless the end of the
    /// index has been reached.
    ///
    /// - parameter cursor: The cursor of the next page to retrieve
    /// - parameter completionHandler: Completion handler to be notified of the request's outcome.
    /// - returns: A cancellable operation.
    ///
    @discardableResult
    @objc public func browseFrom(cursor: String, completionHandler: @escaping CompletionHandler) -> Operation {
        let operation = BlockOperation() {
            let (content, error) = self.browseSync(from: cursor)
            self.callCompletionHandler(completionHandler, content: content, error: error)
        }
        client.offlineSearchQueue.addOperation(operation)
        return operation
    }

    /// Browse the index from a cursor (synchronous version).
    /// This method should be called after an initial call to `browse()`. It returns a cursor, unless the end of the
    /// index has been reached.
    ///
    /// - parameter cursor: The cursor of the next page to retrieve
    /// - parameter completionHandler: Completion handler to be notified of the request's outcome.
    /// - returns: A cancellable operation.
    ///
    private func browseSync(from cursor: String) -> APIResponse {
        let searchResults = self.localIndex.browse(Query(parameters: ["cursor": cursor]).build())
        return OfflineClient.parseResponse(searchResults)
    }

    /// Run multiple queries on this index.
    ///
    /// - parameter queries: The queries to run.
    /// - parameter strategy: The strategy to use.
    /// - parameter completionHandler: Completion handler to be notified of the request's outcome.
    /// - returns: A cancellable operation.
    ///
    @discardableResult
    @objc public func multipleQueries(_ queries: [Query], strategy: String?, completionHandler: @escaping CompletionHandler) -> Operation {
        let operation = BlockOperation() {
            let (content, error) = self.multipleQueriesSync(queries, strategy: strategy)
            self.callCompletionHandler(completionHandler, content: content, error: error)
        }
        client.offlineSearchQueue.addOperation(operation)
        return operation
    }

    /// Run multiple queries on this index (synchronous version).
    ///
    /// - parameter queries: The queries to run.
    /// - parameter strategy: The strategy to use.
    /// - returns: A mutually exclusive (content, error) pair.
    ///
    private func multipleQueriesSync(_ queries: [Query], strategy: String?) -> APIResponse {
        let emulator = MultipleQueryEmulator(indexName: self.name, querier: { (query: Query) in
            return self.searchSync(query)
        })
        return emulator.multipleQueries(queries, strategy: strategy)
    }

    /// Run multiple queries on this index.
    ///
    /// - parameter queries: The queries to run.
    /// - parameter strategy: The strategy to use.
    /// - parameter completionHandler: Completion handler to be notified of the request's outcome.
    /// - returns: A cancellable operation.
    ///
    @discardableResult
    public func multipleQueries(_ queries: [Query], strategy: Client.MultipleQueriesStrategy? = nil, completionHandler: @escaping CompletionHandler) -> Operation {
        return self.multipleQueries(queries, strategy: strategy?.rawValue, completionHandler: completionHandler)
    }

    /// Run multiple queries on this index (synchronous version).
    ///
    /// - parameter queries: The queries to run.
    /// - parameter strategy: The strategy to use.
    /// - returns: A mutually exclusive (content, error) pair.
    ///
    private func multipleQueriesSync(_ queries: [Query], strategy: Client.MultipleQueriesStrategy? = nil) -> APIResponse {
        return self.multipleQueriesSync(queries, strategy: strategy?.rawValue)
    }
    
    /// Search for facet values.
    /// Same parameters as `Index.searchForFacetValues(...)`.
    ///
    @discardableResult
    @objc(searchForFacetValuesOf:matching:query:requestOptions:completionHandler:)
    public func searchForFacetValues(of facetName: String, matching text: String, query: Query? = nil, requestOptions: RequestOptions? = nil, completionHandler: @escaping CompletionHandler) -> Operation {
        let queryCopy = query != nil ? Query(copy: query!) : nil
        let operation = BlockOperation() {
            let (content, error) = self.searchForFacetValuesSync(of: facetName, matching: text, query: queryCopy)
            self.callCompletionHandler(completionHandler, content: content, error: error)
        }
        client.offlineSearchQueue.addOperation(operation)
        return operation
    }
    
    @objc(searchForFacetValuesOf:matching:query:completionHandler:)
    @discardableResult public func z_objc_searchForFacetValues(of facetName: String, matching text: String, query: Query, completionHandler: @escaping CompletionHandler) -> Operation {
        return self.searchForFacetValues(of: facetName, matching: text, query: query, completionHandler: completionHandler)
    }
        
    /// Search for facet values (synchronous version).
    ///
    private func searchForFacetValuesSync(of facetName: String, matching text: String, query: Query? = nil) -> APIResponse {
        let searchResults = self.localIndex.searchForFacetValues(of: facetName, matching: text, parameters: query?.build())
        return OfflineClient.parseResponse(searchResults)
    }

    // ----------------------------------------------------------------------
    // MARK: - Write operations
    // ----------------------------------------------------------------------
    
    /// A transaction to update the index.
    ///
    /// A transaction gathers all the operations that will be performed when the transaction is committed.
    /// Its purpose is twofold:
    ///
    /// 1. Avoid rebuilding the index for every individual operation, which would be very costly.
    /// 2. Avoid keeping all the necessary data in memory, e.g. by flushing added objects to temporary files on disk.
    ///
    /// A transaction can be created by calling `OfflineIndex.newTransaction()`.
    ///
    @objc public class WriteTransaction: NSObject {
        /// The index on which this transaction will operate.
        @objc public let index: OfflineIndex
        
        /// This transaction's ID.
        /// Unique within the context of `index`.
        /// *Not* guaranteed to be unique across all indices.
        ///
        @objc public let identifier: Int
        
        /// Whether this transaction has completed (committed or rolled back).
        @objc public private(set) var finished: Bool = false

        /// Path to the temporary file containing the new settings.
        /// If `nil`, settings will be unchanged by this transaction.
        private var settingsFilePath: String? = nil
        
        /// Paths to the temporary files containing the objects that will be added/updated by this transaction.
        private var objectFilePaths: [String] = []
        
        /// Identifiers of objects that will be deleted by this transaction.
        ///
        /// + Warning: Deleted objects have higher precedence than added/updated objects.
        ///
        private var deletedObjectIDs: Set<String> = Set<String>()
        
        /// Whether the index should be cleared before executing this transaction.
        private var shouldClearIndex: Bool = false
        
        /// Temporary directory for this transaction.
        private let tmpDirPath: String
        
        /// Temporary in-memory cache for objects.
        private var tmpObjects: [JSONObject] = []
        
        /// Dispatch queue used to serialize accesses to a transaction's data.
        private var self_lock = DispatchQueue(label: String(reflecting: type(of: self)) + ".lock")
        
        // MARK: Constants
        
        /// Maximum number of objects to keep in memory before flushing to disk.
        private static let maxObjectsInMemory = 100
        
        // MARK: Initialization
        
        fileprivate init(index: OfflineIndex) {
            self.index = index
            self.identifier = index.nextTransactionSeqNo()
            self.tmpDirPath = URL(fileURLWithPath: index.client.tmpDir).appendingPathComponent(NSUUID().uuidString).path
            super.init()
            
            // Create temporary directory.
            try! FileManager.default.createDirectory(atPath: tmpDirPath, withIntermediateDirectories: true, attributes: nil)
        }
        
        deinit {
            if !finished {
                NSLog("[WARNING] Transaction %@ was never committed nor rolled back", self)
                doRollback()
            }
        }
        
        override public var description: String { return "WriteTransaction{index: \(index), identifier: \(identifier)}" }
        
        // MARK: Populating

        /// Save an object (synchronously).
        ///
        /// - parameter object: Object to save. It must contain an `objectID` attribute.
        ///
        @objc public func saveObjectSync(_ object: JSONObject) throws {
            assertNotMainThread()
            try self_lock.sync {
                assert(!finished)
                tmpObjects.append(object)
                try flushObjectsToDisk(force: false)
            }
        }
        
        /// Save an object.
        ///
        /// - parameter object: Object to save. It must contain an `objectID` attribute.
        /// - parameter completionHandler: Completion handler to be notified when the transaction has been updated.
        /// - returns: The corresponding operation.
        ///
        @discardableResult
        @objc public func saveObject(_ object: JSONObject, completionHandler: CompletionHandler? = nil) -> Operation {
            let operation = BlockOperation() {
                do {
                    try self.saveObjectSync(object)
                    guard let objectID = object["objectID"] else {
                        throw InvalidJSONError(description: "Object is missing required `objectID` attribute")
                    }
                    let content: JSONObject = [
                        "objectID": objectID
                    ]
                    completionHandler?(content, nil)
                } catch let e {
                    completionHandler?(nil, e)
                }
            }
            index.transactionQueue.addOperation(operation)
            return operation
        }

        /// Save multiple objects (synchronously).
        ///
        /// - parameter objects: New versions of the objects to update. Each one must contain an `objectID` attribute.
        ///
        @objc public func saveObjectsSync(_ objects: [JSONObject]) throws {
            assertNotMainThread()
            try self_lock.sync {
                assert(!finished)
                tmpObjects.append(contentsOf: objects)
                try flushObjectsToDisk(force: false)
            }
        }
        
        /// Save multiple objects.
        ///
        /// - parameter objects: New versions of the objects to update. Each one must contain an `objectID` attribute.
        /// - parameter completionHandler: Completion handler to be notified when the transaction has been updated.
        /// - returns: The corresponding operation.
        ///
        @discardableResult
        @objc public func saveObjects(_ objects: [JSONObject], completionHandler: CompletionHandler? = nil) -> Operation {
            let operation = BlockOperation() {
                do {
                    try self.saveObjectsSync(objects)
                    let objectIDs = try objects.map({ (object: JSONObject) -> Any in
                        guard let objectID = object["objectID"] else {
                            throw InvalidJSONError(description: "Object is missing required `objectID` attribute")
                        }
                        return objectID
                    })
                    let content: JSONObject = [
                        "objectIDs": objectIDs
                    ]
                    completionHandler?(content, nil)
                } catch let e {
                    completionHandler?(nil, e)
                }
            }
            index.transactionQueue.addOperation(operation)
            return operation
        }
        
        /// Delete an object (synchronously).
        ///
        /// - parameter objectID: Identifier of the object to delete.
        ///
        @objc public func deleteObjectSync(withID objectID: String) throws {
            assertNotMainThread()
            self_lock.sync {
                assert(!finished)
                deletedObjectIDs.insert(objectID)
            }
        }
        
        /// Delete an object.
        ///
        /// - parameter objectID: Identifier of the object to delete.
        /// - parameter completionHandler: Completion handler to be notified when the transaction has been updated.
        /// - returns: The corresponding operation.
        ///
        @discardableResult
        @objc public func deleteObject(withID objectID: String, completionHandler: CompletionHandler? = nil) -> Operation {
            let operation = BlockOperation() {
                do {
                    try self.deleteObjectSync(withID: objectID)
                    let content: JSONObject = [
                        "objectID": objectID
                    ]
                    completionHandler?(content, nil)
                } catch let e {
                    completionHandler?(nil, e)
                }
            }
            index.transactionQueue.addOperation(operation)
            return operation
        }

        /// Delete multiple objects (synchronously).
        ///
        /// - parameter objectIDs: Identifiers of the objects to delete.
        ///
        @objc public func deleteObjectsSync(withIDs objectIDs: [String]) throws {
            assertNotMainThread()
            self_lock.sync {
                assert(!finished)
                deletedObjectIDs.formUnion(objectIDs)
            }
        }

        /// Delete multiple objects.
        ///
        /// - parameter objectIDs: Identifiers of the objects to delete.
        /// - parameter completionHandler: Completion handler to be notified when the transaction has been updated.
        /// - returns: The corresponding operation.
        ///
        @discardableResult
        @objc public func deleteObjects(withIDs objectIDs: [String], completionHandler: CompletionHandler? = nil) -> Operation {
            let operation = BlockOperation() {
                do {
                    try self.deleteObjectsSync(withIDs: objectIDs)
                    let content: JSONObject = [
                        "objectIDs": objectIDs
                    ]
                    completionHandler?(content, nil)
                } catch let e {
                    completionHandler?(nil, e)
                }
            }
            index.transactionQueue.addOperation(operation)
            return operation
        }

        /// Set the index's settings (synchronously).
        ///
        /// Please refer to our [API documentation](https://www.algolia.com/doc/swift#index-settings) for the list of
        /// supported settings.
        ///
        /// - parameter settings: New settings.
        ///
        @objc public func setSettingsSync(_ settings: JSONObject) throws {
            assertNotMainThread()
            try self_lock.sync {
                assert(!finished)
                settingsFilePath = try writeTmpJSONFile(json: settings)
            }
        }
        
        /// Set the index's settings.
        ///
        /// Please refer to our [API documentation](https://www.algolia.com/doc/swift#index-settings) for the list of
        /// supported settings.
        ///
        /// - parameter settings: New settings.
        /// - parameter completionHandler: Completion handler to be notified when the transaction has been updated.
        /// - returns: The corresponding operation.
        ///
        @discardableResult
        @objc public func setSettings(_ settings: JSONObject, completionHandler: CompletionHandler? = nil) -> Operation {
            let operation = BlockOperation() {
                do {
                    try self.setSettingsSync(settings)
                    completionHandler?([:], nil)
                } catch let e {
                    completionHandler?(nil, e)
                }
            }
            index.transactionQueue.addOperation(operation)
            return operation
        }

        /// Delete the index content without removing settings (synchronously).
        ///
        @objc public func clearIndexSync() throws {
            assertNotMainThread()
            self_lock.sync {
                assert(!finished)
                shouldClearIndex = true
                deletedObjectIDs.removeAll()
                objectFilePaths.removeAll()
            }
        }

        /// Delete the index content without removing settings.
        ///
        /// - parameter completionHandler: Completion handler to be notified when the transaction has been updated.
        /// - returns: The corresponding operation.
        ///
        @discardableResult
        @objc(clearIndex:)
        public func clearIndex(completionHandler: CompletionHandler? = nil) -> Operation {
            let operation = BlockOperation() {
                do {
                    try self.clearIndexSync()
                    completionHandler?([:], nil)
                } catch let e {
                    completionHandler?(nil, e)
                }
            }
            index.transactionQueue.addOperation(operation)
            return operation
        }

        // MARK: Completion
        
        /// Commit the transaction (synchronously).
        ///
        @objc public func commitSync() throws {
            assertNotMainThread()
            try doCommit()
        }
        
        /// Commit the transaction.
        ///
        /// - parameter completionHandler: Completion handler to be notified when the transaction has been committed.
        /// - returns: The corresponding operation.
        ///
        @discardableResult
        @objc(commit:)
        public func commit(completionHandler: CompletionHandler? = nil) -> Operation {
            let operation = BlockOperation() {
                do {
                    try self.doCommit()
                    completionHandler?([:], nil)
                } catch let e {
                    completionHandler?(nil, e)
                }
            }
            index.transactionQueue.addOperation(operation)
            return operation
        }
        
        private func doCommit() throws {
            self_lock.sync {
                assert(!finished)
                finished = true
            }
            try flushObjectsToDisk(force: true)
            var error: Error?
            // Serialize builds with respect to the client's build queue.
            let buildOperation = BlockOperation() {
                let response = OfflineClient.parseResponse(self.index.localIndex.build(settingsFile: self.settingsFilePath, objectFiles: self.objectFilePaths, clearIndex: self.shouldClearIndex, deletedObjectIDs: Array(self.deletedObjectIDs)))
                if response.error != nil {
                    error = response.error
                }
            }
            index.client.offlineBuildQueue.addOperation(buildOperation)
            buildOperation.waitUntilFinished()
            if error != nil {
                throw error!
            }
        }
        
        /// Rollback the transaction (synchronously).
        /// The index will be left untouched.
        ///
        @objc public func rollbackSync() {
            assertNotMainThread()
            doRollback()
        }

        /// Rollback the transaction.
        /// The index will be left untouched.
        ///
        /// - parameter completionHandler: Completion handler to be notified when the transaction has been rolled back.
        /// - returns: The corresponding operation.
        ///
        @discardableResult
        @objc(rollback:)
        public func rollback(completionHandler: CompletionHandler? = nil) -> Operation {
            let operation = BlockOperation() {
                self.doRollback()
                completionHandler?([:], nil)
            }
            index.transactionQueue.addOperation(operation)
            return operation
        }
        
        private func doRollback() {
            self_lock.sync {
                assert(!finished)
                finished = true
            }
            _ = try? FileManager.default.removeItem(atPath: tmpDirPath)
        }

        // MARK: Utils
        
        private func flushObjectsToDisk(force: Bool) throws {
            if force || tmpObjects.count >= WriteTransaction.maxObjectsInMemory {
                let tmpFilePath = try writeTmpJSONFile(json: tmpObjects)
                objectFilePaths.append(tmpFilePath)
                tmpObjects.removeAll()
            }
        }
        
        private func writeTmpJSONFile(json: Any) throws -> String {
            let tmpFilePath = URL(fileURLWithPath: tmpDirPath).appendingPathComponent(NSUUID().uuidString + ".json").path
            guard let stream = OutputStream(toFileAtPath: tmpFilePath, append: false) else {
                throw IOError(description: "Could not open output stream to \(tmpFilePath)")
            }
            stream.open()
            var error: NSError? = nil
            _ = JSONSerialization.writeJSONObject(json, to: stream, options: [], error: &error)
            stream.close()
            guard error == nil else {
                throw error!
            }
            return tmpFilePath
        }
    }
    
    /// Create a new write transaction.
    ///
    @objc public func newTransaction() -> WriteTransaction {
        return WriteTransaction(index: self)
    }
    
    // ----------------------------------------------------------------------
    // MARK: - Manual build
    // ----------------------------------------------------------------------

    /// Build the index from local files.
    /// This method is a shortcut alternative to using write transactions if all of your data is already available as
    /// plain JSON files on disk.
    ///
    /// - parameter settingsFile: Absolute path to the file containing the index settings, in JSON format.
    /// - parameter objectFiles: Absolute path(s) to the file(s) containing the objects. Each file must contain an
    ///   array of objects, in JSON format.
    /// - parameter completionHandler: An optional completion handler to be notified when the build has finished.
    /// - returns: A cancellable operation.
    ///
    /// + Note: Cancelling the request does *not* cancel the build; it merely prevents the completion handler from
    ///    being called.
    ///
    @objc @discardableResult
    public func build(settingsFile: String, objectFiles: [String], completionHandler: CompletionHandler? = nil) -> Operation {
        let operation = AsyncBlockOperation(completionHandler: completionHandler) {
            return self._build(settingsFile: settingsFile, objectFiles: objectFiles)
        }
        operation.completionQueue = client.completionQueue
        client.offlineBuildQueue.addOperation(operation)
        return operation
    }
    
    /// Build the index from local files (synchronously).
    ///
    /// + Warning: This method is synchronous: it blocks until completion.
    ///
    /// - parameter settingsFile: Absolute path to the file containing the index settings, in JSON format.
    /// - parameter objectFiles: Absolute path(s) to the file(s) containing the objects. Each file must contain an
    ///   array of objects, in JSON format.
    ///
    private func _build(settingsFile: String, objectFiles: [String]) -> (JSONObject?, Error?) {
        assert(!Thread.isMainThread) // make sure it's run in the background
        assert(OperationQueue.current == client.offlineBuildQueue) // ensure serial calls

        // Build the index.
        let response = self.localIndex.build(settingsFile: settingsFile, objectFiles: objectFiles, clearIndex: true, deletedObjectIDs: nil)
        return OfflineClient.parseResponse(response)
    }

    // ----------------------------------------------------------------------
    // MARK: - Helpers
    // ----------------------------------------------------------------------
    
    /// Delete all objects matching a query.
    ///
    /// + Warning: This method will assert/crash if no transaction is currently open.
    ///
    /// - parameter query: The query that objects to delete must match.
    /// - parameter completionHandler: Completion handler to be notified of the request's outcome.
    /// - returns: A cancellable operation.
    ///
    @discardableResult
    @objc public func deleteByQuery(_ query: Query, completionHandler: CompletionHandler? = nil) -> Operation {
        let transaction = newTransaction()
        let operation = BlockOperation() {
            var content: JSONObject?
            var error: Error?
            do {
                let deletedObjectIDs = try self.deleteByQuerySync(query, transaction: transaction)
                try transaction.commitSync()
                content = [
                    "objectIDs": deletedObjectIDs,
                    "updatedAt": Date().iso8601,
                    "taskID": transaction.identifier
                ]
            } catch let e {
                error = e
            }
            self.callCompletionHandler(completionHandler, content: content, error: error)
        }
        transactionQueue.addOperation(operation)
        return operation
    }
    
    /// Delete all objects matching a query (synchronously).
    ///
    /// + Warning: This method will assert/crash if no transaction is currently open.
    ///
    /// + Warning: This method must not be called from the main thread.
    ///
    /// - parameter query: The query that objects to delete must match.
    /// - returns: List of deleted object IDs.
    ///
    @discardableResult
    @objc public func deleteByQuerySync(_ query: Query, transaction: WriteTransaction) throws -> [String] {
        assertNotMainThread()
        let browseQuery = Query(copy: query)
        browseQuery.attributesToRetrieve = ["objectID"]
        let queryParameters = browseQuery.build()
        
        // Gather object IDs to delete.
        var objectIDsToDelete: [String] = []
        var hasMore = true
        while hasMore {
            let (content, error) = OfflineClient.parseResponse(self.localIndex.browse(queryParameters))
            guard let returnedContent = content else {
                throw error!
            }
            guard let hits = content!["hits"] as? [JSONObject] else {
                throw InvalidJSONError(description: "No hits returned when browsing")
            }
            // Retrieve object IDs.
            for hit in hits {
                if let objectID = hit["objectID"] as? String {
                    objectIDsToDelete.append(objectID)
                }
            }
            hasMore = returnedContent["cursor"] != nil
        }
        
        // Delete objects.
        try transaction.deleteObjectsSync(withIDs: objectIDsToDelete)
        return objectIDsToDelete
    }
    
    /// Perform a search with disjunctive facets, generating as many queries as number of disjunctive facets (helper).
    ///
    /// - parameter query: The query.
    /// - parameter disjunctiveFacets: List of disjunctive facets.
    /// - parameter refinements: The current refinements, mapping facet names to a list of values.
    /// - parameter completionHandler: Completion handler to be notified of the request's outcome.
    /// - returns: A cancellable operation.
    ///
    @discardableResult
    @objc public func searchDisjunctiveFaceting(_ query: Query, disjunctiveFacets: [String], refinements: [String: [String]], requestOptions: RequestOptions? = nil, completionHandler: @escaping CompletionHandler) -> Operation {
        return DisjunctiveFaceting(multipleQuerier: { (queries, completionHandler) in
            return self.multipleQueries(queries, completionHandler: completionHandler)
        }).searchDisjunctiveFaceting(query, disjunctiveFacets: disjunctiveFacets, refinements: refinements, completionHandler: completionHandler)
    }
    
    @objc(searchDisjunctiveFaceting:disjunctiveFacets:refinements:completionHandler:)
    @discardableResult public func z_objc_searchDisjunctiveFaceting(_ query: Query, disjunctiveFacets: [String], refinements: [String: [String]], completionHandler: @escaping CompletionHandler) -> Operation {
        return self.searchDisjunctiveFaceting(query, disjunctiveFacets: disjunctiveFacets, refinements: refinements, completionHandler: completionHandler)
    }
        
    // ----------------------------------------------------------------------
    // MARK: - Utils
    // ----------------------------------------------------------------------

    /// Call a completion handler on the main queue.
    ///
    /// - parameter completionHandler: The completion handler to call. If `nil`, this function does nothing.
    /// - parameter content: The content to pass as a first argument to the completion handler.
    /// - parameter error: The error to pass as a second argument to the completion handler.
    ///
    private func callCompletionHandler(_ completionHandler: CompletionHandler?, content: JSONObject?, error: Error?) {
        // TODO: Factorize with `OfflineClient`.
        if let completionHandler = completionHandler {
            client.completionQueue!.addOperation {
                completionHandler(content, error)
            }
        }
    }
    
    private func nextTransactionSeqNo() -> Int {
        var seqNo: Int = 0
        transactionSeqNo_lock.sync {
            self.transactionSeqNo += 1
            seqNo = self.transactionSeqNo
        }
        return seqNo
    }
}

fileprivate func assertNotMainThread() {
    assert(!Thread.isMainThread, "Synchronous methods should not be called from the main thread")
}
