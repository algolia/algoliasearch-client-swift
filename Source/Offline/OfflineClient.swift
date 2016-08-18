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


/// An API client that adds offline features on top of the regular online API client.
///
/// + Note: Requires Algolia's Offline Core SDK. The `enableOfflineMode(...)` method must be called with a valid license
/// key prior to calling any offline-related method.
///
@objc public class OfflineClient : Client {
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
        rootDataDir = NSSearchPathForDirectoriesInDomains(.ApplicationSupportDirectory, .UserDomainMask, true).first! + "/algolia"
        super.init(appID: appID, apiKey: apiKey)
        userAgents.append(LibraryVersion(name: "AlgoliaSearchOfflineCore-iOS", version: sdk.versionString))
    }

    var sdk: ASSdk = ASSdk.sharedSdk()

    /// Path to directory where the local data is stored.
    /// Defaults to an `algolia` sub-directory inside the `Library/Application Support` directory.
    /// If you set it to another value, do so *before* calling `enableOfflineMode(...)`.
    ///
    /// + Warning: This directory will be explicitly excluded from iCloud/iTunes backup.
    ///
    @objc public var rootDataDir: String
    
    // NOTE: The build and search queues must be serial to prevent concurrent searches or builds on a given index, but
    // may be distinct because building can be done in parallel with search.
    //
    // NOTE: Although serialization is only strictly needed at the index level, we use global queues as a way to limit
    // resource consumption by the SDK.
    
    /// Queue used to build local indices in the background.
    let buildQueue = NSOperationQueue()
    
    /// Queue used to search local indices in the background.
    let searchQueue = NSOperationQueue()

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
        sdk.initWithLicenseData(licenseData)
        // NOTE: Errors reported by the core itself.
    }

    /// Create a new index.
    ///
    /// + Note: The offline client returns mirror-capable indices.
    ///
    @objc public override func getIndex(indexName: String) -> MirroredIndex {
        return MirroredIndex(client: self, indexName: indexName)
    }
    
    // MARK: - Utils
    
    /// Parse search results returned by the Offline Core into a (content, error) pair suitable for completion handlers.
    ///
    /// - parameter searchResults: Search results to parse.
    /// - returns: A (content, error) pair that can be passed to a `CompletionHandler`.
    ///
    internal static func parseSearchResults(searchResults: ASSearchResults) -> (content: [String: AnyObject]?, error: NSError?) {
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
}
