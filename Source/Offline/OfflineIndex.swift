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
/// - **Slave indices** are not supported.
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
/// ## Writing
///
/// Updating an index involves rebuilding it, which is an expensive and potentially lengthy operation. Therefore, all
/// updates must be wrapped inside a **transaction**.
///
/// + Warning: You cannot have several parallel transactions on a given index.
///
/// The flow is as follows:
///
/// - Initiate a transaction by calling `beginTransaction()`.
///
/// - Populate the transaction:
///
///     - Call the asynchronous methods similar to those in the `Index` class (like `saveObjects` or `deleteObjects`).
///       Each method requires you to provide a completion handler. You must wait until the completion handler is
///       called before chaining with other write methods, or committing or rolling back the transaction.
///
/// - Either commit (`commit()`) or rollback (`rollback()`) the transaction.
///
/// ## Reading
///
/// Read operations behave identically as on online indices.
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
    lazy var localIndex: LocalIndex = LocalIndex(dataDir: self.client.rootDataDir, appID: self.client.appID, indexName: self.name)

    /// Queue used to run transaction bodies (but not the build).
    private let transactionQueue: OperationQueue
    
    /// Serial number for transactions.
    private var transactionSeqNo: Int = 0

    /// Dispatch queue used to serialize access to `transactionSeqNo`.
    private let transactionSeqNo_lock = DispatchQueue(label: "OfflineIndex.transactionSeqNo.lock")
    
    /// The current transaction, or `nil` if no transaction is currently open.
    private var transaction: WriteTransaction?

    // MARK: - Initialization
    
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
    }
    
    override public var description: String {
        get {
            // TODO: Move to a higher level.
            return "Index{\"\(name)\"}"
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
    
    // MARK: - Read operations
    
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
    /// - parameter completionHandler: Completion handler to be notified of the request's outcome.
    /// - returns: A cancellable operation.
    ///
    @discardableResult
    @objc public func getObject(withID objectID: String, attributesToRetrieve: [String]?, completionHandler: @escaping CompletionHandler) -> Operation {
        let operation = BlockOperation() {
            let (content, error) = self.getObjectSync(withID: objectID, attributesToRetrieve: attributesToRetrieve)
            self.callCompletionHandler(completionHandler, content: content, error: error)
        }
        client.searchQueue.addOperation(operation)
        return operation
    }
    
    /// Get an object from this index (synchronous version).
    ///
    /// - parameter objectID: Identifier of the object to retrieve.
    /// - returns: A mutually exclusive (content, error) pair.
    ///
    private func getObjectSync(withID objectID: String, attributesToRetrieve: [String]?) -> APIResponse {
        var content: JSONObject?
        var error: Error?
        let query = Query()
        query.attributesToRetrieve = attributesToRetrieve
        let searchResults = self.localIndex.getObjects(withIDs: [objectID], parameters: query.build())
        (content, error) = OfflineClient.parseSearchResults(searchResults)
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
        let operation = BlockOperation() {
            let (content, error) = self.getObjectsSync(withIDs: objectIDs)
            self.callCompletionHandler(completionHandler, content: content, error: error)
        }
        client.searchQueue.addOperation(operation)
        return operation
    }
    
    /// Get several objects from this index (synchronous version).
    ///
    /// - parameter objectIDs: Identifiers of objects to retrieve.
    /// - returns: A mutually exclusive (content, error) pair.
    ///
    private func getObjectsSync(withIDs objectIDs: [String]) -> APIResponse {
        let searchResults = self.localIndex.getObjects(withIDs: objectIDs, parameters: nil)
        return OfflineClient.parseSearchResults(searchResults)
    }
    
    /// Search this index.
    ///
    /// - parameter query: Search parameters.
    /// - parameter completionHandler: Completion handler to be notified of the request's outcome.
    /// - returns: A cancellable operation.
    ///
    @discardableResult
    @objc public func search(_ query: Query, completionHandler: @escaping CompletionHandler) -> Operation {
        let operation = BlockOperation() {
            let (content, error) = self.searchSync(Query(copy: query))
            self.callCompletionHandler(completionHandler, content: content, error: error)
        }
        client.searchQueue.addOperation(operation)
        return operation
    }

    /// Search this index (synchronous version).
    ///
    /// - parameter query: Search parameters.
    /// - returns: A mutually exclusive (content, error) pair.
    ///
    private func searchSync(_ query: Query) -> APIResponse {
        let searchResults = self.localIndex.search(query.build())
        return OfflineClient.parseSearchResults(searchResults)
    }

    /// Get this index's settings.
    ///
    /// - parameter completionHandler: Completion handler to be notified of the request's outcome.
    /// - returns: A cancellable operation.
    ///
    @discardableResult
    @objc public func getSettings(completionHandler: @escaping CompletionHandler) -> Operation {
        let operation = BlockOperation() {
            let (content, error) = self.getSettingsSync()
            self.callCompletionHandler(completionHandler, content: content, error: error)
        }
        client.searchQueue.addOperation(operation)
        return operation
    }
    
    /// Get this index's settings (synchronous version).
    ///
    /// - returns: A mutually exclusive (content, error) pair.
    ///
    private func getSettingsSync() -> APIResponse {
        let searchResults = self.localIndex.getSettings()
        return OfflineClient.parseSearchResults(searchResults)
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
        client.searchQueue.addOperation(operation)
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
        return OfflineClient.parseSearchResults(searchResults)
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
        client.searchQueue.addOperation(operation)
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
        return OfflineClient.parseSearchResults(searchResults)
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
        client.searchQueue.addOperation(operation)
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
    
    // MARK: - Write operations
    
    /// A transaction to update the index.
    ///
    /// A transaction gathers all the operations that will be performed when the transaction is committed.
    /// Its purpose is twofold:
    ///
    /// 1. Avoid rebuilding the index for every individual operation, which would be astonishingly costly.
    /// 2. Avoid keeping all the necessary data in memory, e.g. by flushing added objects to temporary files on disk.
    ///
    /// A transaction can be created by calling `OfflineIndex.newTransaction()`.
    ///
    /// Alternatively, you can call `OfflineIndex.update(_:)` with a block. A transaction will be created for you and
    /// committed at the end of your block.
    ///
    private class WriteTransaction: NSObject {
        /// The index on which this transaction will operate.
        let index: OfflineIndex
        
        /// This transaction's ID.
        /// Unique within the context of `index`.
        /// *Not* guaranteed to be unique across all indices.
        ///
        let id: Int
        
        /// Whether this transaction has completed (committed or rolled back).
        private var finished: Bool = false

        /// Path to the temporary file containing the new settings.
        /// If `nil`, settings will be unchanged by this transaction.
        private var settingsFilePath: String? = nil
        
        /// Path to the temporary files containing the objects that will be added/updated by this transaction.
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
        
        // MARK: Constants
        
        /// Maximum number of objects to keep in memory before flushing to disk.
        private static let maxObjectsInMemory = 100
        
        // MARK: Initialization
        
        init(index: OfflineIndex) {
            self.index = index
            self.id = index.nextTransactionSeqNo()
            // TODO: Factorize into `OfflineClient`
            let globalTmpDirPath = URL(fileURLWithPath: NSTemporaryDirectory()).appendingPathComponent("algolia").path
            self.tmpDirPath = URL(fileURLWithPath: globalTmpDirPath).appendingPathComponent(NSUUID().uuidString).path
            super.init()
            
            // Create temporary directory.
            try! FileManager.default.createDirectory(atPath: tmpDirPath, withIntermediateDirectories: true, attributes: nil)
        }
        
        deinit {
            assert(finished, "A transaction was never committed nor rolled back")
            if !finished {
                rollback()
            }
        }
        
        // MARK: Populating
        
        /// Update an object.
        ///
        /// - parameter object: New version of the object to update. Must contain an `objectID` attribute.
        ///
        func saveObject(_ object: JSONObject) throws {
            assert(!finished)
            assert(object["objectID"] != nil, "Objects must contain an `objectID` attribute")
            tmpObjects.append(object)
            try flushObjectsToDisk(force: false)
        }
        
        /// Update several objects.
        ///
        /// - parameter objects: New versions of the objects to update. Each one must contain an `objectID` attribute.
        ///
        func saveObjects(_ objects: [JSONObject]) throws {
            assert(!finished)
            tmpObjects.append(contentsOf: objects)
            try flushObjectsToDisk(force: false)
        }
        
        /// Delete an object.
        ///
        /// - parameter objectID: Identifier of the object to delete.
        ///
        func deleteObject(withID objectID: String) throws {
            assert(!finished)
            deletedObjectIDs.insert(objectID)
        }
        
        /// Delete several objects.
        ///
        /// - parameter objectIDs: Identifiers of the objects to delete.
        ///
        func deleteObjects(withIDs objectIDs: [String]) throws {
            assert(!finished)
            deletedObjectIDs.formUnion(objectIDs)
        }
        
        /// Set the index's settings.
        ///
        /// Please refer to our [API documentation](https://www.algolia.com/doc/swift#index-settings) for the list of
        /// supported settings.
        ///
        /// - parameter settings: New settings.
        ///
        func setSettings(_ settings: JSONObject) throws {
            assert(!finished)
            settingsFilePath = try writeTmpJSONFile(json: settings)
        }
        
        /// Delete the index content without removing settings.
        ///
        func clearIndex() throws {
            assert(!finished)
            shouldClearIndex = true
            deletedObjectIDs.removeAll()
            objectFilePaths.removeAll()
        }
        
        // MARK: Completion
        
        /// Commit the transaction (synchronously).
        ///
        /// + Warning: This method blocks until completion. Must not be called from the main thread.
        ///
        func commit() throws {
            assert(!Thread.isMainThread)
            // TODO: Would be easier with dispatch queue. See if we can use underlyingQueue (drop iOS 7 support).
            var error: Error?
            let operation = BlockOperation() {
                do {
                    try self._commit()
                } catch let e {
                    error = e
                }
            }
            index.client.buildQueue.addOperation(operation)
            operation.waitUntilFinished()
            if error != nil {
                throw error!
            }
        }
        
        /// Commit the transaction (asynchronously).
        func commit(completionHandler: CompletionHandler?) {
            // TODO: Not sure it's needed.
            let operation = BlockOperation() {
                do {
                    try self._commit()
                    completionHandler?([:], nil)
                } catch let e {
                    completionHandler?(nil, e)
                }
            }
            index.client.buildQueue.addOperation(operation)
        }
        
        private func _commit() throws {
            assert(!finished)
            try flushObjectsToDisk(force: true)
            let statusCode = Int(index.localIndex.build(settingsFile: settingsFilePath, objectFiles: objectFilePaths, clearIndex: shouldClearIndex, deletedObjectIDs: Array(deletedObjectIDs)))
            if statusCode != StatusCode.ok.rawValue {
                throw HTTPError(statusCode: statusCode)
            }
            finished = true
        }
        
        /// Rollback the transaction.
        /// The index will be left untouched.
        ///
        func rollback() {
            _ = try? FileManager.default.removeItem(atPath: tmpDirPath)
            finished = true
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
    public func beginTransaction() {
        assert(transaction == nil, "A transaction is already open")
        if transaction == nil {
            transaction = WriteTransaction(index: self)
        }
    }
    
    public func commitTransaction(completionHandler: @escaping CompletionHandler) {
        assert(transaction != nil, "No transaction is open")
        transaction!.commit(completionHandler: completionHandler)
        transaction = nil
    }
    
    public func rollbackTransaction() {
        assert(transaction != nil, "No transaction is open")
        transaction!.rollback()
        transaction = nil
    }
    
    /// Add an object to this index.
    ///
    /// - parameter object: The object to add.
    /// - parameter completionHandler: Completion handler to be notified of the request's outcome.
    /// - returns: A cancellable operation.
    ///
    @discardableResult
    @objc public func addObject(_ object: JSONObject, completionHandler: CompletionHandler? = nil) -> Operation {
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
    @discardableResult
    @objc public func addObject(_ object: JSONObject, withID objectID: String, completionHandler: CompletionHandler? = nil) -> Operation {
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
    @discardableResult
    @objc public func addObjects(_ objects: [JSONObject], completionHandler: CompletionHandler? = nil) -> Operation {
        return saveObjects(objects, completionHandler: completionHandler)
    }
    
    /// Delete an object from this index.
    ///
    /// - parameter objectID: Identifier of object to delete.
    /// - parameter completionHandler: Completion handler to be notified of the request's outcome.
    /// - returns: A cancellable operation.
    ///
    @discardableResult
    @objc public func deleteObject(withID objectID: String, completionHandler: CompletionHandler? = nil) -> Operation {
        assert(transaction != nil, "Write operations need to be wrapped inside a transaction")
        let operation = BlockOperation() {
            let (content, error) = self.deleteObjectSync(withID: objectID)
            self.callCompletionHandler(completionHandler, content: content, error: error)
        }
        transactionQueue.addOperation(operation)
        return operation
    }
    
    /// Delete an object from this index (synchronous version).
    ///
    /// + Warning: It is the caller's responsibility to ensure proper serialization of index write operations.
    ///
    /// - parameter objectID: Identifier of object to delete.
    /// - returns: A mutually exclusive (content, error) pair.
    ///
    private func deleteObjectSync(withID objectID: String) -> APIResponse {
        let (content, error) = deleteObjectsSync(withIDs: [objectID])
        if content != nil {
            let newContent: JSONObject = [
                "deletedAt": Date().iso8601
            ]
            return (newContent, nil)
        }
        return (nil, error)
    }
    
    /// Delete several objects from this index.
    ///
    /// - parameter objectIDs: Identifiers of objects to delete.
    /// - parameter completionHandler: Completion handler to be notified of the request's outcome.
    /// - returns: A cancellable operation.
    ///
    @discardableResult
    @objc public func deleteObjects(withIDs objectIDs: [String], completionHandler: CompletionHandler? = nil) -> Operation {
        assert(transaction != nil, "Write operations need to be wrapped inside a transaction")
        let operation = BlockOperation() {
            let (content, error) = self.deleteObjectsSync(withIDs: objectIDs)
            self.callCompletionHandler(completionHandler, content: content, error: error)
        }
        transactionQueue.addOperation(operation)
        return operation
    }
    
    /// Delete several objects from this index (synchronous version).
    ///
    /// + Warning: It is the caller's responsibility to ensure proper serialization of index write operations.
    ///
    /// - parameter objectIDs: Identifiers of objects to delete.
    /// - returns: A mutually exclusive (content, error) pair.
    ///
    private func deleteObjectsSync(withIDs objectIDs: [String]) -> APIResponse {
        assert(!Thread.isMainThread, "Synchronous methods should not be called from the main thread")
        var content: JSONObject?
        var error: NSError?
        do {
            try transaction!.deleteObjects(withIDs: objectIDs)
            content = [
                "objectIDs": objectIDs,
                "taskID": transaction!.id
            ]
        } catch let e {
            error = e as NSError
        }
        return (content, error)
    }
    
    /// Update an object.
    ///
    /// - parameter object: New version of the object to update. Must contain an `objectID` attribute.
    /// - parameter completionHandler: Completion handler to be notified of the request's outcome.
    /// - returns: A cancellable operation.
    ///
    @discardableResult
    @objc public func saveObject(_ object: JSONObject, completionHandler: CompletionHandler? = nil) -> Operation {
        assert(transaction != nil, "Write operations need to be wrapped inside a transaction")
        let operation = BlockOperation() {
            let (content, error) = self.saveObjectSync(object)
            self.callCompletionHandler(completionHandler, content: content, error: error)
        }
        transactionQueue.addOperation(operation)
        return operation
    }
    
    /// Update an object (synchronous version).
    ///
    /// - parameter object: New version of the object to update. Must contain an `objectID` attribute.
    /// - returns: A mutually exclusive (content, error) pair.
    ///
    private func saveObjectSync(_ object: JSONObject) -> APIResponse {
        let (content, error) = saveObjectsSync([object])
        if let content = content {
            let newContent: JSONObject = [
                "updatedAt": Date().iso8601,
                "objectID": (content["objectIDs"] as! [Any])[0], // should always succeed
            ]
            return (newContent, nil)
        } else {
            return (nil, error)
        }
    }
    
    /// Update several objects.
    ///
    /// - parameter objects: New versions of the objects to update. Each one must contain an `objectID` attribute.
    /// - parameter completionHandler: Completion handler to be notified of the request's outcome.
    /// - returns: A cancellable operation.
    ///
    @discardableResult
    @objc public func saveObjects(_ objects: [JSONObject], completionHandler: CompletionHandler? = nil) -> Operation {
        assert(transaction != nil, "Write operations need to be wrapped inside a transaction")
        let operation = BlockOperation() {
            let (content, error) = self.saveObjectsSync(objects)
            self.callCompletionHandler(completionHandler, content: content, error: error)
        }
        client.buildQueue.addOperation(operation)
        return operation
    }
    
    /// Update several objects (synchronous version).
    ///
    /// + Warning: It is the caller's responsibility to ensure proper serialization of index write operations.
    ///
    /// - parameter objects: New versions of the objects to update. Each one must contain an `objectID` attribute.
    /// - returns: A mutually exclusive (content, error) pair.
    ///
    private func saveObjectsSync(_ objects: [JSONObject]) -> APIResponse {
        assert(!Thread.isMainThread, "Synchronous methods should not be called from the main thread")
        var content: JSONObject?
        var error: NSError?
        do {
            let objectIDs = try objects.map({ (object: JSONObject) -> Any in
                guard let objectID = object["objectID"] else {
                    throw InvalidJSONError(description: "Object missing mandatory `objectID` attribute")
                }
                return objectID
            })
            try transaction!.saveObjects(objects)
            content = [
                "objectIDs": objectIDs,
                "taskID": transaction!.id
            ]
        } catch let e as NSError {
            error = e
        }
        return (content, error)
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
    @discardableResult
    @objc public func setSettings(_ settings: JSONObject, completionHandler: CompletionHandler? = nil) -> Operation {
        assert(transaction != nil, "Write operations need to be wrapped inside a transaction")
        let operation = BlockOperation() {
            let (content, error) = self.setSettingsSync(settings)
            self.callCompletionHandler(completionHandler, content: content, error: error)
        }
        transactionQueue.addOperation(operation)
        return operation
    }
    
    /// Set this index's settings (synchronous version).
    ///
    /// Please refer to our [API documentation](https://www.algolia.com/doc/swift#index-settings) for the list of
    /// supported settings.
    ///
    /// + Warning: It is the caller's responsibility to ensure proper serialization of index write operations.
    ///
    /// - parameter settings: New settings.
    /// - returns: A mutually exclusive (content, error) pair.
    ///
    private func setSettingsSync(_ settings: JSONObject) -> APIResponse {
        assert(!Thread.isMainThread, "Synchronous methods should not be called from the main thread")
        var content: JSONObject?
        var error: NSError?
        do {
            try transaction!.setSettings(settings)
            content = [
                "updatedAt": Date().iso8601,
                "taskID": transaction!.id
            ]
        } catch let e as NSError {
            error = e
        }
        return (content, error)
    }
    
    /// Delete the index content without removing settings.
    ///
    /// - parameter completionHandler: Completion handler to be notified of the request's outcome.
    /// - returns: A cancellable operation.
    ///
    @discardableResult
    @objc public func clearIndex(completionHandler: CompletionHandler? = nil) -> Operation {
        assert(transaction != nil, "Write operations need to be wrapped inside a transaction")
        let operation = BlockOperation() {
            let (content, error) = self.clearIndexSync()
            self.callCompletionHandler(completionHandler, content: content, error: error)
        }
        transactionQueue.addOperation(operation)
        return operation
    }
    
    /// Delete the index content without removing settings.
    ///
    /// - returns: A mutually exclusive (content, error) pair.
    ///
    private func clearIndexSync() -> APIResponse {
        assert(!Thread.isMainThread, "Synchronous methods should not be called from the main thread")
        var content: JSONObject?
        var error: NSError?
        do {
            try transaction!.clearIndex()
            content = [
                "updatedAt": Date().iso8601,
                "taskID": transaction!.id
            ]
        } catch let e as NSError {
            error = e
        }
        return (content, error)
    }
    
    // MARK: - Helpers
    
    /// Delete all objects matching a query.
    ///
    /// - parameter query: The query that objects to delete must match.
    /// - parameter completionHandler: Completion handler to be notified of the request's outcome.
    /// - returns: A cancellable operation.
    ///
    @discardableResult
    @objc public func deleteByQuery(_ query: Query, completionHandler: CompletionHandler? = nil) -> Operation {
        assert(transaction != nil, "Write operations need to be wrapped inside a transaction")
        let operation = BlockOperation() {
            let (content, error) = self.deleteByQuerySync(query)
            self.callCompletionHandler(completionHandler, content: content, error: error)
        }
        client.buildQueue.addOperation(operation)
        return operation
    }
    
    /// Delete all objects matching a query (synchronously).
    ///
    /// - parameter query: The query that objects to delete must match.
    /// - returns: A mutually exclusive (content, error) pair.
    ///
    private func deleteByQuerySync(_ query: Query) -> APIResponse {
        assert(!Thread.isMainThread, "Synchronous methods should not be called from the main thread")
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
            guard let hits = content!["hits"] as? [JSONObject] else {
                return (nil, InvalidJSONError(description: "No hits returned when browsing"))
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
        return deleteObjectsSync(withIDs: objectIDsToDelete)
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
    @objc public func searchDisjunctiveFaceting(query: Query, disjunctiveFacets: [String], refinements: [String: [String]], completionHandler: @escaping CompletionHandler) -> Operation {
        return DisjunctiveFaceting(multipleQuerier: { (queries, completionHandler) in
            return self.multipleQueries(queries, completionHandler: completionHandler)
        }).searchDisjunctiveFaceting(query, disjunctiveFacets: disjunctiveFacets, refinements: refinements, completionHandler: completionHandler)
    }
    
    // MARK: - Utils
    
    /// Call a completion handler on the main queue.
    ///
    /// - parameter completionHandler: The completion handler to call. If `nil`, this function does nothing.
    /// - parameter content: The content to pass as a first argument to the completion handler.
    /// - parameter error: The error to pass as a second argument to the completion handler.
    ///
    private func callCompletionHandler(_ completionHandler: CompletionHandler?, content: JSONObject?, error: Error?) {
        // TODO: Factorize with `OfflineClient`.
        if let completionHandler = completionHandler {
            DispatchQueue.main.async {
                completionHandler(content, error)
            }
        }
    }
}
