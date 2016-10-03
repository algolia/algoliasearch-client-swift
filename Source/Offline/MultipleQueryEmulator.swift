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

import Foundation


/// Emulates multiple queries.
///
internal class MultipleQueryEmulator {
    typealias SingleQuerier = (_ query: Query) -> APIResponse
    
    private let querier: SingleQuerier
    private let indexName: String
    
    internal init(indexName: String, querier: @escaping SingleQuerier) {
        self.indexName = indexName
        self.querier = querier
    }
    
    internal func multipleQueries(_ queries: [Query], strategy: String?) -> APIResponse {
        // TODO: Should be moved to `LocalIndex` to factorize implementation between platforms.
        assert(!Thread.isMainThread) // make sure it's run in the background
        
        var content: JSONObject?
        var error: Error?
        var results: [JSONObject] = []
        
        var shouldProcess = true
        for query in queries {
            // Implement the "stop if enough matches" strategy.
            if !shouldProcess {
                let returnedContent: JSONObject = [
                    "hits": [],
                    "page": 0,
                    "nbHits": 0,
                    "nbPages": 0,
                    "hitsPerPage": 0,
                    "processingTimeMS": 1,
                    "params": query.build(),
                    "index": self.indexName,
                    "processed": false
                ]
                results.append(returnedContent)
                continue
            }
            
            let (queryContent, queryError) = self.querier(query)
            assert(queryContent != nil || queryError != nil)
            if queryError != nil {
                error = queryError
                break
            }
            var returnedContent = queryContent!
            returnedContent["index"] = self.indexName
            results.append(returnedContent)
            
            // Implement the "stop if enough matches strategy".
            if shouldProcess && strategy == Client.MultipleQueriesStrategy.stopIfEnoughMatches.rawValue {
                if let nbHits = returnedContent["nbHits"] as? Int, let hitsPerPage = returnedContent["hitsPerPage"] as? Int {
                    if nbHits >= hitsPerPage {
                        shouldProcess = false
                    }
                }
            }
        }
        if error == nil {
            content = [
                "results": results,
                // Tag results as having a local origin.
                // NOTE: Each individual result is also automatically tagged, but having a top-level key allows for
                // more uniform processing.
                MirroredIndex.jsonKeyOrigin: MirroredIndex.jsonValueOriginLocal
            ]
        }
        assert(content != nil || error != nil)
        return (content: content, error: error)
    }
}
