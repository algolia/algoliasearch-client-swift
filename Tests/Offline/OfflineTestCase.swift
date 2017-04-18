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

import AlgoliaSearchOffline
import Foundation
import XCTest


class OfflineTestCase: XCTestCase {
    var client: OfflineClient!
    
    let expectationTimeout: TimeInterval = 5
    
    override func setUp() {
        super.setUp()
        
        // Create client.
        let appID = ProcessInfo.processInfo.environment["ALGOLIA_APPLICATION_ID"] ?? APP_ID
        let apiKey = ProcessInfo.processInfo.environment["ALGOLIA_API_KEY"] ?? API_KEY
        client = OfflineClient(appID: appID, apiKey: apiKey)
        client.enableOfflineMode(licenseKey: "AkwCAQH/pIS5Bf+zpLUFZBhBbGdvbGlhIERldmVsb3BtZW50IFRlYW0kY29tLmFsZ29saWEuQWxnb2xpYVNlYXJjaE9mZmxpbmVDb3JlMC0CFQCSwJj+WYy+dsAvx5hfEcJSpBgF0wIUOYM+9+UMzdAtu1s31jz1qh0jeWo=")
        
        // Clean-up data from potential previous runs.
        if FileManager.default.fileExists(atPath: client.rootDataDir) {
            try! FileManager.default.removeItem(atPath: client.rootDataDir)
        }
    }
    
    override func tearDown() {
        super.tearDown()
    }
    
    let settings: [String: Any] = [
        "searchableAttributes": ["name", "kind", "series"],
        "attributesForFaceting": ["searchable(series)"]
    ]
    
    let objects: [String: JSONObject] = [
        "snoopy": [
            "objectID": "1",
            "name": "Snoopy",
            "kind": "dog",
            "born": 1967,
            "series": "Peanuts"
        ],
        "woodstock": [
            "objectID": "2",
            "name": "Woodstock",
            "kind": "bird",
            "born": 1970,
            "series": "Peanuts"
        ],
    ]
}
