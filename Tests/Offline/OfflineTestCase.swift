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

import AlgoliaSearch
import Foundation
import XCTest


class OfflineTestCase: XCTestCase {
    var client: OfflineClient!
    
    let expectationTimeout: TimeInterval = 5
    
    override func setUp() {
        super.setUp()
        
        // Create client.
        client = OfflineClient(appID: String(reflecting: type(of: self)), apiKey: "NEVERMIND")
        client.enableOfflineMode(licenseKey: "AkUGAQH/3YXDBf+GxMAFABxDbJYBbWVudCBMZSBQcm92b3N0IChBbGdvbGlhKRhjb20uYWxnb2xpYS5GYWtlVW5pdFRlc3QwLgIVANNt9d4exv+oUPNno7XkXLOQozbYAhUAzVNYI6t/KQy1eEZECvYA0/ScpQU=")
        
        // Clean-up data from potential previous runs.
        if FileManager.default.fileExists(atPath: client.rootDataDir) {
            try! FileManager.default.removeItem(atPath: client.rootDataDir)
        }
    }
    
    override func tearDown() {
        super.tearDown()
    }
    
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
