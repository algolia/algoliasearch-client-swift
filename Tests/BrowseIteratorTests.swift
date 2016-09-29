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

import XCTest
import AlgoliaSearch

class BrowseIteratorTests: OnlineTestCase {
    let cancelTimeout: TimeInterval = 10
    
    override func setUp() {
        super.setUp()
        
        // Add a bunch of objects to the index.
        let expectation = self.expectation(description: "Add objects")
        var objects = [JSONObject]()
        for i in 0...1500 {
            objects.append(["i": i])
        }
        index.addObjects(objects) { (content, error) -> Void in
            if error != nil {
                XCTFail("Error during addObjects: \(error!)")
                expectation.fulfill()
            } else {
                self.index.waitTask(withID: content!["taskID"] as! Int) { (content, error) -> Void in
                    if error != nil {
                        XCTFail("Error during waitTask: \(error!)")
                    }
                    expectation.fulfill()
                }
            }
        }
        self.waitForExpectations(timeout: expectationTimeout, handler: nil)
    }
    
    func testNominal() {
        let expectation = self.expectation(description: #function)
        var pageCount = 0
        let iterator = BrowseIterator(index: index, query: Query()) { (iterator, content, error) in
            pageCount += 1
            if error != nil {
                XCTFail("Error encountered: \(error!)")
            }
            if pageCount == 1 {
                XCTAssertTrue(iterator.hasNext())
            } else if pageCount == 2 {
                XCTAssertFalse(iterator.hasNext())
                expectation.fulfill()
            }
        }
        iterator.start()
        self.waitForExpectations(timeout: expectationTimeout, handler: nil)
    }

    func testCancel() {
        var pageCount = 0
        let iterator = BrowseIterator(index: index, query: Query()) { (iterator, content, error) in
            if error != nil {
                XCTFail("Error encountered: \(error!)")
            } else {
                pageCount += 1
                if pageCount == 1 {
                    iterator.cancel()
                } else if pageCount >= 2 {
                    XCTFail("Should never reach this point")
                }
            }
        }
        iterator.start()
        // Manually run the run loop for a while to leave a chance to the completion handler to be called.
        // WARNING: We cannot use `self.waitForExpectations(timeout: )`, because a timeout always results in failure.
        RunLoop.main.run(until: Date().addingTimeInterval(cancelTimeout))
    }

}
