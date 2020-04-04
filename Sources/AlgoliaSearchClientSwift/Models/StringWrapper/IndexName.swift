//
//  IndexName.swift
//  
//
//  Created by Vladislav Fitc on 03/03/2020.
//

import Foundation

public struct IndexName: StringWrapper {

  public var rawValue: String

  func path(with completion: PathCompletion? = nil) -> String {
    let base = "\(Route.indexesV1)/\(rawValue.utf8)"
    return completion.flatMap { base + "/" + $0.rawValue } ?? base
  }

  public init(rawValue: String) {
    self.rawValue = rawValue
  }

}

extension IndexName {
  
  struct PathCompletion {
    
    let rawValue: String
    
    private init(_ rawValue: String) { self.rawValue = rawValue }
    
    static var batch: Self { .init(#function) }
    static var operation: Self { .init(#function) }
    static func objectID(_ objectID: ObjectID, partial: Bool = false) -> Self { return .init(objectID.rawValue + (partial ? "/partial" : "")) }
    static var objects: Self { .init("*/objects") }
    static var deleteByQuery: Self { .init(#function) }
    static var clear: Self { .init(#function) }
    static var query: Self { .init(#function) }
    static var browse: Self { .init(#function) }
    static func searchFacets(for attribute: Attribute) -> Self { return .init("facets/\(attribute.rawValue)/query") }
    static var settings: Self { .init(#function) }
    static func task(for taskID: TaskID) -> Self { .init("task/\(taskID.rawValue)") }
    
  }

  
}
