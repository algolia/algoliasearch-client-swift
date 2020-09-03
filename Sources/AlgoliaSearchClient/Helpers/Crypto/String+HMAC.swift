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

  #if os(Linux)
  public func hmac(_ key: SymmetricKeySize) -> String {
    let sk = SymmetricKey(size: key)
    let data = self.data(using: .utf8)!
    let mac = HMAC<SHA512>.authenticationCode(for: data, using: sk)
    return String(describing: mac)
  }
  #else
  func hmac(algorithm: HmacAlgorithm, key: String) -> String {
    var digest = [UInt8](repeating: 0, count: algorithm.digestLength)
    CCHmac(algorithm.algorithm, key, key.count, self, self.count, &digest)
    let data = Data(digest)
    return data.map { String(format: "%02hhx", $0) }.joined()
  }
  #endif

}
