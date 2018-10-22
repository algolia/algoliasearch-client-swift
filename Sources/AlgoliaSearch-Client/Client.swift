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

import Foundation

/// Entry point into the Swift API.
///
@objcMembers public class Client: AbstractClient {
  // MARK: Properties

  /// Algolia application ID.
  @objc public var appID: String { return _appID! } // will never be nil in this class

  /// Algolia API key.
  @objc public var apiKey: String {
    get { return _apiKey! }
    set { _apiKey = newValue }
  }

  /// Cache of already created indices.
  ///
  /// This dictionary is used to avoid creating two instances to represent the same index, as it is (1) inefficient
  /// and (2) potentially harmful since instances are stateful (that's especially true of mirrored/offline indices,
  /// but also of online indices because of the search cache).
  ///
  /// + Note: The values are zeroing weak references to avoid leaking memory when an index is no longer used.
  ///
  var indices: NSMapTable<NSString, AnyObject> = NSMapTable(keyOptions: [.strongMemory], valueOptions: [.weakMemory])

  /// Queue for purely in-memory operations (no I/Os).
  /// Typically used for aggregate, concurrent operations.
  ///
  internal var inMemoryQueue: OperationQueue = OperationQueue()

  // MARK: - Initialization

  /// Create a new Algolia Search client.
  ///
  /// - parameter appID:  The application ID (available in your Algolia Dashboard).
  /// - parameter apiKey: A valid API key for the service.
  ///
  @objc public init(appID: String, apiKey: String) {
    // Initialize hosts to their default values.
    //
    // NOTE: The host list comes in two parts:
    //
    // 1. The fault-tolerant, load-balanced DNS host.
    // 2. The non-fault-tolerant hosts. Those hosts must be randomized to ensure proper load balancing in case
    //    of the first host's failure.
    //
    let fallbackHosts = [
      "\(appID)-1.algolianet.com",
      "\(appID)-2.algolianet.com",
      "\(appID)-3.algolianet.com",
    ].shuffle()
    let readHosts = ["\(appID)-dsn.algolia.net"] + fallbackHosts
    let writeHosts = ["\(appID).algolia.net"] + fallbackHosts
    super.init(appID: appID, apiKey: apiKey, readHosts: readHosts, writeHosts: writeHosts)
    inMemoryQueue.maxConcurrentOperationCount = onlineRequestQueue.maxConcurrentOperationCount
  }

  /// Obtain a proxy to an Algolia index (no server call required by this method).
  ///
  /// + Note: Only one instance can exist for a given index name. Subsequent calls to this method with the same
  ///   index name will return the same instance, unless it has already been released.
  ///
  /// - parameter indexName: The name of the index.
  /// - returns: A proxy to the specified index.
  ///
  @objc(indexWithName:)
  public func index(withName indexName: String) -> Index {
    if let index = indices.object(forKey: indexName as NSString) {
      assert(index is Index, "An index with the same name but a different type has already been created") // may happen in offline mode
      return index as! Index
    } else {
      let index = Index(client: self, name: indexName)
      indices.setObject(index, forKey: indexName as NSString)
      return index
    }
  }

  // MARK: - Operations

  /// List existing indexes.
  ///
  /// - parameter requestOptions: Request-specific options.
  /// - parameter completionHandler: Completion handler to be notified of the request's outcome.
  /// - returns: A cancellable operation.
  ///
  @objc(listIndexesWithRequestOptions:completionHandler:)
  @discardableResult public func listIndexes(requestOptions: RequestOptions? = nil, completionHandler: @escaping CompletionHandler) -> Operation {
    return performHTTPQuery(path: "1/indexes", method: .GET, body: nil, hostnames: readHosts, requestOptions: requestOptions, completionHandler: completionHandler)
  }

  @objc(listIndexes:)
  @discardableResult public func z_objc_listIndexes(completionHandler: @escaping CompletionHandler) -> Operation {
    return listIndexes(completionHandler: completionHandler)
  }

  /// Delete an index.
  ///
  /// - parameter name: Name of the index to delete.
  /// - parameter requestOptions: Request-specific options.
  /// - parameter completionHandler: Completion handler to be notified of the request's outcome.
  /// - returns: A cancellable operation.
  ///
  @objc(deleteIndexWithName:requestOptions:completionHandler:)
  @discardableResult public func deleteIndex(withName name: String, requestOptions: RequestOptions? = nil, completionHandler: CompletionHandler? = nil) -> Operation {
    let path = "1/indexes/\(name.urlEncodedPathComponent())"
    return performHTTPQuery(path: path, method: .DELETE, body: nil, hostnames: writeHosts, requestOptions: requestOptions, completionHandler: completionHandler)
  }

  @objc(deleteIndexWithName:completionHandler:)
  @discardableResult public func z_objc_deleteIndex(withName name: String, completionHandler: CompletionHandler?) -> Operation {
    return deleteIndex(withName: name, completionHandler: completionHandler)
  }

  /// Move an existing index.
  ///
  /// If the destination index already exists, its specific API keys will be preserved and the source index specific
  /// API keys will be added.
  ///
  /// - parameter srcIndexName: Name of index to move.
  /// - parameter dstIndexName: The new index name.
  /// - parameter requestOptions: Request-specific options.
  /// - parameter completionHandler: Completion handler to be notified of the request's outcome.
  /// - returns: A cancellable operation.
  ///
  @objc(moveIndexFrom:to:requestOptions:completionHandler:)
  @discardableResult public func moveIndex(from srcIndexName: String, to dstIndexName: String, requestOptions: RequestOptions? = nil, completionHandler: CompletionHandler? = nil) -> Operation {
    let path = "1/indexes/\(srcIndexName.urlEncodedPathComponent())/operation"
    let request = [
      "destination": dstIndexName,
      "operation": "move",
    ]
    return performHTTPQuery(path: path, method: .POST, body: request as [String: Any]?, hostnames: writeHosts, requestOptions: requestOptions, completionHandler: completionHandler)
  }

  @objc(moveIndexFrom:to:completionHandler:)
  @discardableResult public func z_objc_moveIndex(from srcIndexName: String, to dstIndexName: String, completionHandler: CompletionHandler?) -> Operation {
    return moveIndex(from: srcIndexName, to: dstIndexName, completionHandler: completionHandler)
  }

  /// Copy an existing index.
  ///
  /// If the destination index already exists, its specific API keys will be preserved and the source index specific
  /// API keys will be added.
  ///
  /// - parameter srcIndexName: Name of the index to copy.
  /// - parameter dstIndexName: The new index name.
  /// - parameter requestOptions: Request-specific options.
  /// - parameter completionHandler: Completion handler to be notified of the request's outcome.
  /// - returns: A cancellable operation.
  ///
  @objc(copyIndexFrom:to:requestOptions:completionHandler:)
  @discardableResult public func copyIndex(from srcIndexName: String, to dstIndexName: String, requestOptions: RequestOptions? = nil, completionHandler: CompletionHandler? = nil) -> Operation {
    let path = "1/indexes/\(srcIndexName.urlEncodedPathComponent())/operation"
    let request = [
      "destination": dstIndexName,
      "operation": "copy",
    ]
    return performHTTPQuery(path: path, method: .POST, body: request as [String: Any]?, hostnames: writeHosts, requestOptions: requestOptions, completionHandler: completionHandler)
  }

  @objc(copyIndexFrom:to:completionHandler:)
  @discardableResult public func z_objc_copyIndex(from srcIndexName: String, to dstIndexName: String, completionHandler: CompletionHandler?) -> Operation {
    return copyIndex(from: srcIndexName, to: dstIndexName, completionHandler: completionHandler)
  }

  /// Strategy when running multiple queries. See `Client.multipleQueries(...)`.
  ///
  public enum MultipleQueriesStrategy: String {
    /// Execute the sequence of queries until the end.
    ///
    /// + Warning: Beware of confusion with `Optional.none` when using type inference!
    ///
    case none
    /// Execute the sequence of queries until the number of hits is reached by the sum of hits.
    case stopIfEnoughMatches
  }

  /// Query multiple indexes with one API call.
  ///
  /// - parameter queries: List of queries.
  /// - parameter strategy: The strategy to use.
  /// - parameter requestOptions: Request-specific options.
  /// - parameter completionHandler: Completion handler to be notified of the request's outcome.
  /// - returns: A cancellable operation.
  ///
  @objc(multipleQueries:strategy:requestOptions:completionHandler:)
  @discardableResult public func multipleQueries(_ queries: [IndexQuery], strategy: String?, requestOptions: RequestOptions? = nil, completionHandler: @escaping CompletionHandler) -> Operation {
    // IMPLEMENTATION NOTE: Objective-C bridgeable alternative.
    let path = "1/indexes/*/queries"
    var requests = [[String: Any]]()
    requests.reserveCapacity(queries.count)
    for query in queries {
      requests.append([
        "indexName": query.indexName as Any,
        "params": query.query.build() as Any,
      ])
    }
    var request = [String: Any]()
    request["requests"] = requests
    if strategy != nil {
      request["strategy"] = strategy
    }
    return performHTTPQuery(path: path, method: .POST, body: request, hostnames: readHosts, requestOptions: requestOptions, completionHandler: completionHandler)
  }

  @objc(multipleQueries:strategy:completionHandler:)
  @discardableResult public func z_objc_multipleQueries(_ queries: [IndexQuery], strategy: String?, completionHandler: @escaping CompletionHandler) -> Operation {
    return multipleQueries(queries, strategy: strategy, completionHandler: completionHandler)
  }

  /// Query multiple indexes with one API call.
  ///
  /// - parameter queries: List of queries.
  /// - parameter strategy: The strategy to use.
  /// - parameter requestOptions: Request-specific options.
  /// - parameter completionHandler: Completion handler to be notified of the request's outcome.
  /// - returns: A cancellable operation.
  ///
  @discardableResult public func multipleQueries(_ queries: [IndexQuery], strategy: MultipleQueriesStrategy? = nil, requestOptions: RequestOptions? = nil, completionHandler: @escaping CompletionHandler) -> Operation {
    // IMPLEMENTATION NOTE: Not Objective-C bridgeable because of enum.
    return multipleQueries(queries, strategy: strategy?.rawValue, requestOptions: requestOptions, completionHandler: completionHandler)
  }

  /// Batch operations.
  ///
  /// - parameter operations: List of operations.
  /// - parameter requestOptions: Request-specific options.
  /// - parameter completionHandler: Completion handler to be notified of the request's outcome.
  /// - returns: A cancellable operation.
  ///
  @objc(batchOperations:requestOptions:completionHandler:)
  @discardableResult public func batch(operations: [Any], requestOptions: RequestOptions? = nil, completionHandler: CompletionHandler? = nil) -> Operation {
    let path = "1/indexes/*/batch"
    let body = ["requests": operations]
    return performHTTPQuery(path: path, method: .POST, body: body as [String: Any]?, hostnames: writeHosts, requestOptions: requestOptions, completionHandler: completionHandler)
  }

  @objc(batchOperations:completionHandler:)
  @discardableResult public func z_objc_batch(operations: [Any], completionHandler: CompletionHandler?) -> Operation {
    return batch(operations: operations, completionHandler: completionHandler)
  }
}
