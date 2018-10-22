//
//  TestHelpers.swift
//  AlgoliaSearch OSX
//
//  Created by Robert Mogos on 06/02/2018.
//  Copyright © 2018 Algolia. All rights reserved.
//

import Foundation
import InstantSearchClient
import PromiseKit
import XCTest

extension OnlineTestCase {
  func addObject(_ object: [String: Any]) -> Promise<[String: Any]> {
    return promiseWrap({ fulfill, reject in
      self.index.addObject(object, completionHandler: completionWrap(fulfill: fulfill, reject: reject))
    })
  }

  func addObjects(_ objects: [[String: Any]]) -> Promise<[String: Any]> {
    return promiseWrap({ fulfill, reject in
      self.index.addObjects(objects, completionHandler: completionWrap(fulfill: fulfill, reject: reject))
    })
  }

  func saveObject(_ object: [String: Any]) -> Promise<[String: Any]> {
    return promiseWrap({ fulfill, reject in
      self.index.saveObject(object, completionHandler: completionWrap(fulfill: fulfill, reject: reject))
    })
  }

  func saveObjects(_ objects: [[String: Any]]) -> Promise<[String: Any]> {
    return promiseWrap({ fulfill, reject in
      self.index.saveObjects(objects, completionHandler: completionWrap(fulfill: fulfill, reject: reject))
    })
  }

  func deleteObject(_ object: [String: Any]) -> Promise<[String: Any]> {
    return promiseWrap({ fulfill, reject in
      self.index.deleteObject(withID: object["objectID"]! as! String, completionHandler: completionWrap(fulfill: fulfill, reject: reject))
    })
  }

  func deleteObjects(_ objects: [String]) -> Promise<[String: Any]> {
    return promiseWrap({ fulfill, reject in
      self.index.deleteObjects(withIDs: objects, completionHandler: completionWrap(fulfill: fulfill, reject: reject))
    })
  }

  func getObject(_ objectID: String) -> Promise<[String: Any]> {
    return promiseWrap({ fulfill, reject in
      self.index.getObject(withID: objectID, completionHandler: completionWrap(fulfill: fulfill, reject: reject))
    })
  }

  func getObjects(_ objectIDs: [String], attributesToRetrieve: [String]? = nil) -> Promise<[String: Any]> {
    return promiseWrap({ fulfill, reject in
      self.index.getObjects(withIDs: objectIDs, attributesToRetrieve: attributesToRetrieve, completionHandler: completionWrap(fulfill: fulfill, reject: reject))
    })
  }

  func waitTask(_ object: [String: Any]) -> Promise<[String: Any]> {
    return promiseWrap({ fulfill, reject in
      guard let taskID = object["taskID"] as? Int else {
        reject(NSError(domain: "com.algolia.com", code: -1, userInfo: [NSLocalizedDescriptionKey: "Wait task failed"]))
        return
      }
      self.index.waitTask(withID: taskID, completionHandler: completionWrap(fulfill: fulfill, reject: reject))
    })
  }

  func batchWaitTask(_ object: [String: Any]) -> Promise<[String: Any]> {
    return promiseWrap({ fulfill, reject in
      guard let taskID = (object["taskID"] as? [String: Any])?[self.index.name] as? Int else {
        reject(NSError(domain: "com.algolia.com", code: -1, userInfo: [NSLocalizedDescriptionKey: "Wait task failed"]))
        return
      }
      self.index.waitTask(withID: taskID, completionHandler: completionWrap(fulfill: fulfill, reject: reject))
    })
  }

  func query(_ query: String? = "") -> Promise<[String: Any]> {
    return promiseWrap({ fulfill, reject in
      self.index.search(Query(query: query), completionHandler: completionWrap(fulfill: fulfill, reject: reject))
    })
  }

  func query(index: Index, query: String? = "") -> Promise<[String: Any]> {
    return promiseWrap({ fulfill, reject in
      index.search(Query(query: query), completionHandler: completionWrap(fulfill: fulfill, reject: reject))
    })
  }

  func browse(_ query: Query) -> Promise<[String: Any]> {
    return promiseWrap({ fulfill, reject in
      self.index.browse(query: query, completionHandler: completionWrap(fulfill: fulfill, reject: reject))
    })
  }

  func deletexIndex(_ name: String) -> Promise<[String: Any]> {
    return promiseWrap({ fulfill, reject in
      self.client.deleteIndex(withName: name, completionHandler: completionWrap(fulfill: fulfill, reject: reject))
    })
  }

  func browse(from cursor: String) -> Promise<[String: Any]> {
    return promiseWrap({ fulfill, reject in
      self.index.browse(from: cursor, completionHandler: completionWrap(fulfill: fulfill, reject: reject))
    })
  }

  func deleteBy(_ query: Query) -> Promise<[String: Any]> {
    return promiseWrap({ fulfill, reject in
      self.index.deleteBy(query, completionHandler: completionWrap(fulfill: fulfill, reject: reject))
    })
  }

  func deleteByQuery(_ query: Query) -> Promise<[String: Any]> {
    return promiseWrap({ fulfill, reject in
      self.index.deleteByQuery(query, completionHandler: completionWrap(fulfill: fulfill, reject: reject))
    })
  }

  func multipleQueries(_ queries: [Query]) -> Promise<[String: Any]> {
    return promiseWrap({ fulfill, reject in
      self.index.multipleQueries(queries, completionHandler: completionWrap(fulfill: fulfill, reject: reject))
    })
  }

  func clientMultipleQueries(_ queries: [IndexQuery]) -> Promise<[String: Any]> {
    return promiseWrap({ fulfill, reject in
      self.client.multipleQueries(queries, completionHandler: completionWrap(fulfill: fulfill, reject: reject))
    })
  }

  func clientMultipleQueriesStopIfEnoughMatches(_ queries: [IndexQuery]) -> Promise<[String: Any]> {
    return promiseWrap({ fulfill, reject in
      self.client.multipleQueries(queries, strategy: .stopIfEnoughMatches, completionHandler: completionWrap(fulfill: fulfill, reject: reject))
    })
  }

  func searchDisjunctiveFaceting(_ query: Query, disjunctiveFacets: [String], refinements: [String: [String]]) -> Promise<[String: Any]> {
    return promiseWrap({ fulfill, reject in
      self.index.searchDisjunctiveFaceting(query, disjunctiveFacets: disjunctiveFacets, refinements: refinements, completionHandler: completionWrap(fulfill: fulfill, reject: reject))
    })
  }

  func searchForFacetValues(of facetName: String, matching text: String, query: Query? = nil) -> Promise<[String: Any]> {
    return promiseWrap({ fulfill, reject in
      self.index.searchForFacetValues(of: facetName, matching: text, query: query, completionHandler: completionWrap(fulfill: fulfill, reject: reject))
    })
  }

  func partialUpdateObject(_ object: [String: Any], withID objectID: String, createIfNotExists: Bool? = nil) -> Promise<[String: Any]> {
    return promiseWrap({ fulfill, reject in
      self.index.partialUpdateObject(object, withID: objectID, createIfNotExists: createIfNotExists, completionHandler: completionWrap(fulfill: fulfill, reject: reject))
    })
  }

  func partialUpdateObjects(_ objects: [[String: Any]], createIfNotExists: Bool? = nil) -> Promise<[String: Any]> {
    return promiseWrap({ fulfill, reject in
      self.index.partialUpdateObjects(objects, createIfNotExists: createIfNotExists, completionHandler: completionWrap(fulfill: fulfill, reject: reject))
    })
  }

  func batch(_ operations: [[String: Any]]) -> Promise<[String: Any]> {
    return promiseWrap({ fulfill, reject in
      self.index.batch(operations: operations, completionHandler: completionWrap(fulfill: fulfill, reject: reject))
    })
  }

  func clientBatch(_ operations: [[String: Any]]) -> Promise<[String: Any]> {
    return promiseWrap({ fulfill, reject in
      self.client.batch(operations: operations, completionHandler: completionWrap(fulfill: fulfill, reject: reject))
    })
  }

  func listIndexes() -> Promise<[String: Any]> {
    return promiseWrap({ fulfill, reject in
      self.client.listIndexes(completionHandler: completionWrap(fulfill: fulfill, reject: reject))
    })
  }

  func moveIndex(from srcIndexName: String, to dstIndexName: String) -> Promise<[String: Any]> {
    return promiseWrap({ fulfill, reject in
      self.client.moveIndex(from: srcIndexName, to: dstIndexName, completionHandler: completionWrap(fulfill: fulfill, reject: reject))
    })
  }

  func copyIndex(from srcIndexName: String, to dstIndexName: String) -> Promise<[String: Any]> {
    return promiseWrap({ fulfill, reject in
      self.client.copyIndex(from: srcIndexName, to: dstIndexName, completionHandler: completionWrap(fulfill: fulfill, reject: reject))
    })
  }

  func clearIndex() -> Promise<[String: Any]> {
    return promiseWrap({ fulfill, reject in
      self.index.clearIndex(completionHandler: completionWrap(fulfill: fulfill, reject: reject))
    })
  }

  func setSettings(_ settings: [String: Any], forwardToReplicas: Bool? = nil) -> Promise<[String: Any]> {
    return promiseWrap({ fulfill, reject in
      self.index.setSettings(settings, forwardToReplicas: forwardToReplicas, completionHandler: completionWrap(fulfill: fulfill, reject: reject))
    })
  }

  func getSettings() -> Promise<[String: Any]> {
    return promiseWrap({ fulfill, reject in
      self.index.getSettings(completionHandler: completionWrap(fulfill: fulfill, reject: reject))
    })
  }

  func getHitsCount(_ content: [String: Any]) -> Promise<Int> {
    let nbHits = content["nbHits"] as! Int
    return Promise(value: nbHits)
  }

  // Helpers

  func getValuePromise<T>(_ content: [String: Any], key: String) -> Promise<T> {
    let value = content[key] as! T
    return Promise(value: value)
  }
}
