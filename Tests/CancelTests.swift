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
@testable import AlgoliaSearch


/// Tests for request cancellation.
///
class CancelTests: XCTestCase {
    let expectationTimeout: TimeInterval = 100
    let cancelTimeout: TimeInterval = 10
    
    var client: Client!
    var index: Index!
    
    let FAKE_APP_ID = "FAKE_APPID"
    let FAKE_API_KEY = "FAKE_API_KEY"
    let FAKE_INDEX_NAME = "FAKE_INDEX_NAME"
    
    let session: MockURLSession = MockURLSession()
    
    // Well-known errors:
    
    let TIMEOUT_ERROR = NSError(domain: NSURLErrorDomain, code: NSURLErrorTimedOut, userInfo: nil)
    
    override func setUp() {
        super.setUp()
        client = AlgoliaSearch.Client(appID: FAKE_APP_ID, apiKey: FAKE_API_KEY)
        client.session = session
        index = client.index(withName: FAKE_INDEX_NAME)
    }
    
    override func tearDown() {
        super.tearDown()
    }
    
    // Search is a composite operation.
    func testSearch() {
        // NOTE: We use a search request here because it is more complex (in-memory cache involved).
        session.responses["https://\(client.readHosts[0])/1/indexes/\(FAKE_INDEX_NAME)"] = MockResponse(statusCode: 200, jsonBody: ["hello": "world"])
        let request1 = index.search(Query()) {
            (content, error) -> Void in
            XCTFail("Completion handler should not be called when a request has been cancelled")
        }
        request1.cancel()
        // Manually run the run loop for a while to leave a chance to the completion handler to be called.
        // WARNING: We cannot use `self.waitForExpectations(timeout: )`, because a timeout always results in failure.
        RunLoop.main.run(until: Date().addingTimeInterval(cancelTimeout))
        XCTAssert(request1.isFinished)
        
        // Run the test again, but this time the session won't actually cancel the (mock) network call.
        // This checks that the `Request` class still mutes the completion handler when cancelled.
        session.cancellable = false
        let request2 = index.search(Query()) {
            (content, error) -> Void in
            XCTFail("Completion handler should not be called when a request has been cancelled")
        }
        request2.cancel()
        RunLoop.main.run(until: Date().addingTimeInterval(cancelTimeout))
        XCTAssert(request2.isFinished)
    }
    
    // `waitTask` is a composite operation, so it has its own cancellation logic.
    func testWaitTask() {
        // NOTE: We are faking network calls, so we don't need a real task ID!
        let taskID = 666
        session.responses["https://\(client.writeHosts[0])/1/indexes/\(FAKE_INDEX_NAME)/task/\(taskID)"] = MockResponse(statusCode: 200, jsonBody: ["status": "published", "pendingTask": false])
        let request1 = index.waitTask(withID: taskID) {
            (content, error) in
            XCTFail("Completion handler should not be called when a request has been cancelled")
        }
        request1.cancel()
        // Manually run the run loop for a while to leave a chance to the completion handler to be called.
        // WARNING: We cannot use `self.waitForExpectations(timeout: )`, because a timeout always results in failure.
        RunLoop.main.run(until: Date().addingTimeInterval(cancelTimeout))
        XCTAssert(request1.isFinished)

        session.responses["https://\(client.writeHosts[0])/1/indexes/\(FAKE_INDEX_NAME)/task/\(taskID)"] = MockResponse(statusCode: 200, jsonBody: ["status": "notPublished", "pendingTask": true])
        let request2 = index.waitTask(withID: taskID) {
            (content, error) in
            XCTFail("Completion handler should not be called when a request has been cancelled")
        }
        RunLoop.main.run(until: Date().addingTimeInterval(cancelTimeout))
        request2.cancel()
        RunLoop.main.run(until: Date().addingTimeInterval(cancelTimeout))
        XCTAssert(request2.isFinished)
    }
}
