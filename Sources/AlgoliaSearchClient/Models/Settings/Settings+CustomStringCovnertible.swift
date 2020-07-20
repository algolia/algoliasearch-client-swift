//
//  Settings+CustomStringConvertible.swift
//  
//
//  Created by Vladislav Fitc on 08/07/2020.
//

import Foundation

extension Settings: CustomStringConvertible {

  public var description: String {

    let encoder = JSONEncoder()
    encoder.outputFormatting = .prettyPrinted

    if let data = try? encoder.encode(self),
      let string = String(data: data, encoding: .utf8) {
      return string
    } else {
      return "encoding error"
    }

  }

}
