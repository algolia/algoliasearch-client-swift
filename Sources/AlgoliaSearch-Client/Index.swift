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

/// A proxy to an Algolia index.
///
/// + Note: You cannot construct this class directly. Please use `Client.index(withName:)` to obtain an instance.
///
@objcMembers public class Index: NSObject, Searchable {
  // MARK: Properties

  /// This index's name.
  @objc public let name: String

  /// API client used by this index.
  @objc public let client: Client

  let urlEncodedName: String

  var searchCache: ExpiringCache?

  // MAR: - Initialization

  /// Create a new index proxy.
  @objc init(client: Client, name: String) {
    self.client = client
    self.name = name
    urlEncodedName = name.urlEncodedPathComponent()
  }

  public override var description: String {
    return "Index{\"\(name)\"}"
  }

  // MARK: - Operations

  /// Add an object to this index.
  ///
  /// - parameter object: The object to add.
  /// - parameter requestOptions: Request-specific options.
  /// - parameter completionHandler: Completion handler to be notified of the request's outcome.
  /// - returns: A cancellable operation.
  /// + Warning: Deprecated, use saveObject(_:) instead.
  ///
  @available(*, deprecated: 6.0, message: "Deprecated, use saveObject(_:) instead")
  @objc
  @discardableResult public func addObject(_ object: [String: Any], requestOptions: RequestOptions? = nil, completionHandler: CompletionHandler? = nil) -> Operation {
    let path = "1/indexes/\(urlEncodedName)"
    return client.performHTTPQuery(path: path, method: .POST, body: object, hostnames: client.writeHosts, requestOptions: requestOptions, completionHandler: completionHandler)
  }

  @available(*, deprecated: 6.0, message: "Deprecated, use saveObject(_:) instead")
  @objc(addObject:completionHandler:)
  @discardableResult public func z_objc_addObject(_ object: [String: Any], completionHandler: CompletionHandler?) -> Operation {
    return addObject(object, requestOptions: nil, completionHandler: completionHandler)
  }

  /// Add an object to this index, assigning it the specified object ID.
  /// If an object already exists with the same object ID, the existing object will be overwritten.
  ///
  /// - parameter object: The object to add.
  /// - parameter objectID: Identifier that you want to assign this object.
  /// - parameter requestOptions: Request-specific options.
  /// - parameter completionHandler: Completion handler to be notified of the request's outcome.
  /// - returns: A cancellable operation.
  /// + Warning: Deprecated, use saveObject(_:) instead.
  ///
  @available(*, deprecated: 6.0, message: "Deprecated, use saveObject(_:) instead")
  @objc
  @discardableResult public func addObject(_ object: [String: Any], withID objectID: String, requestOptions: RequestOptions? = nil, completionHandler: CompletionHandler? = nil) -> Operation {
    let path = "1/indexes/\(urlEncodedName)/\(objectID.urlEncodedPathComponent())"
    return client.performHTTPQuery(path: path, method: .PUT, body: object, hostnames: client.writeHosts, requestOptions: requestOptions, completionHandler: completionHandler)
  }

  @available(*, deprecated: 6.0, message: "Deprecated, use saveObject(_:) instead")
  @objc(addObject:withID:completionHandler:)
  @discardableResult public func z_objc_addObject(_ object: [String: Any], withID objectID: String, completionHandler: CompletionHandler?) -> Operation {
    return addObject(object, withID: objectID, completionHandler: completionHandler)
  }

  /// Add several objects to this index.
  ///
  /// - parameter objects: Objects to add.
  /// - parameter requestOptions: Request-specific options.
  /// - parameter completionHandler: Completion handler to be notified of the request's outcome.
  /// - returns: A cancellable operation.
  /// + Warning: Deprecated, use saveObjects(_:) instead.
  ///
  @available(*, deprecated: 6.0, message: "Deprecated, use saveObject(_:) instead")
  @objc
  @discardableResult public func addObjects(_ objects: [[String: Any]], requestOptions: RequestOptions? = nil, completionHandler: CompletionHandler? = nil) -> Operation {
    let path = "1/indexes/\(urlEncodedName)/batch"

    var requests = [Any]()
    requests.reserveCapacity(objects.count)
    for object in objects {
      requests.append(["action": "addObject", "body": object])
    }
    let request = ["requests": requests]

    return client.performHTTPQuery(path: path, method: .POST, body: request, hostnames: client.writeHosts, requestOptions: requestOptions, completionHandler: completionHandler)
  }

  @available(*, deprecated: 6.0, message: "Deprecated, use saveObject(_:) instead")
  @objc(addObjects:completionHandler:)
  @discardableResult public func z_objc_addObjects(_ objects: [[String: Any]], completionHandler: CompletionHandler?) -> Operation {
    return addObjects(objects, completionHandler: completionHandler)
  }

  /// Delete an object from this index.
  ///
  /// - parameter objectID: Identifier of object to delete.
  /// - parameter requestOptions: Request-specific options.
  /// - parameter completionHandler: Completion handler to be notified of the request's outcome.
  /// - returns: A cancellable operation.
  ///
  @objc
  @discardableResult public func deleteObject(withID objectID: String, requestOptions: RequestOptions? = nil, completionHandler: CompletionHandler? = nil) -> Operation {
    let path = "1/indexes/\(urlEncodedName)/\(objectID.urlEncodedPathComponent())"
    return client.performHTTPQuery(path: path, method: .DELETE, body: nil, hostnames: client.writeHosts, requestOptions: requestOptions, completionHandler: completionHandler)
  }

  @objc(deleteObjectWithID:completionHandler:)
  @discardableResult public func z_objc_deleteObject(withID objectID: String, completionHandler: CompletionHandler?) -> Operation {
    return deleteObject(withID: objectID, completionHandler: completionHandler)
  }

  /// Delete several objects from this index.
  ///
  /// - parameter objectIDs: Identifiers of objects to delete.
  /// - parameter requestOptions: Request-specific options.
  /// - parameter completionHandler: Completion handler to be notified of the request's outcome.
  /// - returns: A cancellable operation.
  ///
  @objc
  @discardableResult public func deleteObjects(withIDs objectIDs: [String], requestOptions: RequestOptions? = nil, completionHandler: CompletionHandler? = nil) -> Operation {
    let path = "1/indexes/\(urlEncodedName)/batch"

    var requests = [Any]()
    requests.reserveCapacity(objectIDs.count)
    for id in objectIDs {
      requests.append(["action": "deleteObject", "objectID": id])
    }
    let request = ["requests": requests]

    return client.performHTTPQuery(path: path, method: .POST, body: request, hostnames: client.writeHosts, requestOptions: requestOptions, completionHandler: completionHandler)
  }

  @objc(deleteObjectsWithIDs:completionHandler:)
  @discardableResult public func z_objc_deleteObjects(withIDs objectIDs: [String], completionHandler: CompletionHandler?) -> Operation {
    return deleteObjects(withIDs: objectIDs, completionHandler: completionHandler)
  }

  /// Get an object from this index, optionally restricting the retrieved content.
  ///
  /// - parameter objectID: Identifier of the object to retrieve.
  /// - parameter attributesToRetrieve: List of attributes to retrieve. If `nil`, all attributes are retrieved.
  ///                                   If one of the elements is `"*"`, all attributes are retrieved.
  /// - parameter requestOptions: Request-specific options.
  /// - parameter completionHandler: Completion handler to be notified of the request's outcome.
  /// - returns: A cancellable operation.
  ///
  @objc
  @discardableResult public func getObject(withID objectID: String, attributesToRetrieve: [String]? = nil, requestOptions: RequestOptions? = nil, completionHandler: @escaping CompletionHandler) -> Operation {
    let query = Query()
    query.attributesToRetrieve = attributesToRetrieve
    let path = "1/indexes/\(urlEncodedName)/\(objectID.urlEncodedPathComponent())"
    return client.performHTTPQuery(path: path, urlParameters: query.parameters, method: .GET, body: nil, hostnames: client.readHosts, requestOptions: requestOptions, completionHandler: completionHandler)
  }

  @objc(getObjectWithID:completionHandler:)
  @discardableResult public func z_objc_getObject(withID objectID: String, completionHandler: @escaping CompletionHandler) -> Operation {
    return getObject(withID: objectID, completionHandler: completionHandler)
  }

  @objc(getObjectWithID:attributesToRetrieve:completionHandler:)
  @discardableResult public func z_objc_getObject(withID objectID: String, attributesToRetrieve: [String]?, completionHandler: @escaping CompletionHandler) -> Operation {
    return getObject(withID: objectID, attributesToRetrieve: attributesToRetrieve, completionHandler: completionHandler)
  }

  /// Get several objects from this index, optionally restricting the retrieved content.
  ///
  /// - parameter objectIDs: Identifiers of objects to retrieve.
  /// - parameter attributesToRetrieve: List of attributes to retrieve. If `nil`, all attributes are retrieved.
  ///                                   If one of the elements is `"*"`, all attributes are retrieved.
  /// - parameter requestOptions: Request-specific options.
  /// - parameter completionHandler: Completion handler to be notified of the request's outcome.
  /// - returns: A cancellable operation.
  ///
  @objc
  @discardableResult public func getObjects(withIDs objectIDs: [String], attributesToRetrieve: [String]? = nil, requestOptions: RequestOptions? = nil, completionHandler: @escaping CompletionHandler) -> Operation {
    let path = "1/indexes/*/objects"
    var requests = [Any]()
    requests.reserveCapacity(objectIDs.count)
    for id in objectIDs {
      var request = [
        "indexName": self.name,
        "objectID": id,
      ]
      request["attributesToRetrieve"] = attributesToRetrieve?.joined(separator: ",")
      requests.append(request as Any)
    }
    return client.performHTTPQuery(path: path, method: .POST, body: ["requests": requests], hostnames: client.readHosts, requestOptions: requestOptions, completionHandler: completionHandler)
  }

  @objc(getObjectsWithIDs:completionHandler:)
  @discardableResult public func z_objc_getObjects(withIDs objectIDs: [String], completionHandler: @escaping CompletionHandler) -> Operation {
    return getObjects(withIDs: objectIDs, attributesToRetrieve: nil, completionHandler: completionHandler)
  }

  @objc(getObjectsWithIDs:attributesToRetrieve:completionHandler:)
  @discardableResult public func z_objc_getObjects(withIDs objectIDs: [String], attributesToRetrieve: [String]?, completionHandler: @escaping CompletionHandler) -> Operation {
    return getObjects(withIDs: objectIDs, attributesToRetrieve: attributesToRetrieve, completionHandler: completionHandler)
  }

  /// Partially update an object.
  ///
  /// - parameter partialObject: New values/operations for the object.
  /// - parameter objectID: Identifier of object to be updated.
  /// - parameter createIfNotExists: Whether an update on a nonexistent object ID should create the object.
  /// - parameter requestOptions: Request-specific options.
  /// - parameter completionHandler: Completion handler to be notified of the request's outcome.
  /// - returns: A cancellable operation.
  ///
  @discardableResult public func partialUpdateObject(_ partialObject: [String: Any], withID objectID: String, createIfNotExists: Bool? = nil, requestOptions: RequestOptions? = nil, completionHandler: CompletionHandler? = nil) -> Operation {
    let path = "1/indexes/\(urlEncodedName)/\(objectID.urlEncodedPathComponent())/partial"
    let urlParameters: [String: String] = createIfNotExists != nil ? ["createIfNotExists": String(createIfNotExists!)] : [:]
    return client.performHTTPQuery(path: path, urlParameters: urlParameters, method: .POST, body: partialObject, hostnames: client.writeHosts, requestOptions: requestOptions, completionHandler: completionHandler)
  }

  @objc(partialUpdateObject:withID:completionHandler:)
  @discardableResult public func z_objc_partialUpdateObject(_ partialObject: [String: Any], withID objectID: String, completionHandler: CompletionHandler?) -> Operation {
    return partialUpdateObject(partialObject, withID: objectID, completionHandler: completionHandler)
  }

  @objc(partialUpdateObject:withID:createIfNotExists:completionHandler:)
  @discardableResult public func z_objc_partialUpdateObject(_ partialObject: [String: Any], withID objectID: String, createIfNotExists: Bool, completionHandler: CompletionHandler?) -> Operation {
    return partialUpdateObject(partialObject, withID: objectID, createIfNotExists: createIfNotExists, completionHandler: completionHandler)
  }

  @objc(partialUpdateObject:withID:createIfNotExists:requestOptions:completionHandler:)
  @discardableResult public func z_objc_partialUpdateObject(_ partialObject: [String: Any], withID objectID: String, createIfNotExists: Bool, requestOptions: RequestOptions?, completionHandler: CompletionHandler?) -> Operation {
    return partialUpdateObject(partialObject, withID: objectID, createIfNotExists: createIfNotExists, requestOptions: requestOptions, completionHandler: completionHandler)
  }

  /// Partially update several objects.
  ///
  /// - parameter objects: New values/operations for the objects. Each object must contain an `objectID` attribute.
  /// - parameter createIfNotExists: Whether an update on a nonexistent object ID should create the object.
  /// - parameter requestOptions: Request-specific options.
  /// - parameter completionHandler: Completion handler to be notified of the request's outcome.
  /// - returns: A cancellable operation.
  ///
  @discardableResult public func partialUpdateObjects(_ objects: [[String: Any]], createIfNotExists: Bool? = nil, requestOptions: RequestOptions? = nil, completionHandler: CompletionHandler? = nil) -> Operation {
    let path = "1/indexes/\(urlEncodedName)/batch"
    let createIfNotExists = createIfNotExists ?? true
    let action = createIfNotExists ? "partialUpdateObject" : "partialUpdateObjectNoCreate"
    var requests = [Any]()
    requests.reserveCapacity(objects.count)
    for object in objects {
      requests.append([
        "action": action,
        "objectID": object["objectID"] as! String,
        "body": object,
      ])
    }
    let request = ["requests": requests]

    return client.performHTTPQuery(path: path, method: .POST, body: request, hostnames: client.writeHosts, requestOptions: requestOptions, completionHandler: completionHandler)
  }

  @objc(partialUpdateObjects:completionHandler:)
  @discardableResult public func z_objc_partialUpdateObjects(_ objects: [[String: Any]], completionHandler: CompletionHandler?) -> Operation {
    return partialUpdateObjects(objects, completionHandler: completionHandler)
  }

  @objc(partialUpdateObjects:createIfNotExists:completionHandler:)
  @discardableResult public func z_objc_partialUpdateObjects(_ objects: [[String: Any]], createIfNotExists: Bool, completionHandler: CompletionHandler?) -> Operation {
    return partialUpdateObjects(objects, createIfNotExists: createIfNotExists, completionHandler: completionHandler)
  }

  @objc(partialUpdateObjects:createIfNotExists:requestOptions:completionHandler:)
  @discardableResult public func z_objc_partialUpdateObjects(_ objects: [[String: Any]], createIfNotExists: Bool, requestOptions: RequestOptions?, completionHandler: CompletionHandler?) -> Operation {
    return partialUpdateObjects(objects, createIfNotExists: createIfNotExists, requestOptions: requestOptions, completionHandler: completionHandler)
  }

  /// Update an object.
  ///
  /// - parameter object: New version of the object to update. Must contain an `objectID` attribute.
  /// - parameter requestOptions: Request-specific options.
  /// - parameter completionHandler: Completion handler to be notified of the request's outcome.
  /// - returns: A cancellable operation.
  ///
  @objc
  @discardableResult public func saveObject(_ object: [String: Any], requestOptions: RequestOptions? = nil, completionHandler: CompletionHandler? = nil) -> Operation {
    let objectID = object["objectID"] as! String
    let path = "1/indexes/\(urlEncodedName)/\(objectID.urlEncodedPathComponent())"
    return client.performHTTPQuery(path: path, method: .PUT, body: object, hostnames: client.writeHosts, requestOptions: requestOptions, completionHandler: completionHandler)
  }

  @objc(saveObject:completionHandler:)
  @discardableResult public func z_objc_saveObject(_ object: [String: Any], completionHandler: CompletionHandler?) -> Operation {
    return saveObject(object, completionHandler: completionHandler)
  }

  /// Update several objects.
  ///
  /// - parameter objects: New versions of the objects to update. Each one must contain an `objectID` attribute.
  /// - parameter requestOptions: Request-specific options.
  /// - parameter completionHandler: Completion handler to be notified of the request's outcome.
  /// - returns: A cancellable operation.
  ///
  @objc
  @discardableResult public func saveObjects(_ objects: [[String: Any]], requestOptions: RequestOptions? = nil, completionHandler: CompletionHandler? = nil) -> Operation {
    let path = "1/indexes/\(urlEncodedName)/batch"

    var requests = [Any]()
    requests.reserveCapacity(objects.count)
    for object in objects {
      requests.append([
        "action": "updateObject",
        "objectID": object["objectID"] as! String,
        "body": object,
      ])
    }
    let request = ["requests": requests]

    return client.performHTTPQuery(path: path, method: .POST, body: request, hostnames: client.writeHosts, requestOptions: requestOptions, completionHandler: completionHandler)
  }

  @objc(saveObjects:completionHandler:)
  @discardableResult public func z_objc_saveObjects(_ objects: [[String: Any]], completionHandler: CompletionHandler?) -> Operation {
    return saveObjects(objects, completionHandler: completionHandler)
  }

  /// Search this index.
  ///
  /// - parameter query: Search parameters.
  /// - parameter requestOptions: Request-specific options.
  /// - parameter completionHandler: Completion handler to be notified of the request's outcome.
  /// - returns: A cancellable operation.
  ///
  @objc
  @discardableResult public func search(_ query: Query, requestOptions: RequestOptions? = nil, completionHandler: @escaping CompletionHandler) -> Operation {
    let path = "1/indexes/\(urlEncodedName)/query"
    let request = ["params": query.build()]

    // First try the in-memory query cache.
    // FIXME: We should not cache result if the request options have changed.
    let cacheKey = "\(path)_body_\(request)"
    if let content = searchCache?.objectForKey(cacheKey) {
      // We *have* to return something, so we create a simple operation.
      let operation = AsyncBlockOperation(completionHandler: completionHandler) {
        return (content, nil)
      }
      operation.completionQueue = client.completionQueue
      client.inMemoryQueue.addOperation(operation)
      return operation
    } else {
      return client.performHTTPQuery(path: path, method: .POST, body: request, hostnames: client.readHosts, isSearchQuery: true, requestOptions: requestOptions) { (content, error) -> Void in
        assert(content != nil || error != nil)

        // Update local cache in case of success.
        if content != nil {
          self.searchCache?.setObject(content!, forKey: cacheKey)
        }
        completionHandler(content, error)
      }
    }
  }

  @objc(search:completionHandler:)
  @discardableResult public func z_objc_search(_ query: Query, completionHandler: @escaping CompletionHandler) -> Operation {
    return search(query, completionHandler: completionHandler)
  }

  /// Search for facet values.
  /// This searches inside a facet's values, optionally restricting the returned values to those contained in objects
  /// matching other (regular) search criteria.
  ///
  /// - parameter facetName: Name of the facet to search. It must have been declared in the index's
  ///       `attributesForFaceting` setting with the `searchable()` modifier.
  /// - parameter text: Text to search for in the facet's values.
  /// - parameter query: An optional query to take extra search parameters into account. These parameters apply to
  ///       index objects like in a regular search query. Only facet values contained in the matched objects will be
  ///       returned.
  /// - parameter requestOptions: Request-specific options.
  /// - parameter completionHandler: Completion handler to be notified of the request's outcome.
  /// - returns: A cancellable operation.
  ///
  @discardableResult public func searchForFacetValues(of facetName: String, matching text: String, query: Query? = nil, requestOptions: RequestOptions? = nil, completionHandler: @escaping CompletionHandler) -> Operation {
    let path = "1/indexes/\(urlEncodedName)/facets/\(facetName.urlEncodedPathComponent())/query"
    var requestBody: [String: Any]?

    if let params = query {
      params["facetQuery"] = text
      requestBody = [
        "params": params.build(),
      ]
    } else {
      let params = Query()
      params["facetQuery"] = text
      requestBody = [
        "params": params.build(),
      ]
    }

    return client.performHTTPQuery(path: path, method: .POST, body: requestBody, hostnames: client.readHosts, isSearchQuery: true, requestOptions: requestOptions, completionHandler: completionHandler)
  }

  @objc(searchForFacetValuesOf:matching:query:completionHandler:)
  @discardableResult public func z_objc_searchForFacetValues(of facetName: String, matching text: String, query: Query?, completionHandler: @escaping CompletionHandler) -> Operation {
    return searchForFacetValues(of: facetName, matching: text, query: query, completionHandler: completionHandler)
  }

  /// Get this index's settings.
  ///
  /// - parameter requestOptions: Request-specific options.
  /// - parameter completionHandler: Completion handler to be notified of the request's outcome.
  /// - returns: A cancellable operation.
  ///
  @objc(getSettingsWithRequestOptions:completionHandler:)
  @discardableResult public func getSettings(requestOptions: RequestOptions? = nil, completionHandler: @escaping CompletionHandler) -> Operation {
    let path = "1/indexes/\(urlEncodedName)/settings"
    let urlParameters = ["getVersion": "2"]
    return client.performHTTPQuery(path: path, urlParameters: urlParameters, method: .GET, body: nil, hostnames: client.readHosts, requestOptions: requestOptions, completionHandler: completionHandler)
  }

  @objc(getSettings:)
  @discardableResult public func z_objc_getSettings(completionHandler: @escaping CompletionHandler) -> Operation {
    return getSettings(completionHandler: completionHandler)
  }

  /// Set this index's settings, optionally forwarding the change to replicas.
  ///
  /// Please refer to our [API documentation](https://www.algolia.com/doc/swift#index-settings) for the list of
  /// supported settings.
  ///
  /// - parameter settings: New settings.
  /// - parameter forwardToReplicas: When true, the change is also applied to replicas of this index.
  /// - parameter requestOptions: Request-specific options.
  /// - parameter completionHandler: Completion handler to be notified of the request's outcome.
  /// - returns: A cancellable operation.
  ///
  @discardableResult public func setSettings(_ settings: [String: Any], forwardToReplicas: Bool? = nil, requestOptions: RequestOptions? = nil, completionHandler: CompletionHandler? = nil) -> Operation {
    let path = "1/indexes/\(urlEncodedName)/settings"
    let urlParameters: [String: String] = forwardToReplicas != nil ? ["forwardToReplicas": String(forwardToReplicas!)] : [:]
    return client.performHTTPQuery(path: path, urlParameters: urlParameters, method: .PUT, body: settings, hostnames: client.writeHosts, requestOptions: requestOptions, completionHandler: completionHandler)
  }

  @objc(setSettings:completionHandler:)
  @discardableResult public func z_objc_setSettings(_ settings: [String: Any], completionHandler: CompletionHandler?) -> Operation {
    return setSettings(settings, completionHandler: completionHandler)
  }

  @objc(setSettings:forwardToReplicas:completionHandler:)
  @discardableResult public func z_objc_setSettings(_ settings: [String: Any], forwardToReplicas: Bool, completionHandler: CompletionHandler?) -> Operation {
    return setSettings(settings, forwardToReplicas: forwardToReplicas, completionHandler: completionHandler)
  }

  /// Delete the index content without removing settings and index specific API keys.
  ///
  /// - parameter requestOptions: Request-specific options.
  /// - parameter completionHandler: Completion handler to be notified of the request's outcome.
  /// - returns: A cancellable operation.
  ///
  @objc(clearIndexWithRequestOptions:completionHandler:)
  @discardableResult public func clearIndex(requestOptions: RequestOptions? = nil, completionHandler: CompletionHandler? = nil) -> Operation {
    let path = "1/indexes/\(urlEncodedName)/clear"
    return client.performHTTPQuery(path: path, method: .POST, body: nil, hostnames: client.writeHosts, requestOptions: requestOptions, completionHandler: completionHandler)
  }

  @objc(clearIndex:)
  @discardableResult public func z_objc_clearIndex(completionHandler: CompletionHandler?) -> Operation {
    return clearIndex(completionHandler: completionHandler)
  }

  /// Batch operations.
  ///
  /// - parameter operations: The array of actions.
  /// - parameter requestOptions: Request-specific options.
  /// - parameter completionHandler: Completion handler to be notified of the request's outcome.
  /// - returns: A cancellable operation.
  ///
  @objc(batchOperations:requestOptions:completionHandler:)
  @discardableResult public func batch(operations: [[String: Any]], requestOptions: RequestOptions? = nil, completionHandler: CompletionHandler? = nil) -> Operation {
    let path = "1/indexes/\(urlEncodedName)/batch"
    let body = ["requests": operations]
    return client.performHTTPQuery(path: path, method: .POST, body: body, hostnames: client.writeHosts, requestOptions: requestOptions, completionHandler: completionHandler)
  }

  @objc(batchOperations:completionHandler:)
  @discardableResult public func z_objc_batch(operations: [[String: Any]], completionHandler: CompletionHandler? = nil) -> Operation {
    return batch(operations: operations, completionHandler: completionHandler)
  }

  /// Browse all index content (initial call).
  /// This method should be called once to initiate a browse. It will return the first page of results and a cursor,
  /// unless the end of the index has been reached. To retrieve subsequent pages, call `browseFrom` with that cursor.
  ///
  /// - parameter query: The query parameters for the browse.
  /// - parameter requestOptions: Request-specific options.
  /// - parameter completionHandler: Completion handler to be notified of the request's outcome.
  /// - returns: A cancellable operation.
  ///
  @objc(browseWithQuery:requestOptions:completionHandler:)
  @discardableResult public func browse(query: Query, requestOptions: RequestOptions? = nil, completionHandler: @escaping CompletionHandler) -> Operation {
    let path = "1/indexes/\(urlEncodedName)/browse"
    let body = [
      "params": query.build(),
    ]
    return client.performHTTPQuery(path: path, method: .POST, body: body, hostnames: client.readHosts, requestOptions: requestOptions, completionHandler: completionHandler)
  }

  @objc(browseWithQuery:completionHandler:)
  @discardableResult public func z_objc_browse(query: Query, completionHandler: @escaping CompletionHandler) -> Operation {
    return browse(query: query, completionHandler: completionHandler)
  }

  /// Browse the index from a cursor.
  /// This method should be called after an initial call to `browse()`. It returns a cursor, unless the end of the
  /// index has been reached.
  ///
  /// - parameter cursor: The cursor of the next page to retrieve
  /// - parameter requestOptions: Request-specific options.
  /// - parameter completionHandler: Completion handler to be notified of the request's outcome.
  /// - returns: A cancellable operation.
  ///
  @objc(browseFromCursor:requestOptions:completionHandler:)
  @discardableResult public func browse(from cursor: String, requestOptions: RequestOptions? = nil, completionHandler: @escaping CompletionHandler) -> Operation {
    let path = "1/indexes/\(urlEncodedName)/browse"
    let bodyParams = ["cursor": cursor]
    return client.performHTTPQuery(path: path, urlParameters: nil, method: .POST, body: bodyParams, hostnames: client.readHosts, requestOptions: requestOptions, completionHandler: completionHandler)
  }

  @objc(browseFromCursor:completionHandler:)
  @discardableResult public func z_objc_browse(from cursor: String, completionHandler: @escaping CompletionHandler) -> Operation {
    return browse(from: cursor, completionHandler: completionHandler)
  }

  // MARK: - Helpers

  /// Wait until the publication of a task on the server (helper).
  /// All server tasks are asynchronous. This method helps you check that a task is published.
  ///
  /// - parameter taskID: Identifier of the task (as returned by the server).
  /// - parameter requestOptions: Request-specific options.
  /// - parameter completionHandler: Completion handler to be notified of the request's outcome.
  /// - returns: A cancellable operation.
  ///
  @objc
  @discardableResult public func waitTask(withID taskID: Int, requestOptions: RequestOptions? = nil, completionHandler: @escaping CompletionHandler) -> Operation {
    let operation = WaitOperation(index: self, taskID: taskID, requestOptions: requestOptions, completionHandler: completionHandler)
    client.inMemoryQueue.addOperation(operation)
    return operation
  }

  @objc(waitTaskWithID:completionHandler:)
  @discardableResult public func z_objc_waitTask(withID taskID: Int, completionHandler: @escaping CompletionHandler) -> Operation {
    return waitTask(withID: taskID, completionHandler: completionHandler)
  }

  private class WaitOperation: AsyncOperationWithCompletion {
    let index: Index
    let taskID: Int
    let requestOptions: RequestOptions?
    let path: String
    var iteration: Int = 0
    var operation: Operation?

    static let BASE_DELAY = 0.1 /// < Minimum wait delay.
    static let MAX_DELAY = 5.0 /// < Maximum wait delay.

    init(index: Index, taskID: Int, requestOptions: RequestOptions?, completionHandler: @escaping CompletionHandler) {
      self.index = index
      self.taskID = taskID
      self.requestOptions = requestOptions
      path = "1/indexes/\(index.urlEncodedName)/task/\(taskID)"
      super.init(completionHandler: completionHandler)
      completionQueue = index.client.completionQueue
    }

    override func start() {
      super.start()
      startNext()
    }

    override func cancel() {
      operation?.cancel()
      super.cancel()
    }

    private func startNext() {
      if isCancelled {
        return
      }
      iteration += 1
      operation = index.client.performHTTPQuery(path: path, method: .GET, body: nil, hostnames: index.client.readHosts, requestOptions: requestOptions) { (content, error) -> Void in
        if let content = content {
          if (content["status"] as? String) == "published" {
            self.callCompletion(content: content, error: nil)
            self.finish()
          } else {
            // The delay between polls increases quadratically from the base delay up to the max delay.
            let delay = min(WaitOperation.BASE_DELAY * Double(self.iteration * self.iteration), WaitOperation.MAX_DELAY)
            DispatchQueue.global().asyncAfter(deadline: .now() + delay, execute: {
              self.startNext()
            })
          }
        } else {
          self.callCompletion(content: content, error: error)
          self.finish()
        }
      }
    }
  }

  /// Delete all objects matching a query.
  ///
  /// - parameter query: The query that objects to delete must match.
  /// - parameter requestOptions: Request-specific options.
  /// - parameter completionHandler: Completion handler to be notified of the request's outcome.
  /// - returns: A cancellable operation.
  ///
  @objc
  @discardableResult public func deleteBy(_ query: Query, requestOptions: RequestOptions? = nil, completionHandler: CompletionHandler? = nil) -> Operation {
    let path = "1/indexes/\(urlEncodedName)/deleteByQuery"
    let body = [
      "params": query.build(),
    ]
    return client.performHTTPQuery(path: path, method: .POST, body: body, hostnames: client.writeHosts, requestOptions: requestOptions, completionHandler: completionHandler)
  }

  @objc(deleteBy:completionHandler:)
  @discardableResult public func z_objc_deleteBy(_ query: Query, completionHandler: CompletionHandler?) -> Operation {
    return deleteBy(query, completionHandler: completionHandler)
  }

  /// Delete all objects matching a query (helper).
  ///
  /// - parameter query: The query that objects to delete must match.
  /// - parameter requestOptions: Request-specific options.
  /// - parameter completionHandler: Completion handler to be notified of the request's outcome.
  /// - returns: A cancellable operation.
  /// + Warning: Deprecated, use deleteBy instead.
  ///
  @objc
  @discardableResult public func deleteByQuery(_ query: Query, requestOptions: RequestOptions? = nil, completionHandler: CompletionHandler? = nil) -> Operation {
    let operation = DeleteByQueryOperation(index: self, query: query, requestOptions: requestOptions, completionHandler: completionHandler)
    client.inMemoryQueue.addOperation(operation)
    return operation
  }

  @objc(deleteByQuery:completionHandler:)
  @discardableResult public func z_objc_deleteByQuery(_ query: Query, completionHandler: CompletionHandler?) -> Operation {
    return deleteByQuery(query, completionHandler: completionHandler)
  }

  private class DeleteByQueryOperation: AsyncOperationWithCompletion {
    let index: Index
    let query: Query
    let requestOptions: RequestOptions?

    init(index: Index, query: Query, requestOptions: RequestOptions?, completionHandler: CompletionHandler?) {
      self.index = index
      self.query = Query(copy: query)
      self.requestOptions = requestOptions
      super.init(completionHandler: completionHandler)
      completionQueue = index.client.completionQueue
    }

    override func start() {
      super.start()
      // Save bandwidth by retrieving only the `objectID` attribute.
      query.attributesToRetrieve = ["objectID"]
      index.browse(query: query, requestOptions: requestOptions, completionHandler: handleResult)
    }

    private func handleResult(_ content: [String: Any]?, error: Error?) {
      if isCancelled {
        return
      }
      var finalError: Error? = error
      if finalError == nil {
        let hasMoreContent = content!["cursor"] != nil
        if let hits = content!["hits"] as? [Any] {
          // Fetch IDs of objects to delete.
          var objectIDs: [String] = []
          for hit in hits {
            if let objectID = (hit as? [String: Any])?["objectID"] as? String {
              objectIDs.append(objectID)
            }
          }
          // Delete the objects.
          index.deleteObjects(withIDs: objectIDs, requestOptions: requestOptions, completionHandler: { content, error in
            if self.isCancelled {
              return
            }
            var finalError: Error? = error
            if finalError == nil {
              if let taskID = content?["taskID"] as? Int {
                // Wait for the deletion to be effective.
                self.index.waitTask(withID: taskID, requestOptions: self.requestOptions, completionHandler: { content, error in
                  if self.isCancelled {
                    return
                  }
                  if error != nil || !hasMoreContent {
                    self.callCompletion(content: content, error: error)
                  } else {
                    // Browse again *from the beginning*, since the deletion invalidated the cursor.
                    self.index.browse(query: self.query, requestOptions: self.requestOptions, completionHandler: self.handleResult)
                  }
                })
              } else {
                finalError = InvalidJSONError(description: "No task ID returned when deleting")
              }
            }
            if finalError != nil {
              self.callCompletion(content: nil, error: finalError)
            }
          })
        } else {
          finalError = InvalidJSONError(description: "No hits returned when browsing")
        }
      }
      if finalError != nil {
        callCompletion(content: nil, error: finalError)
      }
    }
  }

  /// Perform a search with disjunctive facets, generating as many queries as number of disjunctive facets (helper).
  ///
  /// - parameter query: The query.
  /// - parameter disjunctiveFacets: List of disjunctive facets.
  /// - parameter refinements: The current refinements, mapping facet names to a list of values.
  /// - parameter requestOptions: Request-specific options.
  /// - parameter completionHandler: Completion handler to be notified of the request's outcome.
  /// - returns: A cancellable operation.
  ///
  @objc
  @discardableResult public func searchDisjunctiveFaceting(_ query: Query, disjunctiveFacets: [String], refinements: [String: [String]], requestOptions: RequestOptions? = nil, completionHandler: @escaping CompletionHandler) -> Operation {
    return DisjunctiveFaceting(multipleQuerier: { queries, completionHandler in
      self.multipleQueries(queries, requestOptions: requestOptions, completionHandler: completionHandler)
    }).searchDisjunctiveFaceting(query, disjunctiveFacets: disjunctiveFacets, refinements: refinements, completionHandler: completionHandler)
  }

  @objc(searchDisjunctiveFaceting:disjunctiveFacets:refinements:completionHandler:)
  @discardableResult public func z_objc_searchDisjunctiveFaceting(_ query: Query, disjunctiveFacets: [String], refinements: [String: [String]], completionHandler: @escaping CompletionHandler) -> Operation {
    return searchDisjunctiveFaceting(query, disjunctiveFacets: disjunctiveFacets, refinements: refinements, completionHandler: completionHandler)
  }

  /// Run multiple queries on this index.
  /// This method is a variant of `Client.multipleQueries(...)` where the targeted index is always the receiver.
  ///
  /// - parameter queries: The queries to run.
  /// - parameter requestOptions: Request-specific options.
  /// - parameter completionHandler: Completion handler to be notified of the request's outcome.
  /// - returns: A cancellable operation.
  ///
  @objc
  @discardableResult public func multipleQueries(_ queries: [Query], strategy: String?, requestOptions: RequestOptions? = nil, completionHandler: @escaping CompletionHandler) -> Operation {
    var requests = [IndexQuery]()
    for query in queries {
      requests.append(IndexQuery(index: self, query: query))
    }
    return client.multipleQueries(requests, strategy: strategy, requestOptions: requestOptions, completionHandler: completionHandler)
  }

  @objc(multipleQueries:strategy:completionHandler:)
  @discardableResult public func z_objc_multipleQueries(_ queries: [Query], strategy: String?, completionHandler: @escaping CompletionHandler) -> Operation {
    return multipleQueries(queries, strategy: strategy, completionHandler: completionHandler)
  }

  /// Run multiple queries on this index.
  /// This method is a variant of `Client.multipleQueries(...)` where the targeted index is always the receiver.
  ///
  /// - parameter queries: The queries to run.
  /// - parameter strategy: The strategy to use.
  /// - parameter requestOptions: Request-specific options.
  /// - parameter completionHandler: Completion handler to be notified of the request's outcome.
  /// - returns: A cancellable operation.
  ///
  @discardableResult public func multipleQueries(_ queries: [Query], strategy: Client.MultipleQueriesStrategy? = nil, requestOptions: RequestOptions? = nil, completionHandler: @escaping CompletionHandler) -> Operation {
    return multipleQueries(queries, strategy: strategy?.rawValue, requestOptions: requestOptions, completionHandler: completionHandler)
  }

  // MARK: - Search Cache

  /// Whether the search cache is enabled on this index. Default: `false`.
  ///
  @objc public var searchCacheEnabled: Bool = false {
    didSet(wasEnabled) {
      if !wasEnabled && searchCacheEnabled {
        enableSearchCache()
      } else if wasEnabled && !searchCacheEnabled {
        disableSearchCache()
      }
    }
  }

  /// Expiration delay for items in the search cache. Default: 2 minutes.
  ///
  /// + Note: The delay is a minimum threshold. Items may survive longer in cache.
  ///
  @objc public var searchCacheExpiringTimeInterval: TimeInterval = 120 {
    didSet {
      searchCache?.expiringTimeInterval = searchCacheExpiringTimeInterval
    }
  }

  /// Enable the search cache.
  ///
  private func enableSearchCache() {
    searchCache = ExpiringCache(expiringTimeInterval: searchCacheExpiringTimeInterval)
  }

  /// Disable the search cache.
  ///
  private func disableSearchCache() {
    searchCache?.clearCache()
    searchCache = nil
  }

  /// Clear the search cache.
  ///
  @objc public func clearSearchCache() {
    searchCache?.clearCache()
  }
}
