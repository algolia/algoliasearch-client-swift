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

import InstantSearchClient
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
    let appID = Bundle(for: type(of: self)).object(forInfoDictionaryKey: "ALGOLIA_APPLICATION_ID") as? String ?? ""
    let apiKey = Bundle(for: type(of: self)).object(forInfoDictionaryKey: "ALGOLIA_API_KEY") as? String ?? ""
    client = InstantSearchClient.Client(appID: appID, apiKey: apiKey)

    // Init index.
    // NOTE: We use a different index name for each test function.
    let className = String(reflecting: type(of: self)).components(separatedBy: ".").last!
    let functionName = invocation!.selector.description
    let indexName = "\(className).\(functionName)"
    index = client.index(withName: safeIndexName(indexName))

    // Delete the index.
    // Although it's not shared with other test functions, it could remain from a previous execution.
    let expectation = self.expectation(description: "Delete index")
    client.deleteIndex(withName: index.name) { (content, error) -> Void in
      if let error = error {
        XCTFail(error.localizedDescription)
        return
      }
      guard let content = content, let taskID = content["taskID"] as? Int else {
        XCTFail("Task ID not returned for deleteIndex")
        return
      }
      self.index.waitTask(withID: taskID) { _, error in
        XCTAssertNil(error)
        expectation.fulfill()
      }
    }
    waitForExpectations(timeout: expectationTimeout, handler: nil)
  }

  override func tearDown() {
    super.tearDown()

    let expectation = self.expectation(description: "Delete index")
    client.deleteIndex(withName: index.name) { (_, error) -> Void in
      XCTAssertNil(error)
      expectation.fulfill()
    }
    waitForExpectations(timeout: expectationTimeout, handler: nil)
  }
}
