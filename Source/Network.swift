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
enum HTTPMethod: String {
    case GET = "GET"
    case POST = "POST"
    case PUT = "PUT"
    case DELETE = "DELETE"
}

/// Abstraction of `NSURLSession`.
/// Only for the sake of unit tests.
protocol URLSession {
    func dataTaskWithRequest(request: NSURLRequest, completionHandler: (NSData?, NSURLResponse?, NSError?) -> Void) -> NSURLSessionDataTask
}

// Convince the compiler that NSURLSession does implements our custom protocol.
extension NSURLSession: URLSession {
}


#if os(iOS) && DEBUG

import CoreTelephony
import SystemConfiguration

/// Wrapper around an `NSURLSession`, adding logging facilities.
///
class URLSessionLogger: NSObject, URLSession {
    static var epoch: NSDate!
    
    struct RequestStat {
        // TODO: Log network type.
        let startTime: NSDate
        let host: String
        var networkType: String?
        var responseTime: NSTimeInterval?
        var cancelled: Bool = false
        var dataSize: Int?
        var statusCode: Int?
        
        init(startTime: NSDate, host: String) {
            self.startTime = startTime
            self.host = host
        }
        
        var description: String {
            var description = "@\(Int(startTime.timeIntervalSinceDate(URLSessionLogger.epoch) * 1000))ms; \(host); \(networkType != nil ? networkType! : "?")"
            if let responseTime = responseTime, dataSize = dataSize, statusCode = statusCode {
                description += "; \(Int(responseTime * 1000))ms; \(dataSize)B; \(statusCode)"
            }
            return description
        }
    }
    
    /// The wrapped session.
    let session: NSURLSession
    
    /// Stats.
    private(set) var stats: [RequestStat] = []
    
    /// Queue used to serialize concurrent accesses to this object.
    private let queue = dispatch_queue_create(nil, DISPATCH_QUEUE_SERIAL)
    
    /// Temporary stats under construction (ongoing requests).
    private var tmpStats: [NSURLSessionTask: RequestStat] = [:]
    
    /// Used to determine overall network type.
    private let defaultRouteReachability: SCNetworkReachability
    
    /// Used to get the mobile data network type.
    private let networkInfo = CTTelephonyNetworkInfo()
    
    init(session: NSURLSession) {
        self.session = session
        var zeroAddress = sockaddr_in()
        zeroAddress.sin_len = UInt8(sizeofValue(zeroAddress))
        zeroAddress.sin_family = sa_family_t(AF_INET)
        defaultRouteReachability = withUnsafePointer(&zeroAddress) {
            SCNetworkReachabilityCreateWithAddress(nil, UnsafePointer($0))!
        }
        
        // Reset the (global) epoch for logging.
        URLSessionLogger.epoch = NSDate()
    }
    
    func dataTaskWithRequest(request: NSURLRequest, completionHandler: (NSData?, NSURLResponse?, NSError?) -> Void) -> NSURLSessionDataTask {
        var task: NSURLSessionDataTask!
        let startTime = NSDate()
        let networkType = getNetworkType()
        task = session.dataTaskWithRequest(request, completionHandler: completionHandler)
        dispatch_sync(self.queue) {
            self.tmpStats[task] = RequestStat(startTime: startTime, host: request.URL!.host!)
            self.tmpStats[task]?.networkType = networkType
        }
        task.addObserver(self, forKeyPath: "state", options: .New, context: nil)
        return task
    }
    
    override func observeValueForKeyPath(keyPath: String?, ofObject object: AnyObject?, change: [String : AnyObject]?, context: UnsafeMutablePointer<Void>) {
        if let task = object as? NSURLSessionTask {
            if keyPath == "state" {
                if task.state == .Canceling {
                    dispatch_sync(self.queue) {
                        self.tmpStats[task]!.cancelled = true
                    }
                }
                if task.state == .Completed {
                    let stopTime = NSDate()
                    dispatch_sync(self.queue) {
                        var stat = self.tmpStats[task]!
                        stat.responseTime = stopTime.timeIntervalSinceDate(stat.startTime)
                        stat.dataSize = Int(task.countOfBytesReceived)
                        if let response = task.response as? NSHTTPURLResponse {
                            stat.statusCode = response.statusCode
                        } else if let error = task.error {
                            stat.statusCode = error.code
                        }
                        self.stats.append(stat)
                        self.tmpStats.removeValueForKey(task)
                    }
                    task.removeObserver(self, forKeyPath: "state")
                    dump()
                }
            }
        }
    }
    
    func dump() {
        dispatch_sync(self.queue) {
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
            if flags.contains(.IsWWAN) {
                if let technology = networkInfo.currentRadioAccessTechnology {
                    return URLSessionLogger.radioAccessTechnologyDescription(technology)
                }
            } else {
                return "WIFI"
            }
        }
        return nil
    }

    /// Convert one of the enum-like `CTRadioAccessTechnology*` constants into a human-friendly string.
    ///
    static func radioAccessTechnologyDescription(radioAccessTechnology: String) -> String {
        switch (radioAccessTechnology) {
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
