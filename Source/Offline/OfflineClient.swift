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


typealias APIResponse = (content: [String: AnyObject]?, error: NSError?)


/// An API client that adds offline features on top of the regular online API client.
///
/// + Note: Requires Algolia's Offline Core SDK. The `enableOfflineMode(...)` method must be called with a valid license
/// key prior to calling any offline-related method.
///
@objc public class OfflineClient : Client {
    // MARK: Properties

    var sdk: Sdk = Sdk.sharedSdk()

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
    let buildQueue = NSOperationQueue()
    
    /// Queue used to search local indices in the background.
    let searchQueue = NSOperationQueue()
    
    /// Queue for mixed online/offline operations.
    ///
    /// + Note: We could use `Client.requestQueue`, but since mixed operations are essentially aggregations of
    ///   individual operations, we wish to avoid deadlocks.
    ///
    let mixedRequestQueue = NSOperationQueue()

    // MARK: Initialization
    
    /// Create a new offline-capable Algolia Search client.
    ///
    /// + Note: Offline mode is disabled by default, until you call `enableOfflineMode(...)`.
    ///
    /// - parameter appID: the application ID you have in your admin interface
    /// - parameter apiKey: a valid API key for the service
    ///
    @objc public override init(appID: String, apiKey: String) {
        buildQueue.name = "AlgoliaSearch-Build"
        buildQueue.maxConcurrentOperationCount = 1
        searchQueue.name = "AlgoliaSearch-Search"
        searchQueue.maxConcurrentOperationCount = 1
        mixedRequestQueue.name = "AlgoliaSearch-Mixed"
        rootDataDir = NSSearchPathForDirectoriesInDomains(.ApplicationSupportDirectory, .UserDomainMask, true).first! + "/algolia"
        super.init(appID: appID, apiKey: apiKey)
        mixedRequestQueue.maxConcurrentOperationCount = super.requestQueue.maxConcurrentOperationCount
        userAgents.append(LibraryVersion(name: "AlgoliaSearchOfflineCore-iOS", version: sdk.versionString))
    }
    
    /// Enable the offline mode.
    ///
    /// - parameter licenseData: license for Algolia's SDK
    ///
    @objc public func enableOfflineMode(licenseData: String) {
        do {
            // Create the data directory.
            try NSFileManager.defaultManager().createDirectoryAtPath(self.rootDataDir, withIntermediateDirectories: true, attributes: nil)
            
            // Exclude the data directory from iTunes backup.
            // DISCUSSION: Local indices are essentially a cache. But we cannot just use the `Caches` directory because
            // we would have no guarantee that all files pertaining to an index would be purged simultaneously.
            let url = NSURL.fileURLWithPath(rootDataDir)
            try url.setResourceValue(true, forKey: NSURLIsExcludedFromBackupKey)
        } catch _ {
            // Report errors but do not throw: the offline mode will not work, but the online client is still viable.
            NSLog("Error: could not create data directory '%@'", self.rootDataDir)
        }
        
        // Init the SDK.
        sdk.initialize(licenseData: licenseData)
        // NOTE: Errors reported by the core itself.
    }

    /// Create a new index.
    ///
    /// + Note: The offline client returns mirror-capable indices.
    ///
    @objc public override func getIndex(indexName: String) -> MirroredIndex {
        return MirroredIndex(client: self, indexName: indexName)
    }
    
    /// Create a purely offline index.
    ///
    /// - parameter name: Name for the new index.
    /// - returns: A new object representing the index.
    ///
    /// + Warning: The name should not overlap with any `MirroredIndex` (see `getIndex(_:)`).
    ///
    @objc public func getOfflineIndex(name: String) -> OfflineIndex {
        return OfflineIndex(client: self, name: name)
    }
    
    // MARK: - Accessors
    
    private func indexDir(name: String) -> String {
        return appDir + "/" + name
    }
    
    // MARK: - Operations
    
    /// Test if an index has offline data on disk.
    ///
    /// + Note: This applies both to `MirroredIndex` and `OfflineIndex` instances.
    ///
    /// + Warning: This method is synchronous!
    ///
    /// - parameter name: The index's name.
    /// - returns: `true` if data exists on disk for this index, `false` otherwise.
    ///
    @objc public func hasOfflineData(name: String) -> Bool {
        // TODO: Suboptimal; we should be able to test existence without instantiating a `LocalIndex`.
        return LocalIndex(dataDir: rootDataDir, appID: appID, indexName: name).exists()
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
    @objc public func listIndexesOffline(completionHandler: CompletionHandler) -> NSOperation {
        let operation = NSBlockOperation() {
            let (content, error) = self.listIndexesOfflineSync()
            self.callCompletionHandler(completionHandler, content: content, error: error)
        }
        searchQueue.addOperation(operation)
        return operation
    }
    
    /// List existing offline indexes (synchronously).
    /// Only indices that *actually exist* on disk are listed. If an instance was created but never synced or written
    /// to, it will not appear in the list.
    ///
    /// - returns: A mutally exclusive (content, error) pair.
    ///
    private func listIndexesOfflineSync() -> APIResponse {
        var content: [String: AnyObject]?
        var error: NSError?
        do {
            var items = [[String: AnyObject]]()
            var isDirectory: ObjCBool = false
            if NSFileManager.defaultManager().fileExistsAtPath(appDir, isDirectory: &isDirectory) && isDirectory {
                let files = try NSFileManager.defaultManager().contentsOfDirectoryAtPath(appDir)
                for file in files {
                    if hasOfflineData(file) {
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
    @objc public func deleteIndexOffline(indexName: String, completionHandler: CompletionHandler? = nil) -> NSOperation {
        let operation = NSBlockOperation() {
            let (content, error) = self.deleteIndexOfflineSync(indexName)
            self.callCompletionHandler(completionHandler, content: content, error: error)
        }
        buildQueue.addOperation(operation)
        return operation
    }
    
    /// Delete an offline index (synchronously).
    ///
    /// + Note: This applies both to `MirroredIndex` and `OfflineIndex` instances.
    ///
    /// - returns: A mutally exclusive (content, error) pair.
    ///
    private func deleteIndexOfflineSync(indexName: String) -> APIResponse {
        do {
            try NSFileManager.defaultManager().removeItemAtPath(indexDir(indexName))
            let content: [String: AnyObject] = [
                "deletedAt": NSDate().iso8601()
            ]
            return (content, nil)
        } catch let e as NSError {
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
    @objc public func moveIndexOffline(srcIndexName: String, to dstIndexName: String, completionHandler: CompletionHandler? = nil) -> NSOperation {
        let operation = NSBlockOperation() {
            let (content, error) = self.moveIndexOfflineSync(srcIndexName, to: dstIndexName)
            self.callCompletionHandler(completionHandler, content: content, error: error)
        }
        buildQueue.addOperation(operation)
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
    private func moveIndexOfflineSync(srcIndexName: String, to dstIndexName: String) -> APIResponse {
        do {
            let fromPath = indexDir(srcIndexName)
            let toPath = indexDir(dstIndexName)
            if NSFileManager.defaultManager().fileExistsAtPath(toPath) {
                try NSFileManager.defaultManager().removeItemAtPath(toPath)
            }
            try NSFileManager.defaultManager().moveItemAtPath(fromPath, toPath: toPath)
            let content: [String: AnyObject] = [
                "updatedAt": NSDate().iso8601()
            ]
            return (content, nil)
        } catch let e as NSError {
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
    internal static func parseSearchResults(searchResults: SearchResults) -> (content: [String: AnyObject]?, error: NSError?) {
        var content: [String: AnyObject]?
        var error: NSError?
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
    
    /// Call a completion handler on the main queue.
    ///
    /// - parameter completionHandler: The completion handler to call. If `nil`, this function does nothing.
    /// - parameter content: The content to pass as a first argument to the completion handler.
    /// - parameter error: The error to pass as a second argument to the completion handler.
    ///
    internal func callCompletionHandler(completionHandler: CompletionHandler?, content: [String: AnyObject]?, error: NSError?) {
        if let completionHandler = completionHandler {
            dispatch_async(dispatch_get_main_queue(), {
                completionHandler(content: content, error: error)
            })
        }
    }
}
