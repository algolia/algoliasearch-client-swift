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

import AlgoliaSearchSDK
import Foundation


/// An API client that adds offline features on top of the regular online API client.
///
/// NOTE: Requires Algolia's SDK. The `enableOfflineMode()` method must be called with a valid license key prior to
/// calling any offline-related method.
//
public class OfflineClient : Client {
    /// Algolia Search initialization.
    ///
    /// - parameter appID: the application ID you have in your admin interface
    /// - parameter apiKey: a valid API key for the service
    /// - parameter queryParameters: value of the header X-Algolia-QueryParameters
    /// - parameter tagFilters: value of the header X-Algolia-TagFilters (deprecated)
    /// - parameter userToken: value of the header X-Algolia-UserToken
    /// - parameter hostnames: the list of hosts that you have received for the service
    public override init(appID: String, apiKey: String, queryParameters: String? = nil, tagFilters: String? = nil, userToken: String? = nil, hostnames: [String]? = nil) {
        buildQueue.name = "AlgoliaSearch-Build"
        buildQueue.maxConcurrentOperationCount = 1
        searchQueue.name = "AlgoliaSearch-Search"
        searchQueue.maxConcurrentOperationCount = 1
        super.init(appID: appID, apiKey: apiKey, queryParameters: queryParameters, tagFilters: tagFilters, userToken: userToken, hostnames: hostnames)
    }

    var sdk: ASSdk = ASSdk.sharedSdk()
    var rootDataDir: String?
    
    /// Queue used to build local indices in the background.
    let buildQueue = NSOperationQueue()
    /// Queue used to search local indices in the background.
    let searchQueue = NSOperationQueue()

    /// Enable the offline mode.
    ///
    /// - parameter licenseData: license for Algolia's SDK
    ///
    public func enableOfflineMode(licenseData: String) {
        // Create the cache directory.
        do {
            self.rootDataDir = NSSearchPathForDirectoriesInDomains(.CachesDirectory, .UserDomainMask, true).first! + "/algolia"
            try NSFileManager.defaultManager().createDirectoryAtPath(self.rootDataDir!, withIntermediateDirectories: true, attributes: nil)
        } catch _ {
            NSLog("Error: could not create cache directory '%@'", self.rootDataDir!)
        }
        
        // Init the SDK.
        sdk.initWithLicenseData(licenseData)
        // TODO: Report any error.
    }

    /// Create a new index.
    /// NOTE: The offline client returns mirror-capable indices.
    public override func getIndex(indexName: String) -> MirroredIndex {
        return MirroredIndex(client: self, indexName: indexName)
    }
}
