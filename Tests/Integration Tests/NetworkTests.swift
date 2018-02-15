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
    let expectationTimeout: TimeInterval = 100
    
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
    
    /// In case of time-out on one host, check that the next host is tried.
    func testTimeout_OneHost() {
        let expectation = self.expectation(description: #function)
        session.responses["https://\(client.readHosts[0])/1/indexes"] = MockResponse(error: TIMEOUT_ERROR)
        session.responses["https://\(client.readHosts[1])/1/indexes"] = MockResponse(statusCode: 200, jsonBody: ["hello": "world"])
        client.listIndexes {
            (content, error) -> Void in
            XCTAssertNil(error)
            XCTAssertNotNil(content)
            XCTAssertEqual(content?["hello"] as? String, "world")
            expectation.fulfill()
        }
        self.waitForExpectations(timeout: expectationTimeout, handler: nil)
    }

    /// In case of time-out on all hosts, check that the error is returned.
    func testTimeout_AllHosts() {
        let expectation = self.expectation(description: #function)
        for i in 0..<client.writeHosts.count {
            session.responses["https://\(client.readHosts[i])/1/indexes"] = MockResponse(error: TIMEOUT_ERROR)
        }
        client.listIndexes {
            (content, error) -> Void in
            XCTAssertNil(content)
            XCTAssertNotNil(error)
            XCTAssertEqual((error! as NSError).domain, NSURLErrorDomain)
            XCTAssertEqual((error! as NSError).code, NSURLErrorTimedOut)
            expectation.fulfill()
        }
        self.waitForExpectations(timeout: expectationTimeout, handler: nil)
    }

    /// In case of DNS error on one host, check that the next host is tried.
    func testDNSError() {
        let expectation = self.expectation(description: #function)
        session.responses["https://\(client.readHosts[0])/1/indexes"] = MockResponse(error: NSError(domain: NSURLErrorDomain, code: NSURLErrorCannotFindHost, userInfo: nil))
        session.responses["https://\(client.readHosts[1])/1/indexes"] = MockResponse(statusCode: 200, jsonBody: ["hello": "world"])
        client.listIndexes {
            (content, error) -> Void in
            XCTAssertNil(error)
            XCTAssertNotNil(content)
            XCTAssertEqual(content?["hello"] as? String, "world")
            expectation.fulfill()
        }
        self.waitForExpectations(timeout: expectationTimeout, handler: nil)
    }
    
    /// In case of server error on one host, check that the next host is tried.
    func testServerError() {
        let expectation = self.expectation(description: #function)
        session.responses["https://\(client.readHosts[0])/1/indexes"] = MockResponse(statusCode: 500, jsonBody: ["message": "Mind your own business"])
        session.responses["https://\(client.readHosts[1])/1/indexes"] = MockResponse(statusCode: 200, jsonBody: ["hello": "world"])
        client.listIndexes {
            (content, error) -> Void in
            XCTAssertNil(error)
            XCTAssertNotNil(content)
            XCTAssertEqual(content?["hello"] as? String, "world")
            expectation.fulfill()
        }
        self.waitForExpectations(timeout: expectationTimeout, handler: nil)
    }
    
    /// In case of client error, check that the next host is *not* tried.
    func testClientError() {
        let expectation = self.expectation(description: #function)
        session.responses["https://\(client.readHosts[0])/1/indexes"] = MockResponse(statusCode: 403, jsonBody: ["message": "Mind your own business"])
        session.responses["https://\(client.readHosts[1])/1/indexes"] = MockResponse(statusCode: 200, jsonBody: ["hello": "world"])
        client.listIndexes {
            (content, error) -> Void in
            XCTAssertNil(content)
            XCTAssertNotNil(error)
            XCTAssert(error is HTTPError)
            let httpError = error as! HTTPError
            XCTAssertEqual(httpError.statusCode, 403)
            expectation.fulfill()
        }
        self.waitForExpectations(timeout: expectationTimeout, handler: nil)
    }
    
    /// Test when the server returns a success, but no JSON.
    func testEmptyResponse() {
        let expectation = self.expectation(description: #function)
        session.responses["https://\(client.readHosts[0])/1/indexes"] = MockResponse(statusCode: 200, data: Data())
        client.listIndexes {
            (content, error) -> Void in
            XCTAssertNil(content)
            XCTAssertNotNil(error)
            let nsError = error! as NSError
            XCTAssertEqual(NSCocoaErrorDomain, nsError.domain)
            XCTAssertEqual(NSPropertyListReadCorruptError, nsError.code)
            expectation.fulfill()
        }
        self.waitForExpectations(timeout: expectationTimeout, handler: nil)
    }

    /// Test when the server returns a success, but ill-formed JSON.
    func testIllFormedResponse() {
        let expectation = self.expectation(description: #function)
        session.responses["https://\(client.readHosts[0])/1/indexes"] = MockResponse(statusCode: 200, data: Data(base64Encoded: "U0hPVUxETk9UV09SSw==", options: [])!)
        client.listIndexes {
            (content, error) -> Void in
            XCTAssertNil(content)
            let nsError = error! as NSError
            XCTAssertEqual(NSCocoaErrorDomain, nsError.domain)
            XCTAssertEqual(NSPropertyListReadCorruptError, nsError.code)
            expectation.fulfill()
        }
        self.waitForExpectations(timeout: expectationTimeout, handler: nil)
    }
    

    /// Test when the server returns an error status code, but no JSON.
    func testEmptyErrorResponse() {
        let expectation = self.expectation(description: #function)
        session.responses["https://\(client.readHosts[0])/1/indexes"] = MockResponse(statusCode: 403, data: Data())
        session.responses["https://\(client.readHosts[1])/1/indexes"] = MockResponse(statusCode: 200, jsonBody: ["hello": "world"])
        client.listIndexes {
            (content, error) -> Void in
            XCTAssertNil(content)
            XCTAssertNotNil(error)
            let nsError = error! as NSError
            XCTAssertEqual(NSCocoaErrorDomain, nsError.domain)
            XCTAssertEqual(NSPropertyListReadCorruptError, nsError.code)
            expectation.fulfill()
        }
        self.waitForExpectations(timeout: expectationTimeout, handler: nil)
    }
    
    /// Test when the server returns an error status code and valid JSON, but no error message in the JSON.
    func testEmptyErrorMessage() {
        let expectation = self.expectation(description: #function)
        session.responses["https://\(client.readHosts[0])/1/indexes"] = MockResponse(statusCode: 403, jsonBody: ["something": "else"])
        session.responses["https://\(client.readHosts[1])/1/indexes"] = MockResponse(statusCode: 200, jsonBody: ["hello": "world"])
        client.listIndexes {
            (content, error) -> Void in
            XCTAssertNil(content)
            XCTAssertNotNil(error)
            XCTAssert(error is HTTPError)
            let httpError = error as! HTTPError
            XCTAssertEqual(403, httpError.statusCode)
            expectation.fulfill()
        }
        self.waitForExpectations(timeout: expectationTimeout, handler: nil)
    }

    /// Test that the status of down hosts is correctly remembered.
    func testHostStatus() {
        let expectation = self.expectation(description: #function)
        
        client.hostStatusTimeout = 3

        // First host is down, second is up.
        session.responses["https://\(client.readHosts[0])/1/indexes"] = MockResponse(error: TIMEOUT_ERROR)
        session.responses["https://\(client.readHosts[1])/1/indexes"] = MockResponse(statusCode: 200, jsonBody: ["from": "2nd host"])
        
        // Do a query: the 1st host will fail, and the client should transparently fallback to the 2nd host.
        client.listIndexes(completionHandler: {
            (content, error) -> Void in
            // Check that the response is successful and comes from the 2nd host.
            guard error == nil else { XCTFail(); expectation.fulfill(); return }
            XCTAssertEqual(content?["from"] as? String, "2nd host")
            
            // Check that the failing host's status has been remembered.
            guard let status = self.client.hostStatuses[self.client.readHosts[0]] else { XCTFail(); expectation.fulfill(); return }
            XCTAssertFalse(status.up)
            let statusTimestamp = status.lastModified

            // First host is up again.
            self.session.responses["https://\(self.client.readHosts[0])/1/indexes"] = MockResponse(statusCode: 200, jsonBody: ["from": "1st host"])
            
            // Do the same query again: the client should ignore the 1st host and target directly the 2nd host.
            self.client.listIndexes(completionHandler: {
                (content, error) -> Void in
                // Check that the response is successful and still comes from the 2nd host.
                guard error == nil else { XCTFail(); expectation.fulfill(); return }
                XCTAssertEqual(content?["from"] as? String, "2nd host")
                
                // Wait for the down host to be forgotten.
                Thread.sleep(forTimeInterval: self.client.hostStatusTimeout)
                
                // Do the same query again: the client should target the 1st host again.
                self.client.listIndexes(completionHandler: {
                    (content, error) -> Void in
                    // Check that the response is successful and comes from the 1st host.
                    guard error == nil else { XCTFail(); expectation.fulfill(); return }
                    XCTAssertEqual(content?["from"] as? String, "1st host")
                    
                    // Check that the host's status has been updated.
                    guard let status = self.client.hostStatuses[self.client.readHosts[0]] else { XCTFail(); expectation.fulfill(); return }
                    XCTAssertTrue(status.up)
                    XCTAssert(status.lastModified.compare(statusTimestamp) == .orderedDescending)
                    
                    expectation.fulfill()
                })
            })
        })
        self.waitForExpectations(timeout: expectationTimeout, handler: nil)
    }
}
