//
//  String+HMAC.swift
//  
//
//  Created by Vladislav Fitc on 08/07/2020.
//

import Foundation
import CommonCrypto

extension String {

  func hmac(algorithm: HmacAlgorithm, key: String) -> String {
    var digest = [UInt8](repeating: 0, count: algorithm.digestLength)
    CCHmac(algorithm.algorithm, key, key.count, self, self.count, &digest)
    let data = Data(digest)
    return data.map { String(format: "%02hhx", $0) }.joined()
  }

}
