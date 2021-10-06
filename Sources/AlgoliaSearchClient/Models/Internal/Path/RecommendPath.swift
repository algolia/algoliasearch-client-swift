//
//  RecommendPath.swift
//  
//
//  Created by Vladislav Fitc on 31/08/2021.
//

import Foundation

struct RecommendCompletion: PathComponent {

  var parent: IndexRoute?

  let rawValue: String

  private init(_ rawValue: String) { self.rawValue = rawValue }

  static var recommendations: Self { .init(#function) }

}
