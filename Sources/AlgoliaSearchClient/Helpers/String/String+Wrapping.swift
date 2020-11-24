//
//  String+Wrapping.swift
//  
//
//  Created by Vladislav Fitc on 23/11/2020.
//

import Foundation

extension String {

  func wrappedInQuotes() -> String { "\"\(self)\"" }
  func wrappedInBrackets() -> String { "[\(self)]" }

}
