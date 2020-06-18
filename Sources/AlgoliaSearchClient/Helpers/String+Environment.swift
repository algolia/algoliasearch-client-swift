//
//  String+Environment.swift
//  
//
//  Created by Vladislav Fitc on 20/03/2020.
//

import Foundation

extension String {

  init?(environmentVariable: String) {
    if
      let rawValue = getenv(environmentVariable),
      let value = String(utf8String: rawValue) {
      self = value
    } else {
      return nil
    }
  }

}
