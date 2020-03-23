//
//  PolygonTests.swift
//
//
//  Created by Vladislav Fitc on 20/03/2020.
//

import Foundation
import XCTest
@testable import AlgoliaSearchClientSwift

class PolygonTests: XCTestCase {
  
  func testDecoding() {
    
    testDecoding([0, 1, 2, 3, 4, 5, 6, 7], expected: Polygon(.init(latitude: 0, longitude: 1),
                                                             .init(latitude: 2, longitude: 3),
                                                             .init(latitude: 4, longitude: 5),
                                                             .init(latitude: 6, longitude: 7)))
  }
  
  func testEncoding() {
    testEncoding(Polygon(.init(latitude: 0, longitude: 1),
                         .init(latitude: 2, longitude: 3),
                         .init(latitude: 4, longitude: 5),
                         .init(latitude: 6, longitude: 7)),
                 expected: [0, 1, 2, 3, 4, 5, 6, 7])
  }
  
}
