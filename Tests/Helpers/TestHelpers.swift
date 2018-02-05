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
  
  func waitTask(_ object:[String: Any]) -> Promise<[String: Any]> {
    return promiseWrap({ fulfill, reject in
      guard let taskID = object["taskID"] as? Int else {
        reject(NSError(domain: "com.algolia.com", code: -1, userInfo: [NSLocalizedDescriptionKey:"Wait task failed"]))
        return
      }
      self.index.waitTask(withID: taskID, completionHandler: completionWrap(fulfill: fulfill, reject: reject))
    })
  }
  
  func emptyQuery() -> Promise<[String: Any]> {
    return promiseWrap({ fulfill, reject in
      self.index.search(Query(), completionHandler: completionWrap(fulfill: fulfill, reject: reject))
    })
  }
  
  func getHitsCount(_ content:[String: Any]) -> Promise<Int>{
    let nbHits = content["nbHits"] as! Int
    return Promise(value: nbHits)
  }
  
}
