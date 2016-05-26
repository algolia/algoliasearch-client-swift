//
//  Copyright (c) 2015-2016 Algolia
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


/// A data selection query.
@objc public class DataSelectionQuery: NSObject {
    @objc public let query: Query
    @objc public let maxObjects: Int
    
    @objc public init(query: Query, maxObjects: Int) {
        self.query = query
        self.maxObjects = maxObjects
    }
    
    override public func isEqual(object: AnyObject?) -> Bool {
        guard let rhs = object as? DataSelectionQuery else {
            return false
        }
        return self.query == rhs.query && self.maxObjects == rhs.maxObjects
    }
}


/// An online index that can also be mirrored locally.
///
/// When created, an instance of this class has its <code>mirrored</code> flag set to false, and behaves like a normal,
/// online `Index`. When the `mirrored` flag is set to true, the index becomes capable of acting upon local data.
///
/// It is a programming error to call methods acting on the local data when `mirrored` is false. Doing so
/// will result in an assertion error being raised.
///
/// Native resources are lazily instantiated at the first method call requiring them. They are released when the
/// object is released. Although the client guards against concurrent accesses, it is strongly discouraged
/// to create more than one `MirroredIndex` instance pointing to the same index, as that would duplicate
/// native resources.
///
/// NOTE: Requires Algolia's SDK. The `OfflineClient.enableOfflineMode()` method must be called with a valid license
/// key prior to calling any offline-related method.
///
/// ### Preventive offline searches
///
/// This behavior is optional and disabled by default. It may be enabled by setting `preventiveOfflineSearch` to `true`.
///
/// When the index is mirrored, it may launch a "preventive" request to the offline mirror for every online search
/// request. **This may result in the completion handler being called twice:** a first time with the offline results,
/// and a second time with the online results.
///
/// To avoid wasting CPU when the network connection is good, the offline request is only launched after a certain
/// delay. This delay can be adjusted by setting `preventiveOfflineSearchDelay`. The default is
/// `DefaultPreventiveOfflineSearchDelay`. If the online request finishes with a definitive result (i.e. success or
/// application error) before the offline request has finished (or even been launched), the offline request will be
/// cancelled (or not be launched at all).
///
@objc public class MirroredIndex : Index {
    
    // MARK: Constants
    
    /// Notification sent when the sync has started.
    @objc public static let SyncDidStartNotification = "AlgoliaSearch.MirroredIndex.SyncDidStartNotification"
    
    /// Notification sent when the sync has finished.
    @objc public static let SyncDidFinishNotification = "AlgoliaSearch.MirroredIndex.SyncDidFinishNotification"
    
    /// Notification user info key used to pass the error, when an error occurred during the sync.
    @objc public static let SyncErrorKey = "AlgoliaSearch.MirroredIndex.SyncErrorKey"
    
    /// Default minimum delay between two syncs.
    @objc public static let DefaultDelayBetweenSyncs: NSTimeInterval = 60 * 60 * 24 // 1 day

    /// Key used to indicate the origin of results in the returned JSON.
    @objc public static let JSONKeyOrigin = "origin"
    
    /// Value for `JSONKeyOrigin` indicating that the results come from the local mirror.
    @objc public static let JSONValueOriginLocal = "local"
    
    /// Value for `JSONKeyOrigin` indicating that the results come from the online API.
    @objc public static let JSONValueOriginRemote = "remote"

    /// Default delay before preventive offline search.
    @objc public static let DefaultPreventiveOfflineSearchDelay: NSTimeInterval = 0.2

    // ----------------------------------------------------------------------
    // MARK: Properties
    // ----------------------------------------------------------------------
    
    /// Getter returning covariant-typed client.
    // IMPLEMENTATION NOTE: Could not find a way to implement proper covariant properties in Swift.
    @objc public var offlineClient: OfflineClient {
        return self.client as! OfflineClient
    }
    
    /// The local index mirroring this remote index (lazy instantiated, only if mirroring is activated).
    lazy var localIndex: ASLocalIndex? = ASLocalIndex(dataDir: self.offlineClient.rootDataDir, appID: self.client.appID, indexName: self.indexName)
    
    /// The mirrored index settings.
    let mirrorSettings = MirrorSettings()
    
    /// Whether the index is mirrored locally. Default = false.
    @objc public var mirrored: Bool = false {
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
    @objc public var dataSelectionQueries: [DataSelectionQuery] {
        get {
            return mirrorSettings.queries
        }
        set {
            if (mirrorSettings.queries != newValue) {
                mirrorSettings.queries = newValue
                mirrorSettings.queriesModificationDate = NSDate()
                mirrorSettings.save(mirrorSettingsFilePath)
            }
        }
    }
    
    /// Minimum delay between two syncs.
    @objc public var delayBetweenSyncs: NSTimeInterval = DefaultDelayBetweenSyncs
    
    /// Error encountered by the current/last sync (if any).
    @objc public private(set) var syncError : NSError?

    /// Whether to launch a preventive offline search for every online search.
    /// Only valid when the index is mirrored.
    @objc public var preventiveOfflineSearch: Bool = false
    
    /// The delay before a preventive offline search is launched.
    @objc public var preventiveOfflineSearchDelay: NSTimeInterval = MirroredIndex.DefaultPreventiveOfflineSearchDelay

    // ----------------------------------------------------------------------
    // MARK: - Init
    // ----------------------------------------------------------------------
    
    @objc public override init(client: Client, indexName: String) {
        assert(client is OfflineClient);
        super.init(client: client, indexName: indexName)
    }
    
    // ----------------------------------------------------------------------
    // MARK: - Sync
    // ----------------------------------------------------------------------

    /// Syncing indicator.
    /// NOTE: To prevent concurrent access to this variable, we always access it from the build (serial) queue.
    private var syncing: Bool = false
    
    /// Path to the temporary directory for the current sync.
    private var tmpDir : String!
    
    /// The path to the settings file.
    private var settingsFilePath: String!
    
    /// Paths to object files/
    private var objectsFilePaths: [String]!
    
    /// The current object file index. Object files are named `${i}.json`, where `i` is automatically incremented.
    private var objectFileIndex = 0
    
    /// The operation to build the index.
    /// NOTE: We need to store it because its dependencies are modified dynamically.
    private var buildIndexOperation: NSOperation!
    
    /// Path to the persistent mirror settings.
    private var mirrorSettingsFilePath: String {
        get { return "\(self.indexDataDir)/mirror.plist" }
    }
    
    /// Path to this index's offline data.
    private var indexDataDir: String {
        get { return "\(self.offlineClient.rootDataDir)/\(self.client.appID)/\(self.indexName)" }
    }
    
    /// Timeout for data synchronization queries.
    /// There is no need to use a too short timeout in this case: we don't need real-time performance, so failing
    /// too soon would only increase the likeliness of a failure.
    private let SYNC_TIMEOUT: NSTimeInterval = 30

    /// Add a data selection query to the local mirror.
    /// The query is not run immediately. It will be run during the subsequent refreshes.
    /// @pre The index must have been marked as mirrored.
    @objc public func addDataSelectionQuery(query: DataSelectionQuery) {
        assert(mirrored);
        mirrorSettings.queries.append(query)
        mirrorSettings.queriesModificationDate = NSDate()
        mirrorSettings.save(self.mirrorSettingsFilePath)
    }
    
    /// Add any number of data selection queries to the local mirror.
    /// The query is not run immediately. It will be run during the subsequent refreshes.
    /// @pre The index must have been marked as mirrored.
    @objc public func addDataSelectionQueries(queries: [DataSelectionQuery]) {
        assert(mirrored);
        mirrorSettings.queries.appendContentsOf(queries)
        mirrorSettings.queriesModificationDate = NSDate()
        mirrorSettings.save(self.mirrorSettingsFilePath)
    }

    /// Launch a sync.
    /// This unconditionally launches a sync, unless one is already running.
    ///
    @objc public func sync() {
        offlineClient.buildQueue.addOperationWithBlock() {
            self._sync()
        }
    }

    /// Launch a sync if needed.
    /// This takes into account the delay between syncs.
    ///
    @objc public func syncIfNeeded() {
        if self.isSyncDelayExpired() || self.isMirrorSettingsDirty() {
            offlineClient.buildQueue.addOperationWithBlock() {
                self._sync()
            }
        }
    }
    
    private func isSyncDelayExpired() -> Bool {
        let currentDate = NSDate()
        return currentDate.timeIntervalSinceDate(self.mirrorSettings.lastSyncDate) > self.delayBetweenSyncs
    }
    
    private func isMirrorSettingsDirty() -> Bool {
        return self.mirrorSettings.queriesModificationDate.compare(self.mirrorSettings.lastSyncDate) == .OrderedDescending
    }
    
    /// Refresh the local mirror.
    ///
    /// WARNING: Calls to this method must be synchronized by the caller.
    ///
    private func _sync() {
        assert(!NSThread.isMainThread()) // make sure it's run in the background
        assert(NSOperationQueue.currentQueue() == offlineClient.buildQueue) // ensure serial calls
        assert(self.mirrored, "Mirroring not activated on this index")
        assert(!self.dataSelectionQueries.isEmpty)

        // If already syncing, abort.
        if syncing {
            return
        }
        syncing = true

        // Notify observers.
        dispatch_async(dispatch_get_main_queue()) {
            NSNotificationCenter.defaultCenter().postNotificationName(MirroredIndex.SyncDidStartNotification, object: self)
        }

        // Create temporary directory.
        do {
            tmpDir = NSTemporaryDirectory() + "/algolia/" + NSUUID().UUIDString
            try NSFileManager.defaultManager().createDirectoryAtPath(tmpDir, withIntermediateDirectories: true, attributes: nil)
        } catch _ {
            NSLog("ERROR: Could not create temporary directory '%@'", tmpDir)
        }
        
        // NOTE: We use `NSOperation`s to handle dependencies between tasks.
        syncError = nil
        
        // Task: Download index settings.
        // TODO: Factorize query construction with regular code.
        let path = "1/indexes/\(urlEncodedIndexName)/settings"
        let settingsOperation = client.newRequest(.GET, path: path, body: nil, hostnames: client.readHosts, isSearchQuery: false) {
            (json: [String: AnyObject]?, error: NSError?) in
            if error != nil {
                self.syncError = error
            } else {
                assert(json != nil)
                // Write results to disk.
                if let data = try? NSJSONSerialization.dataWithJSONObject(json!, options: []) {
                    self.settingsFilePath = "\(self.tmpDir)/settings.json"
                    data.writeToFile(self.settingsFilePath, atomically: false)
                    return // all other paths go to error
                } else {
                    self.syncError = NSError(domain: Client.ErrorDomain, code: StatusCode.Unknown.rawValue, userInfo: [NSLocalizedDescriptionKey: "Could not write index settings"])
                }
            }
            assert(self.syncError != nil) // we should reach this point only in case of error (see above)
        }
        offlineClient.buildQueue.addOperation(settingsOperation)
        
        // Task: build the index using the downloaded files.
        buildIndexOperation = NSBlockOperation() {
            if self.syncError == nil {
                let status = self.localIndex!.buildFromSettingsFile(self.settingsFilePath, objectFiles: self.objectsFilePaths, clearIndex: true)
                if status != 200 {
                    self.syncError = NSError(domain: Client.ErrorDomain, code: Int(status), userInfo: [NSLocalizedDescriptionKey: "Could not build local index"])
                } else {
                    // Remember the sync's date
                    self.mirrorSettings.lastSyncDate = NSDate()
                    self.mirrorSettings.save(self.mirrorSettingsFilePath)
                }
            }
            self._syncFinished()
        }
        buildIndexOperation.name = "Build \(self)"
        // Make sure this task is run after the settings task.
        buildIndexOperation.addDependency(settingsOperation)

        // Tasks: Perform data selection queries.
        objectFileIndex = 0
        objectsFilePaths = []
        for dataSelectionQuery in mirrorSettings.queries {
            doBrowseQuery(dataSelectionQuery, browseQuery: dataSelectionQuery.query, objectCount: 0)
        }
        
        // Finally add the build index operation to the queue, now that dependencies are set up.
        offlineClient.buildQueue.addOperation(buildIndexOperation)
    }
    
    // Auxiliary function, called:
    // - once synchronously, to initiate the browse;
    // - from 0 to many times asynchronously, to continue browsing.
    //
    private func doBrowseQuery(dataSelectionQuery: DataSelectionQuery, browseQuery: Query, objectCount currentObjectCount: Int) {
        objectFileIndex += 1
        let currentObjectFileIndex = objectFileIndex
        let path = "1/indexes/\(urlEncodedIndexName)/browse"
        let operation = client.newRequest(.POST, path: path, body: ["params": browseQuery.build()], hostnames: client.readHosts, isSearchQuery: false) {
            (json: [String: AnyObject]?, error: NSError?) in
            if error != nil {
                self.syncError = error
            } else {
                assert(json != nil)
                // Fetch cursor from data.
                let cursor = json!["cursor"] as? String
                if let hits = json!["hits"] as? [[String: AnyObject]] {
                    // Update object count.
                    let newObjectCount = currentObjectCount + hits.count
                    
                    // Write results to disk.
                    if let data = try? NSJSONSerialization.dataWithJSONObject(json!, options: []) {
                        let objectFilePath = "\(self.tmpDir)/\(currentObjectFileIndex).json"
                        self.objectsFilePaths.append(objectFilePath)
                        data.writeToFile(objectFilePath, atomically: false)
                        
                        // Chain if needed.
                        if cursor != nil && newObjectCount < dataSelectionQuery.maxObjects {
                            self.doBrowseQuery(dataSelectionQuery, browseQuery: Query(parameters: ["cursor": cursor!]), objectCount: newObjectCount)
                        }
                        return // all other paths go to error
                    } else {
                        self.syncError = NSError(domain: Client.ErrorDomain, code: StatusCode.Unknown.rawValue, userInfo: [NSLocalizedDescriptionKey: "Could not write hits"])
                    }
                } else {
                    self.syncError = NSError(domain: Client.ErrorDomain, code: StatusCode.InvalidResponse.rawValue, userInfo: [NSLocalizedDescriptionKey: "No hits in server response"])
                }
            }
            assert(self.syncError != nil) // we should reach this point only in case of error (see above)
        }
        offlineClient.buildQueue.addOperation(operation)
        buildIndexOperation.addDependency(operation)
    }

    /// Wrap-up method, to be called at the end of each sync, *whatever the result*.
    ///
    /// WARNING: Calls to this method must be synchronized by the caller.
    ///
    private func _syncFinished() {
        assert(NSOperationQueue.currentQueue() == offlineClient.buildQueue) // ensure serial calls

        // Clean-up.
        do {
            try NSFileManager.defaultManager().removeItemAtPath(tmpDir)
        } catch _ {
            // Ignore error
        }
        tmpDir = nil
        settingsFilePath = nil
        objectsFilePaths = nil
        buildIndexOperation = nil
        
        // Mark the sync as finished.
        self.syncing = false
        
        // Notify observers.
        dispatch_async(dispatch_get_main_queue()) {
            var userInfo: [String: AnyObject]? = nil
            if self.syncError != nil {
                userInfo = [MirroredIndex.SyncErrorKey: self.syncError!]
            }
            NSNotificationCenter.defaultCenter().postNotificationName(MirroredIndex.SyncDidFinishNotification, object: self, userInfo: userInfo)
        }
    }
    
    // ----------------------------------------------------------------------
    // MARK: - Search
    // ----------------------------------------------------------------------

    @objc public override func search(query: Query, completionHandler: CompletionHandler) -> NSOperation {
        // A non-mirrored index behaves exactly as an online index.
        if !mirrored {
            return super.search(query, completionHandler: completionHandler)
        }
        // A mirrored index launches a mixed offline/online request.
        else {
            let queryCopy = Query(copy: query)
            let operation = OnlineOfflineSearchOperation(index: self, query: queryCopy, completionHandler: completionHandler)
            // NOTE: This operation is just an aggregate, so it does not need to be enqueued.
            operation.start()
            return operation
        }
    }
    
    private func searchOnline(query: Query, completionHandler: CompletionHandler) -> NSOperation {
        return super.search(query, completionHandler: completionHandler)
    }
    
    /// A mixed online/offline request.
    /// This request encapsulates two concurrent online and offline requests, to optimize response time.
    ///
    /// WARNING: Can only be used when the index is mirrored.
    ///
    class OnlineOfflineSearchOperation: AsyncOperation {
        private let index: MirroredIndex
        let query: Query
        let completionHandler: CompletionHandler
        private var onlineRequest: NSOperation?
        private var offlineRequest: NSOperation?
        private var mayRunOfflineRequest: Bool = true
        
        init(index: MirroredIndex, query: Query, completionHandler: CompletionHandler) {
            self.index = index
            self.query = query
            self.completionHandler = completionHandler
        }
        
        override func start() {
            // WARNING: All callbacks must run sequentially; we cannot afford race conditions between them.
            // Since most methods use the main thread for callbacks, we have to use it as well.
            
            // Launch an online request immediately.
            onlineRequest = index.searchOnline(query, completionHandler: {
                (content, error) in
                if error != nil && error!.isTransient() {
                    self.startOffline()
                } else {
                    self.cancelOffline()
                    var taggedContent = content
                    if content != nil {
                        taggedContent?[MirroredIndex.JSONKeyOrigin] = MirroredIndex.JSONValueOriginRemote
                    }
                    self.completionHandler(content: taggedContent, error: error);
                }
            })
            
            // Preventive offline mode: schedule an offline request to start after a certain delay.
            if index.preventiveOfflineSearch {
                dispatch_after(dispatch_time(DISPATCH_TIME_NOW, Int64(index.preventiveOfflineSearchDelay * Double(NSEC_PER_SEC))), dispatch_get_main_queue()) {
                    if self.mayRunOfflineRequest {
                        self.startOffline()
                    }
                }
            }
        }
        
        private func startOffline() {
            // NOTE: If we reach this handler, it means the offline request has not been cancelled.
            offlineRequest = index.searchMirror(query, completionHandler: {
                (content, error) in
                // NOTE: If we reach this handler, it means the offline request has not been cancelled.
                // WARNING: A 404 error likely indicates that the local mirror has not been synced yet, so absorb it.
                if error?.domain == Client.ErrorDomain && error?.code == 404 {
                    return
                }
                self.completionHandler(content: content, error: error)
            })
        }
        
        private func cancelOffline() {
            // Flag the offline request as obsolete.
            mayRunOfflineRequest = false;
            // Cancel the offline request if already running.
            offlineRequest?.cancel();
        }
        
        override func cancel() {
            if !cancelled {
                onlineRequest?.cancel()
                cancelOffline()
                super.cancel()
            }
        }
    }
    
    /// Search the local mirror.
    @objc public func searchMirror(query: Query, completionHandler: CompletionHandler) -> NSOperation {
        let queryCopy = Query(copy: query)
        let callingQueue = NSOperationQueue.currentQueue() ?? NSOperationQueue.mainQueue()
        let operation = NSBlockOperation()
        operation.addExecutionBlock() {
            let (content, error) = self._searchMirror(queryCopy)
            callingQueue.addOperationWithBlock() {
                if !operation.cancelled {
                    completionHandler(content: content, error: error)
                }
            }
        }
        self.offlineClient.searchQueue.addOperation(operation)
        return operation
    }
    
    /// Search the local mirror synchronously.
    private func _searchMirror(query: Query) -> (content: [String: AnyObject]?, error: NSError?) {
        assert(!NSThread.isMainThread()) // make sure it's run in the background
        assert(self.mirrored, "Mirroring not activated on this index")
        
        var content: [String: AnyObject]?
        var error: NSError?
        
        let searchResults = localIndex!.search(query.build())
        if searchResults.statusCode == 200 {
            assert(searchResults.data != nil)
            do {
                let json = try NSJSONSerialization.JSONObjectWithData(searchResults.data!, options: NSJSONReadingOptions(rawValue: 0))
                if json is [String: AnyObject] {
                    content = (json as! [String: AnyObject])
                    // NOTE: Origin tagging performed by the SDK.
                } else {
                    error = NSError(domain: Client.ErrorDomain, code: 500, userInfo: [NSLocalizedDescriptionKey: "Invalid JSON returned"])
                }
            } catch let _error as NSError {
                error = _error
            }
        } else {
            error = NSError(domain: Client.ErrorDomain, code: Int(searchResults.statusCode), userInfo: nil)
        }
        assert(content != nil || error != nil)
        return (content: content, error: error)
    }
    
    // ----------------------------------------------------------------------
    // MARK: - Browse
    // ----------------------------------------------------------------------
    // NOTE: Contrary to search, there is no point in transparently switching from online to offline when browsing,
    // as the results would likely be inconsistent. Anyway, the cursor is not portable across instances, so the
    // fall back could only work for the first query.

    /// Browse the local mirror (initial call).
    /// Same semantics as `Index.browse()`.
    ///
    @objc public func browseMirror(query: Query, completionHandler: CompletionHandler) -> NSOperation {
        let queryCopy = Query(copy: query)
        let callingQueue = NSOperationQueue.currentQueue() ?? NSOperationQueue.mainQueue()
        let operation = NSBlockOperation()
        operation.addExecutionBlock() {
            let (content, error) = self._browseMirror(queryCopy)
            callingQueue.addOperationWithBlock() {
                if !operation.cancelled {
                    completionHandler(content: content, error: error)
                }
            }
        }
        self.offlineClient.searchQueue.addOperation(operation)
        return operation
    }

    /// Browse the index from a cursor.
    /// Same semantics as `Index.browseFrom()`.
    ///
    @objc public func browseMirrorFrom(cursor: String, completionHandler: CompletionHandler) -> NSOperation {
        let callingQueue = NSOperationQueue.currentQueue() ?? NSOperationQueue.mainQueue()
        let operation = NSBlockOperation()
        operation.addExecutionBlock() {
            let query = Query(parameters: ["cursor": cursor])
            let (content, error) = self._browseMirror(query)
            callingQueue.addOperationWithBlock() {
                if !operation.cancelled {
                    completionHandler(content: content, error: error)
                }
            }
        }
        self.offlineClient.searchQueue.addOperation(operation)
        return operation
    }

    /// Browse the local mirror synchronously.
    private func _browseMirror(query: Query) -> (content: [String: AnyObject]?, error: NSError?) {
        assert(!NSThread.isMainThread()) // make sure it's run in the background
        assert(self.mirrored, "Mirroring not activated on this index")
        
        var content: [String: AnyObject]?
        var error: NSError?
        
        let searchResults = localIndex!.browse(query.build())
        // TODO: Factorize this code with above and with online requests.
        if searchResults.statusCode == 200 {
            assert(searchResults.data != nil)
            do {
                let json = try NSJSONSerialization.JSONObjectWithData(searchResults.data!, options: NSJSONReadingOptions(rawValue: 0))
                if json is [String: AnyObject] {
                    content = (json as! [String: AnyObject])
                    // NOTE: Origin tagging performed by the SDK.
                } else {
                    error = NSError(domain: Client.ErrorDomain, code: 500, userInfo: [NSLocalizedDescriptionKey: "Invalid JSON returned"])
                }
            } catch let _error as NSError {
                error = _error
            }
        } else {
            error = NSError(domain: Client.ErrorDomain, code: Int(searchResults.statusCode), userInfo: nil)
        }
        assert(content != nil || error != nil)
        return (content: content, error: error)
    }
}
