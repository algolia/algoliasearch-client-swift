//
//  Copyright (c) 2016 Algolia
//  http://www.algolia.com/
//
//  Permission is hereby granted, free of charge, to any person obtaining a copy
//  of this software and associated documentation files (the "Software"), to deal
//  in the Software without restriction, including without limitation the rights
//  to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
//  copies of the Software, and to permit persons to whom the Software is
//  furnished to do so, subject to the following conditions:
//
//  The above copyright notice and this permission notice shall be included in
//  all copies or substantial portions of the Software.
//
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
//  IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
//  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
//  AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
//  LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
//  OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
//  THE SOFTWARE.
//

#if !os(watchOS)

  import Foundation
  import SystemConfiguration

  /// Detects network reachability.
  ///
  protocol NetworkReachability {
    // MARK: Properties

    /// Test if network connectivity is currently available.
    ///
    /// - returns: true if network connectivity is available, false otherwise.
    ///
    func isReachable() -> Bool
  }

  /// Detects network reachability using the system's built-in mechanism.
  ///
  class SystemNetworkReachability: NetworkReachability {
    // MARK: Properties

    /// Reachability handle used to test connectivity.
    private var reachability: SCNetworkReachability

    // MARK: Initialization

    init() {
      // Create reachability handle to an all-zeroes address.
      if #available(iOS 9, OSX 10.11, tvOS 9, *) {
        var zeroAddress6 = SystemNetworkReachability.zeroAddress6
        reachability = withUnsafePointer(to: &zeroAddress6) {
          $0.withMemoryRebound(to: sockaddr.self, capacity: 1) {
            SCNetworkReachabilityCreateWithAddress(nil, $0)
          }
        }!
      } else {
        var zeroAddress = SystemNetworkReachability.zeroAddress
        reachability = withUnsafePointer(to: &zeroAddress) {
          $0.withMemoryRebound(to: sockaddr.self, capacity: 1) {
            SCNetworkReachabilityCreateWithAddress(nil, $0)
          }
        }!
      }
    }

    /// Test if network connectivity is currently available.
    ///
    /// - returns: true if network connectivity is available, false otherwise.
    ///
    func isReachable() -> Bool {
      var flags: SCNetworkReachabilityFlags = []
      if !SCNetworkReachabilityGetFlags(reachability, &flags) {
        return false
      }

      let reachable = flags.contains(.reachable)
      let connectionRequired = flags.contains(.connectionRequired)
      return reachable && !connectionRequired
    }

    // MARK: Constants

    /// An all zeroes IP address.
    static let zeroAddress: sockaddr_in = {
      var address = sockaddr_in()
      address.sin_len = UInt8(MemoryLayout<sockaddr_in>.size)
      address.sin_family = sa_family_t(AF_INET)
      return address
    }()

    /// An all zeroes IP address.
    static let zeroAddress6: sockaddr_in6 = {
      var address = sockaddr_in6()
      address.sin6_len = UInt8(MemoryLayout<sockaddr_in6>.size)
      address.sin6_family = sa_family_t(AF_INET6)
      return address
    }()
  }

#endif // !os(watchOS)
