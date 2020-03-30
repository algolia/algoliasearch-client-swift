//
//  ObjectRequest.swift
//  
//
//  Created by Vladislav Fitc on 28/03/2020.
//

import Foundation

struct ObjectRequest: Codable {
 
  /**
   IndexName containing the object.
   */
  let indexName: IndexName
  
  /**
   * The ObjectID of the object within that index.
   */
  let objectID: ObjectID
  
  /**
   List of attributes to retrieve. By default, all retrievable attributes are returned.
   */
  let attributesToRetrieve: [Attribute]?
  
}
