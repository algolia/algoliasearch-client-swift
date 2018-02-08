//
//  TestHelpers.swift
//  AlgoliaSearch OSX
//
//  Created by Robert Mogos on 06/02/2018.
//  Copyright © 2018 Algolia. All rights reserved.
//

import Foundation
import AlgoliaSearch
import PromiseKit
import XCTest

extension IndexTests {
  
  func addObject(_ object:[String: Any]) -> Promise<[String: Any]> {
    return promiseWrap({ fulfill, reject in
      self.index.addObject(object, completionHandler:completionWrap(fulfill: fulfill, reject: reject))
    })
  }
  
  func addObjects(_ objects:[[String: Any]]) -> Promise<[String: Any]> {
    return promiseWrap({ fulfill, reject in
      self.index.addObjects(objects, completionHandler:completionWrap(fulfill: fulfill, reject: reject))
    })
  }
  
  func saveObject(_ object:[String: Any]) -> Promise<[String: Any]> {
    return promiseWrap({ fulfill, reject in
      self.index.saveObject(object, completionHandler:completionWrap(fulfill: fulfill, reject: reject))
    })
  }
  
  func saveObjects(_ objects:[[String: Any]]) -> Promise<[String: Any]> {
    return promiseWrap({ fulfill, reject in
      self.index.saveObjects(objects, completionHandler:completionWrap(fulfill: fulfill, reject: reject))
    })
  }
  
  func deleteObject(_ object:[String: Any]) -> Promise<[String: Any]> {
    return promiseWrap({ fulfill, reject in
      self.index.deleteObject(withID: object["objectID"]! as! String, completionHandler: completionWrap(fulfill: fulfill, reject: reject))
    })
  }
  
  func deleteObjects(_ objects:[String]) -> Promise<[String: Any]> {
    return promiseWrap({ fulfill, reject in
      self.index.deleteObjects(withIDs: objects, completionHandler: completionWrap(fulfill: fulfill, reject: reject))
    })
  }
  
  func getObject(_ objectID: String) -> Promise<[String: Any]> {
    return promiseWrap({ fulfill, reject in
      self.index.getObject(withID: objectID, completionHandler: completionWrap(fulfill: fulfill, reject: reject))
    })
  }
  
  func getObjects(_ objectIDs:[String], attributesToRetrieve: [String]? = nil) -> Promise<[String: Any]> {
    return promiseWrap({ fulfill, reject in
      self.index.getObjects(withIDs: objectIDs, attributesToRetrieve: attributesToRetrieve, completionHandler: completionWrap(fulfill: fulfill, reject: reject))
    })
  }
  
  func waitTask(_ object:[String: Any]) -> Promise<[String: Any]> {
    return promiseWrap({ fulfill, reject in
      guard let taskID = object["taskID"] as? Int else {
        reject(NSError(domain: "com.algolia.com", code: -1, userInfo: [NSLocalizedDescriptionKey:"Wait task failed"]))
        return
      }
      self.index.waitTask(withID: taskID, completionHandler: completionWrap(fulfill: fulfill, reject: reject))
    })
  }
  
  func query(_ query: String? = "") -> Promise<[String: Any]> {
    return promiseWrap({ fulfill, reject in
      self.index.search(Query(query:query), completionHandler: completionWrap(fulfill: fulfill, reject: reject))
    })
  }
    
  func partialUpdateObject(_ object:[String: Any], withID objectID: String, createIfNotExists: Bool? = nil) -> Promise<[String: Any]> {
      return promiseWrap({ fulfill, reject in
          self.index.partialUpdateObject(object, withID: objectID, createIfNotExists: createIfNotExists, completionHandler: completionWrap(fulfill: fulfill, reject: reject))
      })
  }
  
  func getHitsCount(_ content:[String: Any]) -> Promise<Int>{
    let nbHits = content["nbHits"] as! Int
    return Promise(value: nbHits)
  }
  
  func getValuePromise<T>(_ content:[String: Any], key:String) -> Promise<T>{
    let value = content[key] as! T
    return Promise(value: value)
  }
  
}
