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

import Foundation


/// A handler for `BrowseIterator`.
///
/// - parameter iterator:   The browse iterator involved. May be used to cancel the iteration.
/// - parameter content:    The content returned by the server, in case of success.
/// - parameter error:      The error that was encountered, in case of failure.
///
public typealias BrowseIteratorHandler = (_ iterator: BrowseIterator, _ content: [String: Any]?, _ error: Error?) -> Void


/// Iterator to browse all index content.
///
/// This helper takes care of chaining API requests and calling back the completion handler with the results, until:
/// - the end of the index has been reached;
/// - an error has been encountered;
/// - or the user cancelled the iteration.
///
@objc public class BrowseIterator: NSObject {
    /// The index being browsed.
    public let index: Index
    
    /// The query used to filter the results.
    public let query: Query

    /// Completion handler.
    private let completionHandler: BrowseIteratorHandler

    /// Cursor to use for the next call, if any.
    private var cursor: String?
    
    /// Whether the iteration has already started.
    private var started = false
    
    /// Whether the iteration has been cancelled by the user.
    private var cancelled: Bool = false
    
    /// The currently ongoing request, if any.
    private var request: Operation?
    
    /// Construct a new browse iterator.
    ///
    /// + Note: The iteration does not start automatically. You have to call `start()` explicitly.
    ///
    /// - parameter index:  The index to be browsed.
    /// - parameter query:  The query used to filter the results.
    /// - parameter completionHandler:  Handler called for each page of results.
    ///
    @objc public init(index: Index, query: Query, completionHandler: @escaping BrowseIteratorHandler) {
        self.index = index
        self.query = query
        self.completionHandler = completionHandler
    }
    
    /// Start the iteration.
    @objc public func start() {
        assert(!started)
        started = true
        request = index.browse(query: query, completionHandler: self.handleResult)
    }
    
    /// Cancel the iteration.
    /// This cancels any currently ongoing request, and cancels the iteration.
    /// The completion handler will not be called after the iteration has been cancelled.
    ///
    @objc public func cancel() {
        request?.cancel()
        request = nil
        cancelled = true
    }
    
    private func handleResult(_ content: [String: Any]?, error: Error?) {
        request = nil
        cursor = content?["cursor"] as? String
        if !cancelled {
            completionHandler(self, content, error)
            if !cancelled && error == nil && hasNext() {
                next()
            }
        }
    }
    
    /// Determine if there is more content to be browsed.
    ///
    /// + Warning: Can only be called from the handler, once the iteration has started.
    ///
    @objc public func hasNext() -> Bool {
        assert(started)
        return self.cursor != nil
    }
    
    private func next() {
        assert(hasNext())
        request = index.browse(from: self.cursor!, completionHandler: handleResult)
    }
}
