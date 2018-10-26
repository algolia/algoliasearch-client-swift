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

@testable import InstantSearchClient
import PromiseKit
import XCTest

class ClientTests: OnlineTestCase {
  func testListIndexes() {
    let expectation = self.expectation(description: "testListIndexes")
    let mockObject = ["city": "San Francisco", "objectID": "a/go/?à"]

    func checkIndexes(_ indexes: [[String: Any]]) {
      let index = indexes.filter({ $0["name"] as? String == self.index.name })
      XCTAssertNotNil(index, "List indexes failed")
    }

    let promise = firstly {
      self.addObject(mockObject)
    }.then { object in
      self.waitTask(object)
    }.then { _ in
      self.listIndexes()
    }

    promise.then { indexesContent in
      checkIndexes(indexesContent["items"] as! [[String: Any]])
    }.catch { error in
      XCTFail("Error : \(error)")
    }.always {
      expectation.fulfill()
    }

    waitForExpectations(timeout: expectationTimeout, handler: nil)
  }

  func testMoveIndex() {
    let expectation = self.expectation(description: "testMoveIndex")
    let object = ["city": "San Francisco", "objectID": "a/go/?à"]
    let dstIndex = client.index(withName: safeIndexName("algol?à-swift2"))

    let promise = firstly {
      self.addObject(object)
    }.then { object in
      self.waitTask(object)
    }

    let promise2 = promise.then { _ in
      self.moveIndex(from: self.index.name, to: safeIndexName("algol?à-swift2"))
    }.then { object in
      self.waitTask(object)
    }

    let promise3 = promise2.then { _ in
      self.query(index: dstIndex)
    }.then { object in
      assertEqual(object)
    }.then { _ in
      self.deletexIndex(safeIndexName("algol?à-swift2"))
    }

    promise3.catch { error in
      XCTFail("Error : \(error)")
    }.always {
      expectation.fulfill()
    }

    func assertEqual(_ content: [String: Any]) {
      let nbHits = content["nbHits"] as! Int
      XCTAssertEqual(nbHits, 1, "Wrong number of object in the index")
    }

    waitForExpectations(timeout: expectationTimeout, handler: nil)
  }

  func testCopyIndex() {
    let expectation = self.expectation(description: "testCopyIndex")

    let object = ["city": "San Francisco", "objectID": "a/go/?à"]
    let dstIndex = client.index(withName: safeIndexName("algol?à-swift2"))

    let promise = firstly {
      self.addObject(object)
    }.then { object in
      self.waitTask(object)
    }

    let promise2 = promise.then { _ in
      self.copyIndex(from: self.index.name, to: safeIndexName("algol?à-swift2"))
    }.then { object in
      self.waitTask(object)
    }

    let promise3 = promise2.then { _ in
      self.query()
    }.then { object in
      assertEqual(object)
    }

    let promise4 = promise3.then { _ in
      self.query(index: dstIndex)
    }.then { object in
      assertEqual(object)
    }.then { _ in
      self.deletexIndex(safeIndexName("algol?à-swift2"))
    }

    promise4.catch { error in
      XCTFail("Error : \(error)")
    }.always {
      expectation.fulfill()
    }

    func assertEqual(_ content: [String: Any]) {
      let nbHits = content["nbHits"] as! Int
      XCTAssertEqual(nbHits, 1, "Wrong number of object in the index")
    }

    waitForExpectations(timeout: expectationTimeout, handler: nil)
  }

  func testMultipleQueries() {
    let expectation = self.expectation(description: "testMultipleQueries")
    let object = ["city": "San Francisco"]
    let queries = [IndexQuery(index: self.index, query: Query())]

    let promise = firstly {
      self.addObject(object)
    }.then { object in
      self.waitTask(object)
    }

    let promise2 = promise.then { _ in
      self.clientMultipleQueries(queries)
    }.then { (content) -> Promise<Void> in
      let items = content["results"] as! [[String: Any]]
      let nbHits = items[0]["nbHits"] as! Int
      XCTAssertEqual(nbHits, 1, "Wrong number of object in the index")
      return Promise()
    }

    promise2.catch { error in
      XCTFail("Error : \(error)")
    }.always {
      expectation.fulfill()
    }

    waitForExpectations(timeout: expectationTimeout, handler: nil)
  }

  func testMultipleQueries_stopIfEnoughMatches() {
    let expectation = self.expectation(description: "testMultipleQueries")
    let object = ["city": "San Francisco"]
    let query = Query()
    query.hitsPerPage = 1
    let queries = [
      IndexQuery(index: self.index, query: query),
      IndexQuery(index: self.index, query: query),
    ]

    let promise = firstly {
      self.addObject(object)
    }.then { object in
      self.waitTask(object)
    }

    let promise2 = promise.then { _ in
      self.clientMultipleQueriesStopIfEnoughMatches(queries)
    }.then { (content) -> Promise<Void> in
      let items = content["results"] as! [[String: Any]]
      XCTAssert(items.count == 2) // each query should return an item...
      XCTAssertEqual(items[0]["nbHits"] as? Int, 1, "Wrong number of object in the index")
      // ... but the second query should not have been processed
      XCTAssertEqual(items[1]["processed"] as? Bool, false)
      XCTAssertEqual(items[1]["nbHits"] as? Int, 0, "Wrong number of object in the index")
      return Promise()
    }

    promise2.catch { error in
      XCTFail("Error : \(error)")
    }.always {
      expectation.fulfill()
    }

    waitForExpectations(timeout: expectationTimeout, handler: nil)
  }

  func testHeaders() {
    // Make a call with a valid API key.
    let expectation1 = expectation(description: "Valid API key")
    client.listIndexes {
      (_, error) -> Void in
      XCTAssertNil(error)
      expectation1.fulfill()
    }

    // Override the API key and check the call fails.
    client.headers["X-Algolia-API-Key"] = "NOT_A_VALID_API_KEY"
    let expectation2 = expectation(description: "Invalid API key")
    client.listIndexes {
      (_, error) -> Void in
      XCTAssertNotNil(error)
      expectation2.fulfill()
    }

    // Restore the valid API key (otherwise tear down will fail).
    client.headers["X-Algolia-API-Key"] = client.apiKey

    waitForExpectations(timeout: expectationTimeout, handler: nil)
  }

  func testLongAPIKey() {
    let validAPIKey = client.apiKey
    defer {
      // Restore the valid API key (otherwise tear down will fail).
      self.client.headers[AbstractClient.xAlgoliaAPIKey] = validAPIKey
    }

    // Override the API key and check the call fails.
    let longAPIKey = "d6NdYTE1nFai7Pwt5wVmuRzLx8flSvFMq6O7HL5UFhQbfUfZQREp8gRYplxgdQFsejcstDhBIcbYkRqzED9r2gVaj3IQSVDRVxEWDGsZu3wuq4eRUvgy3lPLDK8spwHRKLFCunvvnpzg48UT8s4uSVA268vOYT3JjHPexrRNxItFep4HKyKtysKWokvaASODJzxZluCvxpnG0L79MLd75bqdzqgaCGXdwIkRseUytphdxjHsyfLotYPFAysnDKrgXJQIKEGSMTH6EHXDvOPzBX5vlloMW72y9hB6iHbeqq2Tv7WvUZDuAfAZXnafz58M2LJHkOljD9FarDmzwlTjUiOtci5ObPW9E86Cy2tGMGXJarJXbDRJyZbWGAnD8Zqjy3Ny1MPCqbE15l9rCArRUOQrV3XGsxSHuDfXFEOkcMwwp63pus7jSWDg6Ntonbm82NeUMVqJQhnpOLeEKGj6YLxtdrcC7S38YaPyK32iDpI8PWPF73sHGRCGP427A6IflPhfmHGpuGq1DQZqKAWQ1I5RJJkjmoyxkplsUwlG1DvASccSsioBnHR3KrlkilvKU5MDTI62nbGsVVlmNftTFZIp"
    client.apiKey = longAPIKey

    let request = client.newRequest(method: .POST, path: "/dummyPath", body: [:], hostnames: ["dummyHost1"])
    XCTAssertNil(request.headers![AbstractClient.xAlgoliaAPIKey])
    XCTAssertNotNil(request.jsonBody)

    guard let jsonBody = request.jsonBody, let apiKey = jsonBody[AbstractClient.bodyApiKey] as? String else {
      XCTFail("The long api should be in the body")
      return
    }
    XCTAssertEqual(longAPIKey, apiKey)
  }

  func testBatch() {
    let expectation = self.expectation(description: #function)
    let actions = [
      [
        "indexName": index.name,
        "action": "addObject",
        "body": ["city": "San Francisco"],
      ],
      [
        "indexName": index.name,
        "action": "addObject",
        "body": ["city": "Paris"],
      ],
    ]

    let promise = firstly {
      self.clientBatch(actions)
    }.then { object in
      self.batchWaitTask(object)
    }

    let promise2 = promise.then { _ in
      self.query("Francisco")
    }.then { object in
      XCTAssertEqual(object["nbHits"] as? Int, 1)
    }

    promise2.catch { error in
      XCTFail("Error : \(error)")
    }.always {
      expectation.fulfill()
    }

    waitForExpectations(timeout: expectationTimeout, handler: nil)
  }

  func testIsAlive() {
    let expectation = self.expectation(description: #function)

    client.isAlive { (content, error) -> Void in
      if let error = error {
        XCTFail("\(error)")
      } else {
        XCTAssertEqual(content?["message"] as? String, "server is alive")
      }
      expectation.fulfill()
    }
    waitForExpectations(timeout: expectationTimeout, handler: nil)
  }

  func testIndexNameWithSpace() {
    let expectation = self.expectation(description: #function)
    client.deleteIndex(withName: "Index with spaces", completionHandler: { (_, error) -> Void in
      if error != nil {
        XCTFail(error!.localizedDescription)
      }
      expectation.fulfill()
    })
    waitForExpectations(timeout: expectationTimeout, handler: nil)
  }

  func testUserAgentHeader() {
    // Test that the initial value of the header is correct.
    NSLog("User-Agent 1: \(Client.userAgentHeader!)")
    XCTAssert(Client.userAgentHeader!.range(of: "^Algolia for Swift \\([0-9.]+\\); (iOS|macOS|tvOS) \\([0-9.]+\\)$", options: .regularExpression) != nil)

    // Test equality comparison on the `LibraryVersion` class.
    XCTAssertEqual(LibraryVersion(name: "XYZ", version: "7.8.9"), LibraryVersion(name: "XYZ", version: "7.8.9"))
    XCTAssertNotEqual(LibraryVersion(name: "XYZ", version: "7.8.9"), LibraryVersion(name: "XXX", version: "6.6.6"))

    // Test adding a user agent.
    Client.addUserAgent(LibraryVersion(name: "ABC", version: "1.2.3"))
    let userAgentHeader = Client.userAgentHeader!
    NSLog("User-Agent 2: \(Client.userAgentHeader!)")
    XCTAssert(Client.userAgentHeader!.range(of: "^Algolia for Swift \\([0-9.]+\\); (iOS|macOS|tvOS) \\([0-9.]+\\); ABC \\(1.2.3\\)$", options: .regularExpression) != nil)
    // Test that adding the same user agent a second time is a no-op.
    Client.addUserAgent(LibraryVersion(name: "ABC", version: "1.2.3"))
    XCTAssert(Client.userAgentHeader! == userAgentHeader)
  }

  func testReusingIndices() {
    let indexName = "name"
    let initialCount = client.indices.count // another index is created during set up

    autoreleasepool {
      // Create twice the same index and verify that it is re-used.
      let index1: Index? = client.index(withName: indexName)
      XCTAssertEqual(initialCount + 1, client.indices.count)
      let index2: Index? = client.index(withName: indexName)
      XCTAssertEqual(initialCount + 1, client.indices.count)
      XCTAssert(index1 === index2)
    }
    // Verify that the index instance has been destroyed.
    // NOTE: It may (and probably will) still be in the map, so we cannot rely on the count.
    let memorizedIndex = client.indices.object(forKey: indexName as NSString)
    XCTAssertNil(memorizedIndex)
  }

  // TODO: algolia.biz is down, making this UT fail all the time. Put it back up when .biz is up
  /// Test that the status of down hosts is correctly remembered.
//    func testHostStatus() {
//        let expectation = self.expectation(description: #function)
//
//        client.readHosts[0] = uniqueAlgoliaBizHost()
//        let maxIterations = 10
//        let requestTimeout = client.searchTimeout
//        client.hostStatusTimeout = requestTimeout * (Double(maxIterations) * 2) // ensure that the status will be kept long enough
//
//        let startTime = Date()
//        client.listIndexes(completionHandler: {
//            (content, error) -> Void in
//            if let error = error {
//                XCTFail("\(error)")
//                expectation.fulfill()
//                return
//            }
//            // Check that the timeout has been hit.
//            let stopTime = Date()
//            let duration = stopTime.timeIntervalSince(startTime)
//            XCTAssert(duration >= requestTimeout)
//
//            // Check that the failing host's status has been remembered.
//            guard let status = self.client.hostStatuses[self.client.readHosts[0]] else { XCTFail(); expectation.fulfill(); return }
//            XCTAssertFalse(status.up)
//
//            // Check that further iterations do not hit the timeout.
//            func doTest(iteration: Int) {
//                self.client.listIndexes(completionHandler: {
//                    (content, error) -> Void in
//                    if let error = error {
//                        XCTFail("\(error)")
//                        expectation.fulfill()
//                        return
//                    }
//                    if iteration + 1 < maxIterations {
//                        doTest(iteration: iteration + 1)
//                    } else {
//                        // Check that the timeout has not been hit for all requests.
//                        let stopTime = Date()
//                        let duration = stopTime.timeIntervalSince(startTime)
//                        XCTAssert(duration < requestTimeout * Double(maxIterations + 1))
//                        expectation.fulfill()
//                    }
//                })
//            }
//            doTest(iteration: 0)
//        })
//        self.waitForExpectations(timeout: expectationTimeout, handler: nil)
//    }

  /// Test that we take reachability into account when making requests, unless `useReachability` is set to false.
  ///
  func testUseReachability() {
    let expectation = self.expectation(description: #function)

    // Pretend that we are offline.
    let reachability = MockNetworkReachability()
    client.reachability = reachability
    reachability.reachable = false

    // Check that requests fail right away.
    let startTime = Date()
    client.listIndexes { _, error in
      let stopTime = Date()
      let duration = stopTime.timeIntervalSince(startTime)
      guard let error = error as NSError? else { XCTFail("Request should have failed"); expectation.fulfill(); return }
      XCTAssertEqual(NSURLErrorDomain, error.domain)
      XCTAssertEqual(NSURLErrorNotConnectedToInternet, error.code)
      XCTAssert(duration < min(self.client.searchTimeout, self.client.timeout)) // check that we failed without waiting for the timeout

      // Choose to ignore reachability now, and check that requests are performed, although network is supposedly down.
      self.client.useReachability = false
      self.client.listIndexes { _, error in
        // The request should work, since we are actually connected (fake reachability)!
        XCTAssertNil(error)
        expectation.fulfill()
      }
    }
    waitForExpectations(timeout: expectationTimeout, handler: nil)
  }

  /// Test that the completion queue is used.
  ///
  func testCompletionQueue() {
    let expectation = self.expectation(description: #function)
    let operationQueue = OperationQueue()
    client.listIndexes { _, _ in
      XCTAssert(OperationQueue.current == OperationQueue.main)

      self.client.completionQueue = operationQueue
      self.client.listIndexes { _, _ in
        XCTAssert(OperationQueue.current != OperationQueue.main)
        XCTAssert(OperationQueue.current == operationQueue)
        expectation.fulfill()
      }
    }
    waitForExpectations(timeout: expectationTimeout, handler: nil)
  }

  /// Test that headers from the request options are used.
  ///
  func testRequestOptionsHeaders() {
    let expectation = self.expectation(description: #function)
    let requestOptions = RequestOptions()
    requestOptions.headers["X-Algolia-API-Key"] = "ThisIsNotAValidAPIKey"
    client.listIndexes(requestOptions: requestOptions) { _, error in
      XCTAssertNotNil(error)
      XCTAssert(error is HTTPError)
      XCTAssertEqual((error as! HTTPError).statusCode, 403)
      expectation.fulfill()
    }
    waitForExpectations(timeout: expectationTimeout, handler: nil)
  }

  /// Test that URL parameters from the request options are used.
  ///
  func testRequestOptionsURLParameters() {
    let expectation1 = expectation(description: #function)
    let expectation2 = expectation(description: #function)
    // Listing indices without options should return at least one item.
    client.listIndexes { content, error in
      XCTAssertNil(error)
      XCTAssertNotNil(content)
      XCTAssert(!(content!["items"] as! [[String: Any]]).isEmpty)
      expectation1.fulfill()
    }
    // Listing indices with a `page` URL parameter very high should return no items.
    let requestOptions = RequestOptions()
    requestOptions.urlParameters["page"] = "666"
    client.listIndexes(requestOptions: requestOptions) { content, error in
      XCTAssertNil(error)
      XCTAssertNotNil(content)
      XCTAssert((content!["items"] as! [[String: Any]]).isEmpty)
      expectation2.fulfill()
    }
    waitForExpectations(timeout: expectationTimeout, handler: nil)
  }
}
