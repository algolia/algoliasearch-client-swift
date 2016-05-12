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
/// NOTE: Requires Algolia's SDK. The `enableOfflineMode()` method must be called with a valid license key prior to
/// calling any offline-related method.
//
@objc public class OfflineClient : Client {
    /// Algolia Search initialization.
    ///
    /// - parameter appID: the application ID you have in your admin interface
    /// - parameter apiKey: a valid API key for the service
    @objc public override init(appID: String, apiKey: String) {
        buildQueue.name = "AlgoliaSearch-Build"
        buildQueue.maxConcurrentOperationCount = 1
        searchQueue.name = "AlgoliaSearch-Search"
        searchQueue.maxConcurrentOperationCount = 1
        rootDataDir = NSSearchPathForDirectoriesInDomains(.ApplicationSupportDirectory, .UserDomainMask, true).first! + "/algolia"
        super.init(appID: appID, apiKey: apiKey)
        headers["User-Agent"] = headers["User-Agent"]! + ";AlgoliaSearchOfflineCore-iOS \(sdk.versionString)"
    }

    var sdk: ASSdk = ASSdk.sharedSdk()

    /// Path to directory where the local data is stored.
    /// Defaults to an `algolia` sub-directory inside the `Library/Application Support` directory.
    /// If you set it to another value, do so *before* calling `enableOfflineMode()`.
    ///
    /// WARNING: This directory will be explicitly excluded from iCloud/iTunes backup.
    ///
    @objc public var rootDataDir: String
    
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
    /// NOTE: The offline client returns mirror-capable indices.
    @objc public override func getIndex(indexName: String) -> MirroredIndex {
        return MirroredIndex(client: self, indexName: indexName)
    }
}
