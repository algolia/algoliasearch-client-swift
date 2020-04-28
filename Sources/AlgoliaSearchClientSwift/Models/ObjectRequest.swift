//
//  ObjectRequest.swift
//  
//
//  Created by Vladislav Fitc on 28/03/2020.
//

import Foundation

public struct ObjectRequest: Codable {

  /// IndexName containing the object.
  public let indexName: IndexName

  /// The ObjectID of the object within that index.
  public let objectID: ObjectID

  /// List of attributes to retrieve. By default, all retrievable attributes are returned.
  public let attributesToRetrieve: [Attribute]?

  public init(indexName: IndexName, objectID: ObjectID, attributesToRetrieve: [Attribute]? = nil) {
    self.indexName = indexName
    self.objectID = objectID
    self.attributesToRetrieve = attributesToRetrieve
  }

}
