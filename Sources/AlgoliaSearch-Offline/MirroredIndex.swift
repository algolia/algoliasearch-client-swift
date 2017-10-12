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


/// A data selection query, used to select data to be mirrored locally by a `MirroredIndex`.
///
@objc public class DataSelectionQuery: NSObject {
    /// Query used to select data.
    @objc public let query: Query
    
    /// Maximum number of objects to retrieve with this query.
    @objc public let maxObjects: Int

    /// Create a new data selection query.
    @objc public init(query: Query, maxObjects: Int) {
        self.query = query
        self.maxObjects = maxObjects
    }
    
    override public func isEqual(_ object: Any?) -> Bool {
        guard let rhs = object as? DataSelectionQuery else {
            return false
        }
        return self.query == rhs.query && self.maxObjects == rhs.maxObjects
    }
}


/// An online index that can also be mirrored locally.
///
/// + Note: You cannot construct this class directly. Please use `OfflineClient.index(withName:)` to obtain an
///   instance.
///
/// + Note: Requires Algolia Offline Core. The `OfflineClient.enableOfflineMode(...)` method must be called with a
///   valid license key prior to calling any offline-related method.
///
/// When created, an instance of this class has its `mirrored` flag set to false, and behaves like a normal,
/// online `Index`. When the `mirrored` flag is set to true, the index becomes capable of acting upon local data.
///
/// + Warning: It is a programming error to call methods acting on the local data when `mirrored` is false. Doing so
///   will result in an assertion error being raised.
///
///
/// ## Request strategy
///
/// When the index is mirrored and the device is online, it becomes possible to transparently switch between online and
/// offline requests. There is no single best strategy for that, because it depends on the use case and the current
/// network conditions. You can choose the strategy through the `requestStrategy` property. The default is
/// `FallbackOnFailure`, which will always target the online API first, then fallback to the offline mirror in case of
/// failure (including network unavailability).
///
/// + Note: If you want to explicitly target either the online API or the offline mirror, doing so is always possible
///   using `searchOnline(...)` or `searchOffline(...)`.
///
/// + Note: The strategy applies to:
///   - `search(...)`
///   - `searchDisjunctiveFaceting(...)`
///   - `multipleQueries(...)`
///   - `getObject(...)`
///   - `getObjects(...)`
///
///
/// ## Bootstrapping
///
/// Before the first sync has successfully completed, a mirrored index is not available offline, because it has simply
/// no data to search in yet. In most cases, this is not a problem: the app will sync as soon as instructed, so unless
/// the device is offline when the app is started for the first time, or unless search is required right after the
/// first launch, the user should not notice anything.
///
/// However, in some cases, you might need to have offline data available as soon as possible. To achieve that,
/// `MirroredIndex` provides a **manual build** feature.
///
/// ### Manual build
///
/// Manual building consists in specifying the source data for your index from local files, instead of downloading it
/// from the API. Namely, you need:
///
/// - the **index settings** (one JSON file); and
/// - the **objects** (as many JSON files as needed, each containing an array of objects).
///
/// Those files are typically embedded in the application as resources, although any other origin works too.
///
/// ### Conditional bootstrapping
///
/// To avoid replacing the local mirror every time the app is started (and potentially overwriting more recent data
/// synced from the API), you should test whether the index already has offline data using the `hasOfflineData`
/// property.
///
/// #### Discussion
///
/// + Warning: We strongly advise against prepackaging index files. While it may work in some cases, Algolia Offline
///   makes no guarantee whatsoever that the index file format will remain backward-compatible forever, nor that it
///   is independent of the hardware architecture (e.g. 32 bits vs 64 bits, or Little Endian vs Big Endian). Instead,
///   always use the manual build feature.
///
/// While a manual build involves computing the offline index on the device, and therefore incurs a small delay before
/// the mirror is actually usable, using plain JSON offers several advantages compared to prepackaging the index file
/// itself:
///
/// - You only need to ship the raw object data, which is smaller than shipping an entire index file, which contains
///   both the raw data *and* indexing metadata.
///
/// - Plain JSON compresses well with standard compression techniques like GZip, whereas an index file uses a binary
///   format which doesn't compress very efficiently.
///
/// - Build automation is facilitated: you can easily extract the required data from your back-end, whereas building
///   an index would involve running the app on each mobile platform as part of your build process and capturing the
///   filesystem.
///
/// Also, the build process is purposedly single-threaded across all indices, which means that on most modern devices
/// with multi-core CPUs, the impact of manual building on the app's performance will be very moderate, especially
/// regarding UI responsiveness.
///
///
/// ## Limitations
///
/// Algolia's core features are fully supported offline, including (but not limited to): **ranking**,
/// **typo tolerance**, **filtering**, **faceting**, **highlighting/snippeting**...
///
/// However, and partly due to tight memory, CPU and disk space constraints, some features are disabled:
///
/// - **Synonyms** are only partially supported:
///
///     - Multi-way ("regular") synonyms are fully supported.
///     - One-way synonyms are not supported.
///     - Alternative corrections are limited to one alternative (compared to multiple alternatives with online indices).
///     - Placeholders are fully supported.
///
/// - Dictionary-based **plurals** are not supported. ("Simple" plurals with a final S are supported.)
///
/// - **IP geolocation** (see `Query.aroundLatLngViaIP`) is not supported.
///
/// - **CJK segmentation** is not supported.
///
///
/// ## Resource handling
///
/// Native resources are lazily instantiated when `mirrored` is set to `true`. They are released when the object is
/// released, or if `mirrored` is set to `false` again.
///
@objc public class MirroredIndex : Index {
    
    // ----------------------------------------------------------------------
    // MARK: Constants
    // ----------------------------------------------------------------------
    
    /// Default minimum delay between two syncs.
    @objc public static let defaultDelayBetweenSyncs: TimeInterval = 60 * 60 * 24 // 1 day

    /// Key used to indicate the origin of results in the returned JSON.
    @objc public static let jsonKeyOrigin = "origin"
    
    /// Value for `jsonKeyOrigin` indicating that the results come from the local mirror.
    @objc public static let jsonValueOriginLocal = "local"
    
    /// Value for `jsonKeyOrigin` indicating that the results come from the online API.
    @objc public static let jsonValueOriginRemote = "remote"

    // ----------------------------------------------------------------------
    // MARK: Properties
    // ----------------------------------------------------------------------
    
    /// The offline client used by this index.
    @objc public var offlineClient: OfflineClient {
        // IMPLEMENTATION NOTE: Could not find a way to implement proper covariant properties in Swift.
        return self.client as! OfflineClient
    }
    
    /// The local index mirroring this remote index (lazy instantiated, only if mirroring is activated).
    var localIndex: LocalIndex!
    
    /// The mirrored index settings.
    let mirrorSettings = MirrorSettings()
    
    /// Whether the index is mirrored locally. Default = false.
    ///
    /// + Note: Setting this property to `true` create the resources required to access the local mirror.
    ///   Setting it to `false` does *not* deallocate those resources.
    ///
    @objc public var mirrored: Bool {
        get {
            return self.synchronized { self._mirrored }
        }
        set {
            self.synchronized { self._mirrored = newValue }
        }
    }
    
    /// Storage for the `mirrored` property.
    ///
    /// + Warning: **DO NOT** ACCESS THIS VARIABLE DIRECTLY.
    ///
    private var _mirrored: Bool = false {
        // NOTE: Synchronization performed by the `mirrored` property.
        didSet {
            if (_mirrored) {
                do {
                    try FileManager.default.createDirectory(atPath: self.indexDataDir, withIntermediateDirectories: true, attributes: nil)
                    // Lazy instantiate the local index.
                    if (self.localIndex == nil) {
                        self.localIndex = LocalIndex(dataDir: self.offlineClient.rootDataDir, appID: self.client.appID, indexName: self.name)
                    }
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
                mirrorSettings.queriesModificationDate = Date()
                mirrorSettings.save(mirrorSettingsFilePath)
            }
        }
    }
    
    /// Minimum delay between two syncs.
    @objc public var delayBetweenSyncs: TimeInterval = defaultDelayBetweenSyncs
    
    /// Date of the last successful sync, or nil if the index has never been successfully synced.
    @objc public var lastSuccessfulSyncDate: Date? {
        return mirrorSettings.lastSyncDate
    }
    
    /// Error encountered by the current/last sync (if any).
    @objc public private(set) var syncError : Error?

    /// Whether this index has offline data on disk.
    ///
    @objc public var hasOfflineData: Bool {
        get {
            assert(mirrored, "Mirroring not activated for this index")
            return localIndex.exists()
        }
    }
    
    // ----------------------------------------------------------------------
    // MARK: - Init
    // ----------------------------------------------------------------------
    
    @objc override internal init(client: Client, name: String) {
        assert(client is OfflineClient)
        super.init(client: client, name: name)
    }
    
    // ----------------------------------------------------------------------
    // MARK: - Sync
    // ----------------------------------------------------------------------

    /// Syncing indicator.
    ///
    /// + Note: To prevent concurrent access to this variable, we always access it from the build (serial) queue.
    ///
    private var syncing: Bool = false
    
    /// Path to the temporary directory for the current sync.
    private var tmpDir : String?
    
    /// The path to the settings file.
    private var settingsFilePath: String?
    
    /// Paths to object files/
    private var objectsFilePaths: [String]?
    
    /// The current object file index. Object files are named `${i}.json`, where `i` is automatically incremented.
    private var objectFileIndex = 0
    
    /// The operation to build the index.
    /// NOTE: We need to store it because its dependencies are modified dynamically.
    private var buildIndexOperation: Operation?
    
    /// Path to the persistent mirror settings.
    private var mirrorSettingsFilePath: String {
        get { return "\(self.indexDataDir)/mirror.plist" }
    }
    
    /// Path to this index's offline data.
    private var indexDataDir: String {
        get { return "\(self.offlineClient.rootDataDir)/\(self.client.appID)/\(self.name)" }
    }
    
    /// Timeout for data synchronization queries.
    /// There is no need to use a too short timeout in this case: we don't need real-time performance, so failing
    /// too soon would only increase the likeliness of a failure.
    private let SYNC_TIMEOUT: TimeInterval = 30

    /// Add a data selection query to the local mirror.
    /// The query is not run immediately. It will be run during the subsequent refreshes.
    ///
    /// + Precondition: Mirroring must have been activated on this index (see the `mirrored` property).
    ///
    @objc
    public func addDataSelectionQuery(_ query: DataSelectionQuery) {
        assert(mirrored);
        mirrorSettings.queries.append(query)
        mirrorSettings.queriesModificationDate = Date()
        mirrorSettings.save(self.mirrorSettingsFilePath)
    }
    
    /// Add any number of data selection queries to the local mirror.
    /// The query is not run immediately. It will be run during the subsequent refreshes.
    ///
    /// + Precondition: Mirroring must have been activated on this index (see the `mirrored` property).
    ///
    @objc
    public func addDataSelectionQueries(_ queries: [DataSelectionQuery]) {
        assert(mirrored);
        mirrorSettings.queries.append(contentsOf: queries)
        mirrorSettings.queriesModificationDate = Date()
        mirrorSettings.save(self.mirrorSettingsFilePath)
    }

    /// Launch a sync.
    /// This unconditionally launches a sync, unless one is already running.
    ///
    /// + Precondition: Mirroring must have been activated on this index (see the `mirrored` property).
    ///
    @objc
    public func sync() {
        assert(self.mirrored, "Mirroring not activated on this index")
        offlineClient.offlineBuildQueue.addOperation() {
            self._sync()
        }
    }

    /// Launch a sync if needed.
    /// This takes into account the delay between syncs.
    ///
    /// + Precondition: Mirroring must have been activated on this index (see the `mirrored` property).
    ///
    @objc
    public func syncIfNeeded() {
        assert(self.mirrored, "Mirroring not activated on this index")
        if self.isSyncDelayExpired() || self.isMirrorSettingsDirty() {
            offlineClient.offlineBuildQueue.addOperation() {
                self._sync()
            }
        }
    }
    
    private func isSyncDelayExpired() -> Bool {
        let currentDate = Date()
        if let lastSyncDate = mirrorSettings.lastSyncDate {
            return currentDate.timeIntervalSince(lastSyncDate as Date) > self.delayBetweenSyncs
        } else {
            return true
        }
    }
    
    private func isMirrorSettingsDirty() -> Bool {
        if let queriesModificationDate = mirrorSettings.queriesModificationDate {
            if let lastSyncDate = lastSuccessfulSyncDate {
                return queriesModificationDate.compare(lastSyncDate) == .orderedDescending
            } else {
                return true
            }
        } else {
            return false
        }
    }
    
    /// Refresh the local mirror.
    ///
    /// WARNING: Calls to this method must be synchronized by the caller.
    ///
    private func _sync() {
        assert(!Thread.isMainThread) // make sure it's run in the background
        assert(OperationQueue.current == offlineClient.offlineBuildQueue) // ensure serial calls
        assert(!self.dataSelectionQueries.isEmpty)

        // If already syncing, abort.
        if syncing {
            return
        }
        syncing = true

        // Notify observers.
        // TODO: Asynchronous notifications are superfluous since the observers can choose their own queue with
        // `NotificationCenter.addObserver(forName:object:queue:using:)`.
        client.completionQueue!.addOperation {
            NotificationCenter.default.post(name: MirroredIndex.SyncDidStartNotification, object: self)
        }

        // Create temporary directory.
        do {
            tmpDir = URL(fileURLWithPath: offlineClient.tmpDir).appendingPathComponent(UUID().uuidString).path
            try FileManager.default.createDirectory(atPath: tmpDir!, withIntermediateDirectories: true, attributes: nil)
        } catch _ {
            NSLog("ERROR: Could not create temporary directory '%@'", tmpDir!)
        }
        
        // NOTE: We use `Operation`s to handle dependencies between tasks.
        syncError = nil
        
        // Task: Download index settings.
        // WARNING: We must use the legacy format to retrieve synonyms, alternative corrections & placeholders.
        let path = "1/indexes/\(urlEncodedName)/settings?getVersion=1"
        let settingsOperation = client.newRequest(method: .GET, path: path, body: nil, hostnames: client.readHosts, isSearchQuery: false) {
            (json, error) in
            if error != nil {
                self.syncError = error
            } else {
                do {
                    assert(json != nil)
                    // Write results to disk.
                    let data = try JSONSerialization.data(withJSONObject: json!, options: [])
                    self.settingsFilePath = URL(fileURLWithPath: self.tmpDir!).appendingPathComponent("settings.json").path
                    try data.write(to: URL(fileURLWithPath: self.settingsFilePath!), options: [])
                } catch let e {
                    self.syncError = e
                }
            }
        }
        offlineClient.offlineBuildQueue.addOperation(settingsOperation)
        
        // Task: build the index using the downloaded files.
        buildIndexOperation = BlockOperation() {
            if self.syncError == nil {
                let (_, error) = self._buildOffline(settingsFile: self.settingsFilePath!, objectFiles: self.objectsFilePaths!)
                if let error = error {
                    self.syncError = error
                    return
                }
                // Remember the sync's date
                self.mirrorSettings.lastSyncDate = Date()
                self.mirrorSettings.save(self.mirrorSettingsFilePath)
            }
            self._syncFinished()
        }
        buildIndexOperation!.name = "Build \(self)"
        // Make sure this task is run after the settings task.
        buildIndexOperation!.addDependency(settingsOperation)

        // Tasks: Perform data selection queries.
        objectFileIndex = 0
        objectsFilePaths = []
        for dataSelectionQuery in mirrorSettings.queries {
            doBrowseQuery(dataSelectionQuery, browseQuery: dataSelectionQuery.query, objectCount: 0)
        }
        
        // Finally add the build index operation to the queue, now that dependencies are set up.
        offlineClient.offlineBuildQueue.addOperation(buildIndexOperation!)
    }
    
    // Auxiliary function, called:
    // - once synchronously, to initiate the browse;
    // - from 0 to many times asynchronously, to continue browsing.
    //
    private func doBrowseQuery(_ dataSelectionQuery: DataSelectionQuery, browseQuery: Query, objectCount currentObjectCount: Int) {
        objectFileIndex += 1
        let currentObjectFileIndex = objectFileIndex
        let path = "1/indexes/\(urlEncodedName)/browse"
        let operation = client.newRequest(method: .POST, path: path, body: ["params": browseQuery.build()], hostnames: client.readHosts, isSearchQuery: false) {
            (json, error) in
            if error != nil {
                self.syncError = error
            } else {
                do {
                    assert(json != nil)
                    // Fetch cursor from data.
                    let cursor = json!["cursor"] as? String
                    guard let hits = json!["hits"] as? [JSONObject] else {
                        self.syncError = InvalidJSONError(description: "No hits found when browsing")
                        return
                    }
                    // Update object count.
                    let newObjectCount = currentObjectCount + hits.count
                    
                    // Write results to disk.
                    let data = try JSONSerialization.data(withJSONObject: json!, options: [])
                    let objectFilePath = URL(fileURLWithPath: self.tmpDir!).appendingPathComponent("\(currentObjectFileIndex).json").path
                    self.objectsFilePaths!.append(objectFilePath)
                    try data.write(to: URL(fileURLWithPath: objectFilePath), options: [])
                    
                    // Chain if needed.
                    if cursor != nil && newObjectCount < dataSelectionQuery.maxObjects {
                        self.doBrowseQuery(dataSelectionQuery, browseQuery: Query(parameters: ["cursor": cursor!]), objectCount: newObjectCount)
                    }
                } catch let e {
                    self.syncError = e
                }
            }
        }
        offlineClient.offlineBuildQueue.addOperation(operation)
        buildIndexOperation!.addDependency(operation)
    }

    /// Wrap-up method, to be called at the end of each sync, *whatever the result*.
    ///
    /// WARNING: Calls to this method must be synchronized by the caller.
    ///
    private func _syncFinished() {
        assert(OperationQueue.current == offlineClient.offlineBuildQueue) // ensure serial calls

        // Clean-up.
        do {
            try FileManager.default.removeItem(atPath: tmpDir!)
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
        // TODO: Asynchronous notifications are superfluous since the observers can choose their own queue with
        // `NotificationCenter.addObserver(forName:object:queue:using:)`.
        client.completionQueue!.addOperation {
            var userInfo: [String: Any]? = nil
            if self.syncError != nil {
                userInfo = [MirroredIndex.errorKey: self.syncError!]
            }
            NotificationCenter.default.post(name: MirroredIndex.SyncDidFinishNotification, object: self, userInfo: userInfo)
        }
    }
    
    // ----------------------------------------------------------------------
    // MARK: - Manual build
    // ----------------------------------------------------------------------
    
    /// Replace the local mirror with local data.
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
    public func buildOffline(settingsFile: String, objectFiles: [String], completionHandler: CompletionHandler? = nil) -> Operation {
        assert(self.mirrored, "Mirroring not activated on this index")
        let operation = AsyncBlockOperation(completionHandler: completionHandler) {
            return self._buildOffline(settingsFile: settingsFile, objectFiles: objectFiles)
        }
        operation.completionQueue = client.completionQueue
        offlineClient.offlineBuildQueue.addOperation(operation)
        return operation
    }

    /// Build the offline mirror.
    ///
    /// + Warning: This method is synchronous: it blocks until completion.
    ///
    /// - parameter settingsFile: Absolute path to the file containing the index settings, in JSON format.
    /// - parameter objectFiles: Absolute path(s) to the file(s) containing the objects. Each file must contain an
    ///   array of objects, in JSON format.
    ///
    private func _buildOffline(settingsFile: String, objectFiles: [String]) -> (JSONObject?, Error?) {
        assert(!Thread.isMainThread) // make sure it's run in the background
        assert(OperationQueue.current == offlineClient.offlineBuildQueue) // ensure serial calls
        // Notify observers.
        // TODO: Asynchronous notifications are superfluous since the observers can choose their own queue with
        // `NotificationCenter.addObserver(forName:object:queue:using:)`.
        client.completionQueue!.addOperation {
            NotificationCenter.default.post(name: MirroredIndex.BuildDidStartNotification, object: self)
        }
        // Build the index.
        let response = OfflineClient.parseResponse(self.localIndex.build(settingsFile: settingsFile, objectFiles: objectFiles, clearIndex: true, deletedObjectIDs: nil))
        // Notify observers.
        var userInfo: [String: Any] = [:]
        userInfo[MirroredIndex.errorKey] = response.error
        // TODO: Asynchronous notifications are superfluous since the observers can choose their own queue with
        // `NotificationCenter.addObserver(forName:object:queue:using:)`.
        client.completionQueue!.addOperation {
            NotificationCenter.default.post(name: MirroredIndex.BuildDidFinishNotification, object: self, userInfo: userInfo)
        }
        return response
    }

    // ----------------------------------------------------------------------
    // MARK: - Search
    // ----------------------------------------------------------------------
    
    /// Strategy to choose between online and offline search.
    ///
    @objc public enum Strategy: Int {
        /// Search online only.
        /// The search will fail when the API can't be reached.
        ///
        /// + Note: You might consider that this defeats the purpose of having a mirror in the first place... But this
        /// is intended for applications wanting to manually manage their policy.
        ///
        case onlineOnly = 0

        /// Search offline only.
        /// The search will fail when the offline mirror has not yet been synced.
        ///
        case offlineOnly = 1
        
        /// Search online, then fallback to offline on failure.
        /// Please note that when online, this is likely to hit the request timeout on *every host* before failing.
        ///
        case fallbackOnFailure = 2
        
        /// Fallback after a certain timeout.
        /// Will first try an online request, but fallback to offline in case of failure or when a timeout has been
        /// reached, whichever comes first.
        ///
        /// The timeout can be set through the `offlineFallbackTimeout` property.
        ///
        case fallbackOnTimeout = 3
    }
    
    /// Strategy to use for offline fallback. Default = `FallbackOnFailure`.
    @objc public var requestStrategy: Strategy = .fallbackOnFailure
    
    /// Timeout used to control offline fallback.
    ///
    /// + Note: Only used by the `FallbackOnTimeout` strategy.
    ///
    @objc public var offlineFallbackTimeout: TimeInterval = 1.0

    /// A mixed online/offline request.
    /// This request encapsulates two concurrent online and offline requests, to optimize response time.
    ///
    /// + Warning: The fallback logic requires that all phases are run sequentially. Since we have no guaranteee that
    ///   the completion handlers run on a serial queue (and since the mixed request queue itself is heavily parallel),
    ///   we explicitly synchronize the blocks using a serial dispatch queue specific to this operation.
    ///
    private class OnlineOfflineOperation: AsyncOperationWithCompletion {
        fileprivate let index: MirroredIndex
        private var onlineRequest: Operation?
        private var offlineRequest: Operation?
        private var mayRunOfflineRequest: Bool = true

        /// Dispatch queue used to serialize the fallback logic.
        private let lock = DispatchQueue(label: "MirroredIndex.OnlineOfflineOperation.lock")

        init(index: MirroredIndex, completionHandler: @escaping CompletionHandler) {
            self.index = index
            super.init(completionHandler: completionHandler)
            self.completionQueue = index.client.completionQueue
        }
        
        override func start() {
            lock.sync {
                // If the strategy is "offline only" or if connectivity is unavailable, go offline straight away.
                if index.requestStrategy == .offlineOnly || index.requestStrategy != .onlineOnly && !index.client.shouldMakeNetworkCall() {
                    startOffline()
                }
                    // Otherwise, always launch an online request.
                else {
                    if index.requestStrategy == .onlineOnly || !index.localIndex.exists() {
                        mayRunOfflineRequest = false
                    }
                    startOnline()
                }
                if index.requestStrategy == .fallbackOnTimeout && mayRunOfflineRequest {
                    // Schedule an offline request to start after a certain delay.
                    lock.asyncAfter(deadline: .now() + index.offlineFallbackTimeout) {
                        [weak self] in
                        // WARNING: Because dispatched blocks cannot be cancelled, and to avoid increasing the lifetime of
                        // the operation by the timeout delay, we do not retain self. => Gracefully fail if the operation
                        // has already finished.
                        guard let this = self else { return }
                        if this.mayRunOfflineRequest {
                            this.startOffline()
                        }
                    }
                }
            }
        }
        
        private func startOnline() {
            // Avoid launching the request twice.
            if onlineRequest != nil {
                return
            }
            onlineRequest = startOnlineRequest() {
                [unowned self] // works because the operation is enqueued and retained by the queue
                (content, error) in
                self.lock.sync {
                    // In case of transient error, run an offline request.
                    if error != nil && error!.isTransient() && self.mayRunOfflineRequest {
                        self.startOffline()
                    }
                        // Otherwise, just return the online results.
                    else {
                        self.cancelOffline()
                        self.callCompletion(content: content, error: error)
                    }
                }
            }
        }
        
        private func startOffline() {
            // NOTE: If we reach this handler, it means the offline request has not been cancelled.
            assert(mayRunOfflineRequest)
            // Avoid launching the request twice.
            if offlineRequest != nil {
                return
            }
            offlineRequest = startOfflineRequest() {
                [unowned self] // works because the operation is enqueued and retained by the queue
                (content, error) in
                self.lock.sync {
                    self.onlineRequest?.cancel()
                    self.callCompletion(content: content, error: error)
                }
            }
        }
        
        private func cancelOffline() {
            // Flag the offline request as obsolete.
            mayRunOfflineRequest = false;
            // Cancel the offline request if already running.
            offlineRequest?.cancel();
            offlineRequest = nil
        }
        
        override func cancel() {
            lock.sync {
                if !isCancelled {
                    onlineRequest?.cancel()
                    cancelOffline()
                    super.cancel()
                }
            }
        }
        
        func startOnlineRequest(completionHandler: @escaping CompletionHandler) -> Operation {
            preconditionFailure("To be implemented by derived classes")
        }

        func startOfflineRequest(completionHandler: @escaping CompletionHandler) -> Operation {
            preconditionFailure("To be implemented by derived classes")
        }
    }
    
    /// Search using the current request strategy to choose between online and offline (or a combination of both).
    @objc
    @discardableResult public override func search(_ query: Query, requestOptions: RequestOptions? = nil, completionHandler: @escaping CompletionHandler) -> Operation {
        // IMPORTANT: A non-mirrored index must behave exactly as an online index.
        if (!mirrored) {
            return super.search(query, requestOptions: requestOptions, completionHandler: completionHandler);
        }
        // A mirrored index launches a mixed offline/online request.
        else {
            let queryCopy = Query(copy: query)
            let operation = OnlineOfflineSearchOperation(index: self, query: queryCopy, requestOptions: requestOptions, completionHandler: completionHandler)
            offlineClient.mixedRequestQueue.addOperation(operation)
            return operation
        }
    }
    
    private class OnlineOfflineSearchOperation: OnlineOfflineOperation {
        let query: Query
        let requestOptions: RequestOptions?
        
        init(index: MirroredIndex, query: Query, requestOptions: RequestOptions?, completionHandler: @escaping CompletionHandler) {
            self.query = query
            self.requestOptions = requestOptions
            super.init(index: index, completionHandler: completionHandler)
        }
        
        override func startOnlineRequest(completionHandler: @escaping CompletionHandler) -> Operation {
            return index.searchOnline(query, requestOptions: requestOptions, completionHandler: completionHandler)
        }
        
        override func startOfflineRequest(completionHandler: @escaping CompletionHandler) -> Operation {
            return index.searchOffline(query, completionHandler: completionHandler)
        }
    }
    
    /// Explicitly search the online API, and not the local mirror.
    @objc
    @discardableResult public func searchOnline(_ query: Query, requestOptions: RequestOptions? = nil, completionHandler: @escaping CompletionHandler) -> Operation {
        return super.search(query, completionHandler: {
            (content, error) in
            completionHandler(MirroredIndex.tagAsRemote(content: content), error)
        })
    }
    
    /// Explicitly search the local mirror.
    @objc
    @discardableResult public func searchOffline(_ query: Query, completionHandler: @escaping CompletionHandler) -> Operation {
        assert(self.mirrored, "Mirroring not activated on this index")
        let queryCopy = Query(copy: query)
        let operation = AsyncBlockOperation(completionHandler: completionHandler) {
            return self._searchOffline(queryCopy)
        }
        operation.completionQueue = client.completionQueue
        self.offlineClient.offlineSearchQueue.addOperation(operation)
        return operation
    }

    /// Search the local mirror synchronously.
    private func _searchOffline(_ query: Query) -> (content: JSONObject?, error: Error?) {
        assert(!Thread.isMainThread) // make sure it's run in the background
        
        let searchResults = localIndex.search(query.build())
        return OfflineClient.parseResponse(searchResults)
    }
    
    // MARK: Multiple queries
    
    /// Run multiple queries using the current request strategy to choose between online and offline.
    @objc
    @discardableResult override public func multipleQueries(_ queries: [Query], strategy: String?, requestOptions: RequestOptions? = nil, completionHandler: @escaping CompletionHandler) -> Operation {
        // IMPORTANT: A non-mirrored index must behave exactly as an online index.
        if (!mirrored) {
            return super.multipleQueries(queries, strategy: strategy, requestOptions: requestOptions, completionHandler: completionHandler);
        }
        // A mirrored index launches a mixed offline/online request.
        else {
            let operation = OnlineOfflineMultipleQueriesOperation(index: self, queries: queries, requestOptions: requestOptions, completionHandler: completionHandler)
            offlineClient.mixedRequestQueue.addOperation(operation)
            return operation
        }
    }
    
    private class OnlineOfflineMultipleQueriesOperation: OnlineOfflineOperation {
        let queries: [Query]
        let requestOptions: RequestOptions?
        
        init(index: MirroredIndex, queries: [Query], requestOptions: RequestOptions?, completionHandler: @escaping CompletionHandler) {
            self.queries = queries
            self.requestOptions = requestOptions
            super.init(index: index, completionHandler: completionHandler)
        }
        
        override func startOnlineRequest(completionHandler: @escaping CompletionHandler) -> Operation {
            return index.multipleQueriesOnline(queries, requestOptions: requestOptions, completionHandler: completionHandler)
        }
        
        override func startOfflineRequest(completionHandler: @escaping CompletionHandler) -> Operation {
            return index.multipleQueriesOffline(queries, completionHandler: completionHandler)
        }
    }
    
    /// Run multiple queries on the online API, not the local mirror.
    ///
    /// - parameter queries: List of queries.
    /// - parameter strategy: The strategy to use.
    /// - parameter completionHandler: Completion handler to be notified of the request's outcome.
    /// - returns: A cancellable operation.
    ///
    @objc
    @discardableResult public func multipleQueriesOnline(_ queries: [Query], strategy: String?, requestOptions: RequestOptions? = nil, completionHandler: @escaping CompletionHandler) -> Operation {
        return super.multipleQueries(queries, strategy: strategy, requestOptions: requestOptions, completionHandler: {
            (content, error) in
            completionHandler(MirroredIndex.tagAsRemote(content: content), error)
        })
    }

    /// Run multiple queries on the online API, not the local mirror.
    ///
    /// - parameter queries: List of queries.
    /// - parameter strategy: The strategy to use.
    /// - parameter completionHandler: Completion handler to be notified of the request's outcome.
    /// - returns: A cancellable operation.
    ///
    @discardableResult public func multipleQueriesOnline(_ queries: [Query], strategy: Client.MultipleQueriesStrategy? = nil, requestOptions: RequestOptions? = nil, completionHandler: @escaping CompletionHandler) -> Operation {
        return self.multipleQueriesOnline(queries, strategy: strategy?.rawValue, requestOptions: requestOptions, completionHandler: completionHandler)
    }

    /// Run multiple queries on the local mirror.
    /// This method is the offline equivalent of `Index.multipleQueries(...)`.
    ///
    /// - parameter queries: List of queries.
    /// - parameter strategy: The strategy to use.
    /// - parameter completionHandler: Completion handler to be notified of the request's outcome.
    /// - returns: A cancellable operation.
    ///
    @objc
    @discardableResult public func multipleQueriesOffline(_ queries: [Query], strategy: String?, completionHandler: @escaping CompletionHandler) -> Operation {
        assert(self.mirrored, "Mirroring not activated on this index")
        
        // TODO: We should be doing a copy of the queries for better safety.
        let operation = AsyncBlockOperation(completionHandler: completionHandler) {
            return self._multipleQueriesOffline(queries, strategy: strategy)
        }
        operation.completionQueue = client.completionQueue
        self.offlineClient.offlineSearchQueue.addOperation(operation)
        return operation
    }
    
    /// Run multiple queries on the local mirror.
    /// This method is the offline equivalent of `Index.multipleQueries(...)`.
    ///
    /// - parameter queries: List of queries.
    /// - parameter strategy: The strategy to use.
    /// - parameter completionHandler: Completion handler to be notified of the request's outcome.
    /// - returns: A cancellable operation.
    ///
    @discardableResult public func multipleQueriesOffline(_ queries: [Query], strategy: Client.MultipleQueriesStrategy? = nil, completionHandler: @escaping CompletionHandler) -> Operation {
        return self.multipleQueriesOffline(queries, strategy: strategy?.rawValue, completionHandler: completionHandler)
    }
    
    /// Run multiple queries on the local mirror synchronously.
    private func _multipleQueriesOffline(_ queries: [Query], strategy: String?) -> (content: JSONObject?, error: Error?) {
        return MultipleQueryEmulator(indexName: self.name, querier: self._searchOffline).multipleQueries(queries, strategy: strategy)
    }
    
    // ----------------------------------------------------------------------
    // MARK: - Browse
    // ----------------------------------------------------------------------
    // NOTE: Contrary to search, there is no point in transparently switching from online to offline when browsing,
    // as the results would likely be inconsistent. Anyway, the cursor is not portable across instances, so the
    // fall back could only work for the first query.

    /// Browse the local mirror (initial call).
    /// Same semantics as `Index.browse(query:completionHandler:)`.
    ///
    @objc(browseMirrorWithQuery:completionHandler:)
    @discardableResult public func browseMirror(query: Query, completionHandler: @escaping CompletionHandler) -> Operation {
        assert(self.mirrored, "Mirroring not activated on this index")
        let queryCopy = Query(copy: query)
        let operation = AsyncBlockOperation(completionHandler: completionHandler) {
            return self._browseMirror(query: queryCopy)
        }
        operation.completionQueue = client.completionQueue
        self.offlineClient.offlineSearchQueue.addOperation(operation)
        return operation
    }

    /// Browse the index from a cursor.
    /// Same semantics as `Index.browse(from:completionHandler:)`.
    ///
    @objc(browseMirrorFromCursor:completionHandler:)
    @discardableResult public func browseMirror(from cursor: String, completionHandler: @escaping CompletionHandler) -> Operation {
        assert(self.mirrored, "Mirroring not activated on this index")
        let operation = AsyncBlockOperation(completionHandler: completionHandler) {
            let query = Query(parameters: ["cursor": cursor])
            return self._browseMirror(query: query)
        }
        operation.completionQueue = client.completionQueue
        self.offlineClient.offlineSearchQueue.addOperation(operation)
        return operation
    }

    /// Browse the local mirror synchronously.
    private func _browseMirror(query: Query) -> (content: JSONObject?, error: Error?) {
        assert(!Thread.isMainThread) // make sure it's run in the background
        
        let searchResults = localIndex.browse(query.build())
        return OfflineClient.parseResponse(searchResults)
    }
    
    // ----------------------------------------------------------------------
    // MARK: - Getting individual objects
    // ----------------------------------------------------------------------
    
    /// Get an object from this index, optionally restricting the retrieved content.
    /// Same semantics as `Index.getObject(withID:attributesToRetrieve:completionHandler:)`.
    ///
    @objc @discardableResult override public func getObject(withID objectID: String, attributesToRetrieve: [String]? = nil, requestOptions: RequestOptions? = nil, completionHandler: @escaping CompletionHandler) -> Operation {
        if (!mirrored) {
            return super.getObject(withID: objectID, attributesToRetrieve: attributesToRetrieve, requestOptions: requestOptions, completionHandler: completionHandler)
        } else {
            let operation = OnlineOfflineGetObjectOperation(index: self, objectID: objectID, attributesToRetrieve: attributesToRetrieve, requestOptions: requestOptions, completionHandler: completionHandler)
            offlineClient.mixedRequestQueue.addOperation(operation)
            return operation
        }
    }

    private class OnlineOfflineGetObjectOperation: OnlineOfflineOperation {
        let objectID: String
        let attributesToRetrieve: [String]?
        let requestOptions: RequestOptions?
        
        init(index: MirroredIndex, objectID: String, attributesToRetrieve: [String]?, requestOptions: RequestOptions?, completionHandler: @escaping CompletionHandler) {
            self.objectID = objectID
            self.attributesToRetrieve = attributesToRetrieve
            self.requestOptions = requestOptions
            super.init(index: index, completionHandler: completionHandler)
        }
        
        override func startOnlineRequest(completionHandler: @escaping CompletionHandler) -> Operation {
            return index.getObjectOnline(withID: objectID, attributesToRetrieve: attributesToRetrieve, requestOptions: requestOptions, completionHandler: completionHandler)
        }
        
        override func startOfflineRequest(completionHandler: @escaping CompletionHandler) -> Operation {
            return index.getObjectOffline(withID: objectID, attributesToRetrieve: attributesToRetrieve, completionHandler: completionHandler)
        }
    }

    /// Get an individual object, explicitly targeting the online API, and not the offline mirror.
    @objc
    @discardableResult public func getObjectOnline(withID objectID: String, attributesToRetrieve: [String]? = nil, requestOptions: RequestOptions? = nil, completionHandler: @escaping CompletionHandler) -> Operation {
        return super.getObject(withID: objectID, attributesToRetrieve: attributesToRetrieve, requestOptions: requestOptions, completionHandler: {
            (content, error) in
            completionHandler(MirroredIndex.tagAsRemote(content: content), error)
        })
    }
    
    @objc(getObjectOnlineWithID:attributesToRetrieve:completionHandler:)
    @discardableResult public func z_objc_getObjectOnline(withID objectID: String, attributesToRetrieve: [String]?, completionHandler: @escaping CompletionHandler) -> Operation {
        return self.getObjectOnline(withID: objectID, attributesToRetrieve: attributesToRetrieve, completionHandler: completionHandler)
    }
    
    /// Get an individual object, explicitly targeting the offline mirror, and not the online API.
    @objc
    @discardableResult public func getObjectOffline(withID objectID: String, attributesToRetrieve: [String]? = nil, completionHandler: @escaping CompletionHandler) -> Operation {
        assert(self.mirrored, "Mirroring not activated on this index")
        let operation = AsyncBlockOperation(completionHandler: completionHandler) {
            return self._getObjectOffline(withID: objectID, attributesToRetrieve: attributesToRetrieve)
        }
        operation.completionQueue = client.completionQueue
        self.offlineClient.offlineSearchQueue.addOperation(operation)
        return operation
    }
    
    /// Get an individual object from the local mirror synchronously.
    ///
    private func _getObjectOffline(withID objectID: String, attributesToRetrieve: [String]?) -> (content: JSONObject?, error: Error?) {
        assert(!Thread.isMainThread) // make sure it's run in the background
        let params = Query()
        params.attributesToRetrieve = attributesToRetrieve
        let searchResults = localIndex.getObjects(withIDs: [objectID], parameters: params.build())
        var (content, error) = OfflineClient.parseResponse(searchResults)
        if error == nil {
            if let results = content?["results"] as? [JSONObject], results.count == 1 {
                content = results[0]
            } else {
                content = nil
                error = HTTPError(statusCode: StatusCode.internalServerError.rawValue) // should never happen
            }
        }
        return (MirroredIndex.tagAsLocal(content: content), error)
    }

    /// Get several objects from this index, optionally restricting the retrieved content.
    /// Same semantics as `Index.getObjects(withIDs:attributesToRetrieve:completionHandler:)`.
    ///
    @objc @discardableResult override public func getObjects(withIDs objectIDs: [String], attributesToRetrieve: [String]? = nil, requestOptions: RequestOptions? = nil, completionHandler: @escaping CompletionHandler) -> Operation {
        if (!mirrored) {
            return super.getObjects(withIDs: objectIDs, attributesToRetrieve: attributesToRetrieve, requestOptions: requestOptions, completionHandler: completionHandler)
        } else {
            let operation = OnlineOfflineGetObjectsOperation(index: self, objectIDs: objectIDs, attributesToRetrieve: attributesToRetrieve, requestOptions: requestOptions, completionHandler: completionHandler)
            offlineClient.mixedRequestQueue.addOperation(operation)
            return operation
        }
    }

    private class OnlineOfflineGetObjectsOperation: OnlineOfflineOperation {
        let objectIDs: [String]
        let attributesToRetrieve: [String]?
        let requestOptions: RequestOptions?
        
        init(index: MirroredIndex, objectIDs: [String], attributesToRetrieve: [String]?, requestOptions: RequestOptions?, completionHandler: @escaping CompletionHandler) {
            self.objectIDs = objectIDs
            self.attributesToRetrieve = attributesToRetrieve
            self.requestOptions = requestOptions
            super.init(index: index, completionHandler: completionHandler)
        }
        
        override func startOnlineRequest(completionHandler: @escaping CompletionHandler) -> Operation {
            return index.getObjectsOnline(withIDs: objectIDs, attributesToRetrieve: attributesToRetrieve, requestOptions: requestOptions, completionHandler: completionHandler)
        }
        
        override func startOfflineRequest(completionHandler: @escaping CompletionHandler) -> Operation {
            return index.getObjectsOffline(withIDs: objectIDs, attributesToRetrieve: attributesToRetrieve, completionHandler: completionHandler)
        }
    }
    
    /// Get individual objects, explicitly targeting the online API, and not the offline mirror.
    @objc
    @discardableResult public func getObjectsOnline(withIDs objectIDs: [String], attributesToRetrieve: [String]? = nil, requestOptions: RequestOptions? = nil, completionHandler: @escaping CompletionHandler) -> Operation {
        return super.getObjects(withIDs: objectIDs, attributesToRetrieve: attributesToRetrieve, requestOptions: requestOptions, completionHandler: {
            (content, error) in
            completionHandler(MirroredIndex.tagAsRemote(content: content), error)
        })
    }
    
    @objc(getObjectsOnlineWithIDs:attributesToRetrieve:completionHandler:)
    @discardableResult public func z_objc_getObjectsOnline(withIDs objectIDs: [String], attributesToRetrieve: [String]?, completionHandler: @escaping CompletionHandler) -> Operation {
        return self.getObjectsOnline(withIDs: objectIDs, attributesToRetrieve: attributesToRetrieve, completionHandler: completionHandler)
    }
    
    /// Get individual objects, explicitly targeting the offline mirror, and not the online API.
    @objc
    @discardableResult public func getObjectsOffline(withIDs objectIDs: [String], attributesToRetrieve: [String]? = nil, completionHandler: @escaping CompletionHandler) -> Operation {
        assert(self.mirrored, "Mirroring not activated on this index")
        let operation = AsyncBlockOperation(completionHandler: completionHandler) {
            return self._getObjectsOffline(withIDs: objectIDs, attributesToRetrieve: attributesToRetrieve)
        }
        operation.completionQueue = client.completionQueue
        self.offlineClient.offlineSearchQueue.addOperation(operation)
        return operation
    }
    
    /// Get individual objects from the local mirror synchronously.
    ///
    private func _getObjectsOffline(withIDs objectIDs: [String], attributesToRetrieve: [String]?) -> (content: JSONObject?, error: Error?) {
        assert(!Thread.isMainThread) // make sure it's run in the background
        let params = Query()
        params.attributesToRetrieve = attributesToRetrieve
        let searchResults = localIndex.getObjects(withIDs: objectIDs, parameters: params.build())
        let (content, error) = OfflineClient.parseResponse(searchResults)
        return (MirroredIndex.tagAsLocal(content: content), error)
    }

    // ----------------------------------------------------------------------
    // MARK: - Search for facet values
    // ----------------------------------------------------------------------
    
    /// Search for facet values, using the current request strategy to choose between online and offline.
    /// Same parameters as `Index.searchForFacetValues(...)`.
    ///
    @objc(searchForFacetValuesOf:matching:query:requestOptions:completionHandler:)
    @discardableResult override public func searchForFacetValues(of facetName: String, matching text: String, query: Query? = nil, requestOptions: RequestOptions? = nil, completionHandler: @escaping CompletionHandler) -> Operation {
        // IMPORTANT: A non-mirrored index must behave exactly as an online index.
        if (!mirrored) {
            return super.searchForFacetValues(of: facetName, matching: text, query: query, requestOptions: requestOptions, completionHandler: completionHandler)
        }
        // A mirrored index launches a mixed offline/online request.
        else {
            let operation = MixedSearchFacetOperation(index: self, facetName: facetName, facetQuery: text, query: query, requestOptions: requestOptions, completionHandler: completionHandler)
            offlineClient.mixedRequestQueue.addOperation(operation)
            return operation
        }
    }
    
    private class MixedSearchFacetOperation: OnlineOfflineOperation {
        let facetName: String
        let facetQuery: String
        let query: Query?
        let requestOptions: RequestOptions?
        
        init(index: MirroredIndex, facetName: String, facetQuery: String, query: Query?, requestOptions: RequestOptions?, completionHandler: @escaping CompletionHandler) {
            self.facetName = facetName
            self.facetQuery = facetQuery
            self.query = query
            self.requestOptions = requestOptions
            super.init(index: index, completionHandler: completionHandler)
        }
        
        override func startOnlineRequest(completionHandler: @escaping CompletionHandler) -> Operation {
            return index.searchForFacetValuesOnline(of: facetName, matching: facetQuery, query: query, requestOptions: requestOptions, completionHandler: completionHandler)
        }
        
        override func startOfflineRequest(completionHandler: @escaping CompletionHandler) -> Operation {
            return index.searchForFacetValuesOffline(of: facetName, matching: facetQuery, query: query, completionHandler: completionHandler)
        }
    }
    
    /// Search for facet values on the online API, not the local mirror.
    /// This method is an alias of `Index.searchForFacetValues(...)`.
    ///
    @objc(searchForFacetValuesOnlineOf:matching:query:requestOptions:completionHandler:)
    @discardableResult public func searchForFacetValuesOnline(of facetName: String, matching text: String, query: Query? = nil, requestOptions: RequestOptions? = nil, completionHandler: @escaping CompletionHandler) -> Operation {
        return super.searchForFacetValues(of: facetName, matching: text, query: query, requestOptions: requestOptions, completionHandler: {
            (content, error) in
            completionHandler(MirroredIndex.tagAsRemote(content: content), error)
        })
    }
    
    /// Search for facet values on the local mirror, not the online API.
    /// This method is the offline equivalent of `Index.searchForFacetValues(...)`.
    ///
    @objc(searchForFacetValuesOfflineOf:matching:query:completionHandler:)
    @discardableResult public func searchForFacetValuesOffline(of facetName: String, matching text: String, query: Query? = nil, completionHandler: @escaping CompletionHandler) -> Operation {
        assert(self.mirrored, "Mirroring not activated on this index")
        let operation = AsyncBlockOperation(completionHandler: completionHandler) {
            return self._searchForFacetValuesOffline(of: facetName, matching: text, query: query)
        }
        operation.completionQueue = client.completionQueue
        self.offlineClient.offlineSearchQueue.addOperation(operation)
        return operation
    }
    
    /// Search for facet values on the local mirror synchronously.
    private func _searchForFacetValuesOffline(of facetName: String, matching text: String, query: Query?) -> (content: JSONObject?, error: Error?) {
        assert(!Thread.isMainThread) // make sure it's run in the background
        let searchResults = localIndex.searchForFacetValues(of: facetName, matching: text, parameters: query?.build())
        return OfflineClient.parseResponse(searchResults)
    }

    // ----------------------------------------------------------------------
    // MARK: - Notifications
    // ----------------------------------------------------------------------

    /// Notification sent when the sync has started.
    @objc public static let SyncDidStartNotification = Notification.Name("AlgoliaSearch.MirroredIndex.SyncDidStartNotification")
    
    /// Notification sent when the sync has finished.
    @objc public static let SyncDidFinishNotification = Notification.Name("AlgoliaSearch.MirroredIndex.SyncDidFinishNotification")
    
    /// Notification user info key used to pass the error, when an error occurred during a sync or a build.
    @objc public static let errorKey = "AlgoliaSearch.MirroredIndex.errorKey"

    @available(*, deprecated: 4.6, message: "Please use `errorKey` instead")
    @objc public static let syncErrorKey = errorKey
    
    /// Notification sent when the build of the local mirror has started.
    /// This notification is sent both for syncs or manual builds.
    ///
    @objc public static let BuildDidStartNotification = Notification.Name("AlgoliaSearch.MirroredIndex.BuildDidStartNotification")
    
    /// Notification sent when the build of the local mirror has finished.
    /// This notification is sent both for syncs or manual builds.
    ///
    @objc public static let BuildDidFinishNotification = Notification.Name("AlgoliaSearch.MirroredIndex.BuildDidFinishNotification")
    
    // ----------------------------------------------------------------------
    // MARK: - Utils
    // ----------------------------------------------------------------------

    /// Tag some content as having remote origin.
    ///
    /// - parameter content: The content to tag. For convenience purposes, `nil` is allowed.
    /// - returns: The tagged content, or `nil` if `content` was `nil`.
    ///
    private static func tagAsRemote(content: JSONObject?) -> JSONObject? {
        var taggedContent: JSONObject? = content
        taggedContent?[MirroredIndex.jsonKeyOrigin] = MirroredIndex.jsonValueOriginRemote
        return taggedContent
    }

    /// Tag some content as having local origin.
    ///
    /// - parameter content: The content to tag. For convenience purposes, `nil` is allowed.
    /// - returns: The tagged content, or `nil` if `content` was `nil`.
    ///
    private static func tagAsLocal(content: JSONObject?) -> JSONObject? {
        var taggedContent: JSONObject? = content
        taggedContent?[MirroredIndex.jsonKeyOrigin] = MirroredIndex.jsonValueOriginLocal
        return taggedContent
    }
}
