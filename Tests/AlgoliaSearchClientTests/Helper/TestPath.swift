//
//  TestPath.swift
//  
//
//  Created by Vladislav Fitc on 14/11/2020.
//

import Foundation
@testable import AlgoliaSearchClient

struct TestPath {
  static var path: TestPathLevel2 = TestPathRoot() >>> TestPathLevel1() >>> TestPathLevel2()
}

struct TestPathRoot: RootPath {

  var rawValue: String = "/my"

}

struct TestPathLevel1: PathComponent {

  var parent: TestPathRoot?

  var rawValue: String = "test"

}

struct TestPathLevel2: PathComponent {

  var parent: TestPathLevel1?

  var rawValue: String = "path"

}
