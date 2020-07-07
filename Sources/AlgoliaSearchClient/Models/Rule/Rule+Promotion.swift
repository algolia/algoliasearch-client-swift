//
//  Rule+Promotion.swift
//  
//
//  Created by Vladislav Fitc on 05/05/2020.
//

import Foundation

extension Rule {

  public struct Promotion: Codable {

    /// Unique identifier of the object to promote.
    public let objectID: ObjectID

    /// Promoted rank for the object.
    public let position: Int

    public init(objectID: ObjectID, position: Int) {
      self.objectID = objectID
      self.position = position
    }

  }

}
