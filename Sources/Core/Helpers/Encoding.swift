//
//  Encoding.swift
//
//
//  Created by Algolia on 22/02/2024.
//

import Foundation
#if os(Linux)
    import Crypto
#else
    import CommonCrypto
#endif

public extension String {
    func hmac256(withKey key: String) -> String {
        #if os(Linux)
            let key = SymmetricKey(data: Data(key.utf8))
            let digest = Array(HMAC<SHA256>.authenticationCode(for: Data(utf8), using: key))
        #else
            var digest = [UInt8](repeating: 0, count: Int(CC_SHA256_DIGEST_LENGTH))
            CCHmac(CCHmacAlgorithm(kCCHmacAlgSHA256), key, key.count, self, self.count, &digest)
        #endif
        let data = Data(digest)
        return data.map { String(format: "%02hhx", $0) }.joined()
    }
}
