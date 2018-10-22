//
//  Copyright (c) 2015 Algolia
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

import Foundation

/// HTTP method definitions.
internal enum HTTPMethod: String {
  case GET
  case POST
  case PUT
  case DELETE
}

/// Abstraction of `NSURLSession`.
/// Only for the sake of unit tests.
internal protocol URLSession {
  func dataTask(with request: URLRequest, completionHandler: @escaping (Data?, URLResponse?, Error?) -> Void) -> URLSessionDataTask
  func finishTasksAndInvalidate()
}

// Convince the compiler that NSURLSession does implements our custom protocol.
extension Foundation.URLSession: URLSession {}

#if os(iOS) && DEBUG

  import CoreTelephony
  import SystemConfiguration

  /// Wrapper around an `NSURLSession`, adding logging facilities.
  ///
  internal class URLSessionLogger: NSObject, URLSession {
    static var epoch: Date = Date()

    struct RequestStat {
      // TODO: Log network type.
      let startTime: Date
      let host: String
      var networkType: String?
      var responseTime: TimeInterval?
      var cancelled: Bool = false
      var dataSize: Int?
      var statusCode: Int?

      init(startTime: Date, host: String) {
        self.startTime = startTime
        self.host = host
      }

      var description: String {
        var description = "@\(Int(startTime.timeIntervalSince(URLSessionLogger.epoch) * 1000))ms; \(host); \(networkType != nil ? networkType! : "?")"
        if let responseTime = responseTime, let dataSize = dataSize, let statusCode = statusCode {
          description += "; \(Int(responseTime * 1000))ms; \(dataSize)B; \(statusCode)"
        }
        return description
      }
    }

    /// The wrapped session.
    let session: URLSession

    /// Stats.
    private(set) var stats: [RequestStat] = []

    /// Queue used to serialize concurrent accesses to this object.
    private let queue = DispatchQueue(label: "URLSessionLogger.lock")

    /// Temporary stats under construction (ongoing requests).
    private var tmpStats: [URLSessionTask: RequestStat] = [:]

    /// Used to determine overall network type.
    private let defaultRouteReachability: SCNetworkReachability

    /// Used to get the mobile data network type.
    private let networkInfo = CTTelephonyNetworkInfo()

    init(session: URLSession) {
      self.session = session
      if #available(iOS 9, OSX 10.11, *) {
        var zeroAddress6: sockaddr_in6 = sockaddr_in6()
        zeroAddress6.sin6_len = UInt8(MemoryLayout.size(ofValue: zeroAddress6))
        zeroAddress6.sin6_family = sa_family_t(AF_INET6)
        defaultRouteReachability = withUnsafePointer(to: &zeroAddress6) {
          let zeroAddressAsSockaddr = UnsafePointer<sockaddr>(OpaquePointer($0))
          return SCNetworkReachabilityCreateWithAddress(nil, zeroAddressAsSockaddr)!
        }
      } else {
        var zeroAddress: sockaddr_in = sockaddr_in()
        zeroAddress.sin_len = UInt8(MemoryLayout.size(ofValue: zeroAddress))
        zeroAddress.sin_family = sa_family_t(AF_INET)
        defaultRouteReachability = withUnsafePointer(to: &zeroAddress) {
          let zeroAddressAsSockaddr = UnsafePointer<sockaddr>(OpaquePointer($0))
          return SCNetworkReachabilityCreateWithAddress(nil, zeroAddressAsSockaddr)!
        }
      }

      // Reset the (global) epoch for logging.
      URLSessionLogger.epoch = Date()
    }

    func dataTask(with request: URLRequest, completionHandler: @escaping (Data?, URLResponse?, Error?) -> Void) -> URLSessionDataTask {
      var task: URLSessionDataTask!
      let startTime = Date()
      let networkType = getNetworkType()
      task = session.dataTask(with: request, completionHandler: completionHandler)
      queue.sync {
        self.tmpStats[task] = RequestStat(startTime: startTime, host: request.url!.host!)
        self.tmpStats[task]?.networkType = networkType
      }
      task.addObserver(self, forKeyPath: "state", options: .new, context: nil)
      return task
    }

    func finishTasksAndInvalidate() {
      session.finishTasksAndInvalidate()
    }

    override func observeValue(forKeyPath keyPath: String?, of object: Any?, change _: [NSKeyValueChangeKey: Any]?, context _: UnsafeMutableRawPointer?) {
      if let task = object as? URLSessionTask {
        if keyPath == "state" {
          if task.state == .canceling {
            queue.sync {
              self.tmpStats[task]!.cancelled = true
            }
          }
          if task.state == .completed {
            let stopTime = NSDate()
            queue.sync {
              var stat = self.tmpStats[task]!
              stat.responseTime = stopTime.timeIntervalSince(stat.startTime)
              stat.dataSize = Int(task.countOfBytesReceived)
              if let response = task.response as? HTTPURLResponse {
                stat.statusCode = response.statusCode
              } else if let error = task.error as NSError? {
                stat.statusCode = error.code
              }
              self.stats.append(stat)
              self.tmpStats.removeValue(forKey: task)
            }
            task.removeObserver(self, forKeyPath: "state")
            dump()
          }
        }
      }
    }

    func dump() {
      queue.sync {
        for stat in self.stats {
          print("[NET] \(stat.description)")
        }
        self.stats.removeAll()
      }
    }

    // MARK: Network status

    /// Return the current network type as a human-friendly string.
    ///
    private func getNetworkType() -> String? {
      var flags = SCNetworkReachabilityFlags()
      if SCNetworkReachabilityGetFlags(defaultRouteReachability, &flags) {
        if flags.contains(.isWWAN) {
          if let technology = networkInfo.currentRadioAccessTechnology {
            return URLSessionLogger.description(radioAccessTechnology: technology)
          }
        } else {
          return "WIFI"
        }
      }
      return nil
    }

    /// Convert one of the enum-like `CTRadioAccessTechnology*` constants into a human-friendly string.
    ///
    static func description(radioAccessTechnology: String) -> String {
      switch radioAccessTechnology {
      case CTRadioAccessTechnologyGPRS: return "GPRS"
      case CTRadioAccessTechnologyEdge: return "EDGE"
      case CTRadioAccessTechnologyWCDMA: return "WCDMA"
      case CTRadioAccessTechnologyHSDPA: return "HSDPA"
      case CTRadioAccessTechnologyHSUPA: return "HSUPA"
      case CTRadioAccessTechnologyCDMA1x: return "CDMA(1x)"
      case CTRadioAccessTechnologyCDMAEVDORev0: return "CDMA(EVDORev0)"
      case CTRadioAccessTechnologyCDMAEVDORevA: return "CDMA(EVDORevA)"
      case CTRadioAccessTechnologyCDMAEVDORevB: return "CDMA(EVDORevB)"
      case CTRadioAccessTechnologyeHRPD: return "HRPD"
      case CTRadioAccessTechnologyLTE: return "LTE"
      default: return "?"
      }
    }
  }

#endif // DBEUG
