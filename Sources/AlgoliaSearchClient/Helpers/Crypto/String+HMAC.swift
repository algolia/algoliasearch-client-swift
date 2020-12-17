//
//  String+HMAC.swift
//  
//
//  Created by Vladislav Fitc on 08/07/2020.
//

import Foundation

#if os(Linux)
import Crypto
#else
import CommonCrypto
#endif

extension String {

  func hmac256(withKey key: String) -> String {
    #if os(Linux)
    let key = SymmetricKey(data: Data(key.utf8))
    let digest = Array(HMAC<SHA256>.authenticationCode(for: Data(utf8), using: key))
    #else
    let algorithm = HmacAlgorithm.sha256
    var digest = [UInt8](repeating: 0, count: algorithm.digestLength)
    CCHmac(algorithm.algorithm, key, key.count, self, self.count, &digest)
    #endif
    let data = Data(digest)
    return data.map { String(format: "%02hhx", $0) }.joined()
  }

}
