//
//  String+Base64.swift
//  
//
//  Created by Vladislav Fitc on 02/06/2020.
//

import Foundation

extension String {

  func fromBase64() -> String? {
    guard let data = Data(base64Encoded: self) else {
      return nil
    }
    return String(data: data, encoding: .utf8)
  }

  func toBase64() -> String {
    return Data(self.utf8).base64EncodedString()
  }

}
