//
//  Copyright (c) 2015-2016 Algolia
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

class OfflineTests: XCTestCase {
    
    let expectationTimeout: NSTimeInterval = 100
    
    var client: OfflineClient!
    var index: MirroredIndex!
    
    let FAKE_APP_ID = "FAKE_APPID"
    let FAKE_API_KEY = "FAKE_API_KEY"
    let FAKE_INDEX_NAME = "FAKE_INDEX_NAME"

    /// Fake session used to mock network calls.
    let session: MockURLSession = MockURLSession()
    
    override func setUp() {
        super.setUp()
        client = OfflineClient(appID: FAKE_APP_ID, apiKey: FAKE_API_KEY)
        index = client.getIndex(FAKE_INDEX_NAME)
    }
    
    override func tearDown() {
        super.tearDown()
    }
    
    // MARK: Sync

    func testSync() {
        // TODO: To be implemented
    }

    // MARK: Search
    
    func testSearchOnlineOnly() {
        // TODO: To be implemented
    }
    
    func testSearchOfflineOnly() {
        // TODO: To be implemented
    }
    
    func testSearchFallback() {
        // TODO: To be implemented
    }
    
    // MARK: Init
    
    func testLicense() {
        // TODO: To be implemented
    }
}
