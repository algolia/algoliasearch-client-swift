//
//  ABTestPath.swift
//  
//
//  Created by Vladislav Fitc on 23/02/2021.
//

import Foundation

struct ABTestRoute: PathComponent {

  var parent: Path?

  let rawValue: String

  private init(_ rawValue: String) { self.rawValue = rawValue }

  static func ABTestID(_ abTestID: ABTestID) -> Self { .init(abTestID.rawValue) }

}

struct ABTestCompletion: PathComponent {

  var parent: ABTestRoute?

  let rawValue: String

  private init(_ rawValue: String) { self.rawValue = rawValue }

  static var stop: Self { .init(#function) }

}
