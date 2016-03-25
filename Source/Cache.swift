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

class ExpiringCacheItem {
    let expiringCacheItemDate: NSDate
    let content: [String: AnyObject]
    
    init(content: [String: AnyObject]) {
        self.content = content
        self.expiringCacheItemDate = NSDate()
    }
}

class ExpiringCache {
    private let cache = NSCache()
    private let expiringTimeInterval: NSTimeInterval
    
    private var cacheKeys = [String]()
    private var timer: NSTimer? = nil
    
    init(expiringTimeInterval: NSTimeInterval) {
        self.expiringTimeInterval = expiringTimeInterval
        
        // Garbage collector like, for the expired cache
        timer = NSTimer(timeInterval: 2 * expiringTimeInterval, target: self, selector: #selector(ExpiringCache.clearExpiredCache), userInfo: nil, repeats: true)
        timer!.tolerance = expiringTimeInterval * 0.5
        NSRunLoop.mainRunLoop().addTimer(timer!, forMode: NSDefaultRunLoopMode)
    }
    
    deinit {
        timer!.invalidate()
    }
    
    func objectForKey(key: String) -> [String: AnyObject]? {
        if let object = cache.objectForKey(key) as? ExpiringCacheItem {
            let timeSinceCache = abs(object.expiringCacheItemDate.timeIntervalSinceNow)
            if timeSinceCache > expiringTimeInterval {
                cache.removeObjectForKey(key)
            } else {
                return object.content
            }
        }
        
        return nil
    }
    
    func setObject(obj: [String: AnyObject], forKey key: String) {
        cache.setObject(ExpiringCacheItem(content: obj), forKey: key)
        cacheKeys.append(key)
    }
    
    func clearCache() {
        cache.removeAllObjects()
        cacheKeys.removeAll(keepCapacity: true)
    }
    
    @objc func clearExpiredCache() {
        var tmp = [String]()
        
        for key in cacheKeys {
            if let object = cache.objectForKey(key) as? ExpiringCacheItem {
                let timeSinceCache = abs(object.expiringCacheItemDate.timeIntervalSinceNow)
                if timeSinceCache > expiringTimeInterval {
                    cache.removeObjectForKey(key)
                } else {
                    tmp.append(key)
                }
            }
        }
        
        cacheKeys = tmp
    }
}