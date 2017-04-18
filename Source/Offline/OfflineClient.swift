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


typealias APIResponse = (content: JSONObject?, error: Error?)


/// An API client that adds offline features on top of the regular online API client.
///
/// + Note: Requires Algolia's Offline Core SDK. The `enableOfflineMode(...)` method must be called with a valid license
/// key prior to calling any offline-related method.
///
@objc public class OfflineClient : Client {
    // MARK: Properties

    var sdk: Sdk = Sdk.shared

    /// Path to directory where the local data is stored.
    /// Defaults to an `algolia` sub-directory inside the `Library/Application Support` directory.
    /// If you set it to another value, do so *before* calling `enableOfflineMode(...)`.
    ///
    /// + Warning: This directory will be explicitly excluded from iCloud/iTunes backup.
    ///
    @objc public var rootDataDir: String
    
    /// The local data directory for this client's app ID.
    private var appDir: String { return rootDataDir + "/" + appID }
    
    // NOTE: The build and search queues must be serial to prevent concurrent searches or builds on a given index, but
    // may be distinct because building can be done in parallel with search.
    //
    // NOTE: Although serialization is only strictly needed at the index level, we use global queues as a way to limit
    // resource consumption by the SDK.
    
    /// Queue used to build local indices in the background.
    let offlineBuildQueue = OperationQueue()
    
    /// Queue used to search local indices in the background.
    let offlineSearchQueue = OperationQueue()
    
    /// Queue for mixed online/offline operations.
    ///
    /// + Note: We could use `Client.onlineRequestQueue`, but since mixed operations are essentially aggregations of
    ///   individual operations, we wish to avoid deadlocks.
    ///
    let mixedRequestQueue = OperationQueue()
    
    /// Path to the root directory for temporary files.
    var tmpDir: String

    // MARK: Initialization
    
    // Fake global property to act as static initializer. This is the recommended (and only, AFAIK) way, as per the doc.
    // See <http://stackoverflow.com/a/37887068/5838753>
    private static let _initUserAgent: Void = {
        addUserAgent(LibraryVersion(name: "AlgoliaSearchOfflineCore-iOS", version: Sdk.shared.versionString))
    }()
    
    /// Create a new offline-capable Algolia Search client.
    ///
    /// + Note: Offline mode is disabled by default, until you call `enableOfflineMode(...)`.
    ///
    /// - parameter appID: the application ID you have in your admin interface
    /// - parameter apiKey: a valid API key for the service
    ///
    @objc public override init(appID: String, apiKey: String) {
        offlineBuildQueue.name = "AlgoliaSearch offline build"
        offlineBuildQueue.maxConcurrentOperationCount = 1
        offlineSearchQueue.name = "AlgoliaSearch offline search"
        offlineSearchQueue.maxConcurrentOperationCount = 1
        mixedRequestQueue.name = "AlgoliaSearch mixed requests"
        rootDataDir = NSSearchPathForDirectoriesInDomains(.applicationSupportDirectory, .userDomainMask, true).first! + "/algolia"
        tmpDir = URL(fileURLWithPath: NSTemporaryDirectory()).appendingPathComponent("algolia").path
        super.init(appID: appID, apiKey: apiKey)
        mixedRequestQueue.maxConcurrentOperationCount = super.onlineRequestQueue.maxConcurrentOperationCount
        // IMPORTANT: Update user agent. This will only be invoked once (static property).
        OfflineClient._initUserAgent
    }
    
    /// Enable the offline mode.
    ///
    /// - parameter licenseKey: License key for Algolia's SDK.
    ///
    @objc(enableOfflineModeWithLicenseKey:)
    public func enableOfflineMode(licenseKey: String) {
        do {
            // Create the data directory.
            try FileManager.default.createDirectory(atPath: self.rootDataDir, withIntermediateDirectories: true, attributes: nil)
            
            // Exclude the data directory from iTunes backup.
            // DISCUSSION: Local indices are essentially a cache. But we cannot just use the `Caches` directory because
            // we would have no guarantee that all files pertaining to an index would be purged simultaneously.
            let url = URL(fileURLWithPath: rootDataDir)
            try (url as NSURL).setResourceValue(true, forKey: URLResourceKey.isExcludedFromBackupKey)
        } catch _ {
            // Report errors but do not throw: the offline mode will not work, but the online client is still viable.
            NSLog("Error: could not create data directory '%@'", self.rootDataDir)
        }
        
        // Init the SDK.
        sdk.initialize(licenseKey: licenseKey)
        // NOTE: Errors reported by the core itself.
    }

    /// Obtain a mirrored index.
    ///
    /// + Note: The offline client returns mirror-capable indices.
    ///
    /// + Note: Only one instance can exist for a given index name. Subsequent calls to this method with the same
    ///   index name will return the same instance, unless it has already been released.
    ///
    /// + Warning: The name should not overlap with any `OfflineIndex` (see `offlineIndex(withName:)`).
    ///
    /// - parameter indexName: The name of the index.
    /// - returns: A proxy to the specified index.
    ///
    @objc public override func index(withName indexName: String) -> MirroredIndex {
        if let index = indices.object(forKey: indexName as NSString) {
            assert(index is MirroredIndex, "An index with the same name but a different type has already been created")
            return index as! MirroredIndex
        } else {
            let index = MirroredIndex(client: self, name: indexName)
            indices.setObject(index, forKey: indexName as NSString)
            return index
        }
    }
    
    /// Obtain an offline index.
    ///
    /// + Note: Only one instance can exist for a given index name. Subsequent calls to this method with the same
    ///   index name will return the same instance, unless it has already been released.
    ///
    /// + Warning: The name should not overlap with any `MirroredIndex` (see `index(withName:)`).
    ///
    /// - parameter indexName: The name of the index.
    /// - returns: A proxy to the specified index.
    ///
    @objc public func offlineIndex(withName indexName: String) -> OfflineIndex {
        if let index = indices.object(forKey: indexName as NSString) {
            assert(index is OfflineIndex, "An index with the same name but a different type has already been created")
            return index as! OfflineIndex
        } else {
            let index = OfflineIndex(client: self, name: indexName)
            indices.setObject(index, forKey: indexName as NSString)
            return index
        }
    }
    
    // MARK: - Accessors
    
    private func indexDir(indexName: String) -> String {
        return appDir + "/" + indexName
    }
    
    // MARK: - Operations
    
    /// Test if an index has offline data on disk.
    ///
    /// + Note: This applies both to `MirroredIndex` and `OfflineIndex` instances.
    ///
    /// + Warning: This method is synchronous!
    ///
    /// - parameter indexName: The index's name.
    /// - returns: `true` if data exists on disk for this index, `false` otherwise.
    ///
    @objc public func hasOfflineData(indexName: String) -> Bool {
        // TODO: Suboptimal; we should be able to test existence without instantiating a `LocalIndex`.
        return LocalIndex(dataDir: rootDataDir, appID: appID, indexName: indexName).exists()
    }

    /// List existing offline indexes.
    /// Only indices that *actually exist* on disk are listed. If an instance was created but never synced or written
    /// to, it will not appear in the list.
    ///
    /// + Note: This applies both to `MirroredIndex` and `OfflineIndex` instances.
    ///
    /// - parameter completionHandler: Completion handler to be notified of the request's outcome.
    /// - returns: A cancellable operation.
    ///
    @discardableResult
    @objc(listOfflineIndexes:)
    public func listOfflineIndexes(completionHandler: @escaping CompletionHandler) -> Operation {
        let operation = BlockOperation() {
            let (content, error) = self.listOfflineIndexesSync()
            self.callCompletionHandler(completionHandler, content: content, error: error)
        }
        offlineSearchQueue.addOperation(operation)
        return operation
    }
    
    /// List existing offline indexes (synchronously).
    /// Only indices that *actually exist* on disk are listed. If an instance was created but never synced or written
    /// to, it will not appear in the list.
    ///
    /// - returns: A mutally exclusive (content, error) pair.
    ///
    private func listOfflineIndexesSync() -> APIResponse {
        var content: JSONObject?
        var error: NSError?
        do {
            var items = [JSONObject]()
            var isDirectory: ObjCBool = false
            if FileManager.default.fileExists(atPath: appDir, isDirectory: &isDirectory) && isDirectory.boolValue {
                let files = try FileManager.default.contentsOfDirectory(atPath: appDir)
                for file in files {
                    if hasOfflineData(indexName: file) {
                        items.append([
                            "name": file
                        ])
                        // TODO: Do we need other data as in the online API?
                    }
                }
            }
            content = ["items": items]
        } catch let e as NSError {
            error = e
        }
        return (content, error)
    }
    
    /// Delete an offline index.
    ///
    /// + Note: This applies both to `MirroredIndex` and `OfflineIndex` instances.
    ///
    /// - parameter indexName: Name of the index to delete.
    /// - parameter completionHandler: Completion handler to be notified of the request's outcome.
    /// - returns: A cancellable operation.
    ///
    @discardableResult
    @objc(deleteOfflineIndexWithName:completionHandler:)
    public func deleteOfflineIndex(withName indexName: String, completionHandler: CompletionHandler? = nil) -> Operation {
        let operation = BlockOperation() {
            let (content, error) = self.deleteOfflineIndexSync(withName: indexName)
            self.callCompletionHandler(completionHandler, content: content, error: error)
        }
        offlineBuildQueue.addOperation(operation)
        return operation
    }
    
    /// Delete an offline index (synchronously).
    ///
    /// + Note: This applies both to `MirroredIndex` and `OfflineIndex` instances.
    ///
    /// - parameter indexName: Name of the index to delete.
    /// - returns: A mutally exclusive (content, error) pair.
    ///
    private func deleteOfflineIndexSync(withName indexName: String) -> APIResponse {
        do {
            try FileManager.default.removeItem(atPath: indexDir(indexName: indexName))
            let content: JSONObject = [
                "deletedAt": Date().iso8601
            ]
            return (content, nil)
        } catch let e {
            return (nil, e)
        }
    }
    
    /// Move an existing index.
    ///
    /// + Warning: This will overwrite the destination index if it exists.
    ///
    /// + Note: This applies both to `MirroredIndex` and `OfflineIndex` instances.
    ///
    /// - parameter srcIndexName: Name of index to move.
    /// - parameter dstIndexName: The new index name.
    /// - parameter completionHandler: Completion handler to be notified of the request's outcome.
    /// - returns: A cancellable operation.
    ///
    @discardableResult
    @objc public func moveOfflineIndex(from srcIndexName: String, to dstIndexName: String, completionHandler: CompletionHandler? = nil) -> Operation {
        let operation = BlockOperation() {
            let (content, error) = self.moveOfflineIndexSync(from: srcIndexName, to: dstIndexName)
            self.callCompletionHandler(completionHandler, content: content, error: error)
        }
        offlineBuildQueue.addOperation(operation)
        return operation
    }
    
    /// Move an existing index (synchronously).
    ///
    /// + Warning: This will overwrite the destination index if it exists.
    ///
    /// + Note: This applies both to `MirroredIndex` and `OfflineIndex` instances.
    ///
    /// - parameter srcIndexName: Name of index to move.
    /// - parameter dstIndexName: The new index name.
    /// - returns: A mutally exclusive (content, error) pair.
    ///
    private func moveOfflineIndexSync(from srcIndexName: String, to dstIndexName: String) -> APIResponse {
        do {
            let fromPath = indexDir(indexName: srcIndexName)
            let toPath = indexDir(indexName: dstIndexName)
            if FileManager.default.fileExists(atPath: toPath) {
                try FileManager.default.removeItem(atPath: toPath)
            }
            try FileManager.default.moveItem(atPath: fromPath, toPath: toPath)
            let content: JSONObject = [
                "updatedAt": Date().iso8601
            ]
            return (content, nil)
        } catch let e {
            return (nil, e)
        }
    }
    
    // NOTE: Copy not supported because it would be too resource-intensive.
    
    // MARK: - Utils
    
    /// Parse search results returned by the Offline Core into a (content, error) pair suitable for completion handlers.
    ///
    /// - parameter searchResults: Search results to parse.
    /// - returns: A (content, error) pair that can be passed to a `CompletionHandler`.
    ///
    internal static func parseResponse(_ response: Response) -> APIResponse {
        var content: JSONObject?
        var error: Error?
        let statusCode = Int(response.statusCode)
        if statusCode == StatusCode.ok.rawValue {
            if let data = response.data {
                do {
                    let json = try JSONSerialization.jsonObject(with: data, options: [])
                    if json is JSONObject {
                        content = (json as! JSONObject)
                        // NOTE: Origin tagging performed by the SDK.
                    } else {
                        error = InvalidJSONError(description: "Invalid JSON returned")
                    }
                } catch let _error {
                    error = _error
                }
            } else { // may happen in case of empty response (e.g. when building)
                content = JSONObject()
            }
        } else {
            error = HTTPError(statusCode: statusCode, message: response.errorMessage)
        }
        assert(content != nil || error != nil)
        return (content: content, error: error)
    }
    
    /// Call a completion handler on the completion queue.
    ///
    /// - parameter completionHandler: The completion handler to call. If `nil`, this function does nothing.
    /// - parameter content: The content to pass as a first argument to the completion handler.
    /// - parameter error: The error to pass as a second argument to the completion handler.
    ///
    internal func callCompletionHandler(_ completionHandler: CompletionHandler?, content: JSONObject?, error: Error?) {
        if let completionHandler = completionHandler {
            completionQueue!.addOperation {
                completionHandler(content, error)
            }
        }
    }
}
