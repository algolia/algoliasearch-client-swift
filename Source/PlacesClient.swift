//
//  Copyright (c) 2016 Algolia
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

import Foundation


/// Client for [Algolia Places](https://community.algolia.com/places/).
///
@objc public class PlacesClient : AbstractClient {
    // MARK: Properties
    
    /// Algolia application ID.
    @objc public var appID: String? { return _appID }
    
    /// Algolia API key.
    @objc public var apiKey: String? {
        get { return _apiKey }
        set { _apiKey = newValue }
    }
    
    // MARK: Initialization
    
    /// Create a new Algolia Places client.
    ///
    /// + Note: You may omit the authentication credentials, but
    ///
    /// - parameter appID:  [optional] The application ID (available in your Algolia Dashboard).
    /// - parameter apiKey: [optional] A valid API key for the service.
    ///
    @objc(initWithOptionalAppID:apiKey:) // moved away to avoid conflict with public initializer below
    internal init(appID: String?, apiKey: String?) {
        // Initialize hosts to their default values.
        //
        // NOTE: The host list comes in two parts:
        //
        // 1. The fault-tolerant, load-balanced DNS host.
        // 2. The non-fault-tolerant hosts. Those hosts must be randomized to ensure proper load balancing in case
        //    of the first host's failure.
        //
        let fallbackHosts = [
            "places-1.algolianet.com",
            "places-2.algolianet.com",
            "places-3.algolianet.com"
        ].shuffle()
        let readHosts = [ "places-dsn.algolia.net" ] + fallbackHosts
        super.init(appID: appID, apiKey: apiKey, readHosts: readHosts, writeHosts: [])
    }
    
    /// Create a new authenticated Algolia Places client.
    ///
    /// - parameter appID:  The application ID (available in your Algolia Dashboard).
    /// - parameter apiKey: A valid API key for the service.
    ///
    @objc public convenience init(appID: String, apiKey: String) {
        self.init(appID: appID, apiKey: apiKey)
    }

    /// Create a new unauthenticated Algolia Places client.
    ///
    /// + Note: The rate limit for the unauthenticated API is significantly lower than for the authenticated API.
    ///
    @objc public convenience init() {
        self.init(appID: nil, apiKey: nil)
    }
    
    // MARK: - Operations
    
    /// Search for places.
    ///
    /// - parameter params: Query parameters.
    /// - parameter completionHandler: Completion handler to be notified of the request's outcome.
    /// - returns: A cancellable operation.
    ///
    @objc(search:completionHandler:)
    @discardableResult public func search(_ params: PlacesQuery, completionHandler: @escaping CompletionHandler) -> Operation {
        let request = ["params": params.build()]
        return performHTTPQuery(path: "1/places/query", method: .POST, body: request, hostnames: self.readHosts, isSearchQuery: true, completionHandler: completionHandler)
    }
}
