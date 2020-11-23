//
//  HMAC.swift
//  
//
//  Created by Vladislav Fitc on 02/06/2020.
//

import Foundation
#if os(Linux)
#else
import CommonCrypto

enum HmacAlgorithm {

  case sha1, md5, sha256, sha384, sha512, sha224

  var algorithm: CCHmacAlgorithm {
    var alg = 0
    switch self {
    case .sha1:
      alg = kCCHmacAlgSHA1
    case .md5:
      alg = kCCHmacAlgMD5
    case .sha256:
      alg = kCCHmacAlgSHA256
    case .sha384:
      alg = kCCHmacAlgSHA384
    case .sha512:
      alg = kCCHmacAlgSHA512
    case .sha224:
      alg = kCCHmacAlgSHA224
    }
    return CCHmacAlgorithm(alg)
  }

  var digestLength: Int {
    var len: Int32 = 0
    switch self {
    case .sha1:
      len = CC_SHA1_DIGEST_LENGTH
    case .md5:
      len = CC_MD5_DIGEST_LENGTH
    case .sha256:
      len = CC_SHA256_DIGEST_LENGTH
    case .sha384:
      len = CC_SHA384_DIGEST_LENGTH
    case .sha512:
      len = CC_SHA512_DIGEST_LENGTH
    case .sha224:
      len = CC_SHA224_DIGEST_LENGTH
    }
    return Int(len)
  }

}
#endif
