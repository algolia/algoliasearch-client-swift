//
//  Data+JSONString.swift
//  
//
//  Created by Vladislav Fitc on 23/02/2021.
//

import Foundation

extension Data {
  
  var jsonString: String? {
    return (try? JSONSerialization.jsonObject(with: self, options: .allowFragments))
      .flatMap {
        let writingOptions: JSONSerialization.WritingOptions
        if #available(OSX 10.13, *) {
          writingOptions = [.prettyPrinted, .fragmentsAllowed, .sortedKeys]
        } else {
          writingOptions = [.prettyPrinted, .fragmentsAllowed]
        }
        return try? JSONSerialization.data(withJSONObject: $0, options: writingOptions)
      }
      .flatMap { String(data: $0, encoding: .utf8) }
  }
  
}
