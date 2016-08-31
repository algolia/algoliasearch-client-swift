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
#if false
    import XCTest // disabled so far
#endif

// ----------------------------------------------------------------------
// WARNING
// ----------------------------------------------------------------------
// Could not find a way to have proper unit tests work for the offline
// mode. Even if we use Cocoapods to draw the dependency on the Offline
// Core, the build fails with a weird error.
// => I am emulating tests in an iOS app so far.
// ----------------------------------------------------------------------

class CustomExpectation {
    let testCase: OfflineTestCase
    let description: String
    var fulfilled: Bool = false
    
    init(testCase: OfflineTestCase, description: String) {
        self.testCase = testCase
        self.description = description
    }
    
    func fulfill() {
        fulfilled = true
        NSLog("[TEST] OK: \(description)")
    }
    
    func kill() {
        if fulfilled {
            return
        }
        NSLog("[TEST] KO: \(description)")
    }
}

class OfflineTestCase /*: XCTestCase */ {
    var client: OfflineClient!
    var tests: [() -> ()]!
    var expectations: [CustomExpectation] = []
    
    let expectationTimeout: NSTimeInterval = 5
    
    init() {
    }
    
    /* override */ func setUp() {
        // super.setUp()
        if client == nil {
            client = OfflineClient(appID: String(self.dynamicType), apiKey: "NEVERMIND")
            client.enableOfflineMode("AkUGAQH/3YXDBf+GxMAFABxDbJYBbWVudCBMZSBQcm92b3N0IChBbGdvbGlhKRhjb20uYWxnb2xpYS5GYWtlVW5pdFRlc3QwLgIVANNt9d4exv+oUPNno7XkXLOQozbYAhUAzVNYI6t/KQy1eEZECvYA0/ScpQU=")
        }
    }
    
    /* override */ func tearDown() {
        // super.tearDown()
    }
    
    let objects: [String: [String: AnyObject]] = [
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
    
    func test() {
        for aTest in tests {
            setUp()
            aTest()
            tearDown()
        }
    }
    
    func expectationWithDescription(description: String) -> CustomExpectation {
        let expectation = CustomExpectation(testCase: self, description: description)
        expectations.append(expectation)
        return expectation
    }
    
    func waitForExpectationsWithTimeout(timeout: NSTimeInterval, handler: (()->())?) {
        let expectationsToWait = expectations
        expectations.removeAll()
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, Int64(timeout * Double(NSEC_PER_SEC))), dispatch_get_main_queue()) {
            for expectation in expectationsToWait {
                expectation.kill()
            }
        }
    }
}
