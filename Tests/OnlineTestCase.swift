//
//  Copyright (c) 2015 Algolia
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
import XCTest


/// Abstract base class for online test cases.
///
class OnlineTestCase: XCTestCase {
    var expectationTimeout: TimeInterval = 100
    
    var client: Client!
    var index: Index!
    
    override func setUp() {
        super.setUp()
        
        // Init client.
        let appID = ProcessInfo.processInfo.environment["ALGOLIA_APPLICATION_ID"] ?? APP_ID
        let apiKey = ProcessInfo.processInfo.environment["ALGOLIA_API_KEY"] ?? API_KEY
        client = AlgoliaSearch.Client(appID: appID, apiKey: apiKey)
        
        // Init index.
        // NOTE: We use a different index name for each test function.
        let className = String(reflecting: type(of: self)).components(separatedBy: ".").last!
        let functionName = self.invocation!.selector.description
        let indexName = "\(className).\(functionName)"
        index = client.index(withName: safeIndexName(indexName))
        
        // Delete the index.
        // Although it's not shared with other test functions, it could remain from a previous execution.
        let expectation = self.expectation(description: "Delete index")
        client.deleteIndex(withName: index.name) { (content, error) -> Void in
            XCTAssertNil(error)
            expectation.fulfill()
        }
        self.waitForExpectations(timeout: expectationTimeout, handler: nil)
    }
    
    override func tearDown() {
        super.tearDown()
        
        let expectation = self.expectation(description: "Delete index")
        client.deleteIndex(withName: index.name) { (content, error) -> Void in
            XCTAssertNil(error)
            expectation.fulfill()
        }
        self.waitForExpectations(timeout: expectationTimeout, handler: nil)
    }
}
