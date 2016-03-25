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


/// Tests for the network logic.
///
/// NOTE: We use `listIndexes()` to test, but we could use roughly any other function, since we don't really care
/// about the result.
///
class NetworkTests: XCTestCase {
    let expectationTimeout: NSTimeInterval = 100
    
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
        index = client.getIndex(FAKE_INDEX_NAME)
    }
    
    override func tearDown() {
        super.tearDown()
    }
    
    /// In case of time-out on one host, check that the next host is tried.
    func testTimeout_OneHost() {
        let expectation = expectationWithDescription(#function)
        session.responses["https://\(client.writeHosts[0])/1/indexes"] = MockResponse(statusCode: nil, headers: nil, jsonBody: nil, error: TIMEOUT_ERROR)
        session.responses["https://\(client.writeHosts[1])/1/indexes"] = MockResponse(statusCode: 200, headers: nil, jsonBody: ["hello": "world"], error: nil)
        client.listIndexes {
            (content, error) -> Void in
            XCTAssertNil(error)
            XCTAssertNotNil(content)
            XCTAssertEqual(content?["hello"] as? String, "world")
            expectation.fulfill()
        }
        waitForExpectationsWithTimeout(expectationTimeout, handler: nil)
    }

    /// In case of time-out on all hosts, check that the error is returned.
    func testTimeout_AllHosts() {
        let expectation = expectationWithDescription(#function)
        for i in 0..<client.writeHosts.count {
            session.responses["https://\(client.writeHosts[i])/1/indexes"] = MockResponse(statusCode: nil, headers: nil, jsonBody: nil, error: TIMEOUT_ERROR)
        }
        client.listIndexes {
            (content, error) -> Void in
            XCTAssertNil(content)
            XCTAssertNotNil(error)
            XCTAssert(error?.domain == NSURLErrorDomain)
            XCTAssert(error?.code == NSURLErrorTimedOut)
            expectation.fulfill()
        }
        waitForExpectationsWithTimeout(expectationTimeout, handler: nil)
    }

    /// In case of DNS error on one host, check that the next host is tried.
    func testDNSError() {
        let expectation = expectationWithDescription(#function)
        session.responses["https://\(client.writeHosts[0])/1/indexes"] = MockResponse(statusCode: nil, headers: nil, jsonBody: nil, error: NSError(domain: NSURLErrorDomain, code: NSURLErrorCannotFindHost, userInfo: nil))
        session.responses["https://\(client.writeHosts[1])/1/indexes"] = MockResponse(statusCode: 200, headers: nil, jsonBody: ["hello": "world"], error: nil)
        client.listIndexes {
            (content, error) -> Void in
            XCTAssertNil(error)
            XCTAssertNotNil(content)
            XCTAssertEqual(content?["hello"] as? String, "world")
            expectation.fulfill()
        }
        waitForExpectationsWithTimeout(expectationTimeout, handler: nil)
    }
    
    /// In case of server error on one host, check that the next host is tried.
    func testServerError() {
        let expectation = expectationWithDescription(#function)
        session.responses["https://\(client.writeHosts[0])/1/indexes"] = MockResponse(statusCode: 500, headers: nil, jsonBody: ["message": "Mind your own business"], error: nil)
        session.responses["https://\(client.writeHosts[1])/1/indexes"] = MockResponse(statusCode: 200, headers: nil, jsonBody: ["hello": "world"], error: nil)
        client.listIndexes {
            (content, error) -> Void in
            XCTAssertNil(error)
            XCTAssertNotNil(content)
            XCTAssertEqual(content?["hello"] as? String, "world")
            expectation.fulfill()
        }
        waitForExpectationsWithTimeout(expectationTimeout, handler: nil)
    }
    
    /// In case of client error, check that the next host is *not* tried.
    func testClientError() {
        let expectation = expectationWithDescription(#function)
        session.responses["https://\(client.writeHosts[0])/1/indexes"] = MockResponse(statusCode: 403, headers: nil, jsonBody: ["message": "Mind your own business"], error: nil)
        session.responses["https://\(client.writeHosts[1])/1/indexes"] = MockResponse(statusCode: 200, headers: nil, jsonBody: ["hello": "world"], error: nil)
        client.listIndexes {
            (content, error) -> Void in
            XCTAssertNil(content)
            XCTAssertNotNil(error)
            XCTAssertEqual(error?.domain, AlgoliaSearchErrorDomain)
            XCTAssertEqual(error?.code, 403)
            XCTAssertEqual(error?.userInfo[NSLocalizedDescriptionKey] as? String, "Mind your own business")
            expectation.fulfill()
        }
        waitForExpectationsWithTimeout(expectationTimeout, handler: nil)
    }
    
    /// Test when the server returns a success, but no JSON.
    func testEmptyResponse() {
        let expectation = expectationWithDescription(#function)
        session.responses["https://\(client.writeHosts[0])/1/indexes"] = MockResponse(statusCode: 200, headers: nil, jsonBody: nil, error: nil)
        client.listIndexes {
            (content, error) -> Void in
            XCTAssertNil(content)
            XCTAssertNotNil(error)
            XCTAssertEqual(error?.domain, AlgoliaSearchErrorDomain)
            XCTAssertEqual(error?.code, StatusCode.InvalidJSONResponse.rawValue)
            expectation.fulfill()
        }
        waitForExpectationsWithTimeout(expectationTimeout, handler: nil)
    }
    
    /// Test when the server returns an error status code, but no JSON.
    func testEmptyErrorResponse() {
        let expectation = expectationWithDescription(#function)
        session.responses["https://\(client.writeHosts[0])/1/indexes"] = MockResponse(statusCode: 403, headers: nil, jsonBody: nil, error: nil)
        session.responses["https://\(client.writeHosts[1])/1/indexes"] = MockResponse(statusCode: 200, headers: nil, jsonBody: ["hello": "world"], error: nil)
        client.listIndexes {
            (content, error) -> Void in
            XCTAssertNil(content)
            XCTAssertNotNil(error)
            XCTAssertEqual(error?.domain, AlgoliaSearchErrorDomain)
            XCTAssertEqual(error?.code, StatusCode.InvalidJSONResponse.rawValue)
            expectation.fulfill()
        }
        waitForExpectationsWithTimeout(expectationTimeout, handler: nil)
    }
    
    /// Test when the server returns an error status code and valid JSON, but no error message in the JSON.
    func testEmptyErrorMessage() {
        let expectation = expectationWithDescription(#function)
        session.responses["https://\(client.writeHosts[0])/1/indexes"] = MockResponse(statusCode: 403, headers: nil, jsonBody: ["something": "else"], error: nil)
        session.responses["https://\(client.writeHosts[1])/1/indexes"] = MockResponse(statusCode: 200, headers: nil, jsonBody: ["hello": "world"], error: nil)
        client.listIndexes {
            (content, error) -> Void in
            XCTAssertNil(content)
            XCTAssertNotNil(error)
            XCTAssertEqual(error?.domain, AlgoliaSearchErrorDomain)
            XCTAssertEqual(error?.code, 403)
            expectation.fulfill()
        }
        waitForExpectationsWithTimeout(expectationTimeout, handler: nil)
    }
    
    /// Test cancelling a request.
    func testCancel() {
        // NOTE: We use a search request here because it is more complex (in-memory cache involved).
        session.responses["https://\(client.writeHosts[0])/1/indexes/\(FAKE_INDEX_NAME)"] = MockResponse(statusCode: 200, headers: nil, jsonBody: ["hello": "world"], error: nil)
        let request1 = index.search(Query()) {
            (content, error) -> Void in
            XCTFail("Completion handler should not be called when a request has been cancelled")
        }
        request1.cancel()
        // Manually run the run loop for a while to leave a chance to the completion handler to be called.
        // WARNING: We cannot use `waitForExpectationsWithTimeout()`, because a timeout always results in failure.
        NSRunLoop.mainRunLoop().runUntilDate(NSDate().dateByAddingTimeInterval(3))
        
        // Run the test again, but this time the session won't actually cancel the (mock) network call.
        // This checks that the `Request` class still mutes the completion handler when cancelled.
        session.cancellable = false
        let request2 = index.search(Query()) {
            (content, error) -> Void in
            XCTFail("Completion handler should not be called when a request has been cancelled")
        }
        request2.cancel()
        NSRunLoop.mainRunLoop().runUntilDate(NSDate().dateByAddingTimeInterval(3))
    }
}
