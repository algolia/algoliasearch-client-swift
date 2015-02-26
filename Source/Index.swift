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

/// Contains all the functions related to one index
///
/// You can use Client.getIndex(indexName) to retrieve this object
public class Index {
    let indexName: String
    let client: Client
    let urlEncodedIndexName: String
    
    init(client: Client, indexName: String) {
        self.client = client
        self.indexName = indexName
        urlEncodedIndexName = indexName.urlEncode()
    }
    
    public func addObject(object: [String: AnyObject], block: CompletionHandler? = nil) {
        let path = "1/indexes/\(urlEncodedIndexName)"
        client.performHTTPQuery(path, method: .POST, body: object, block: block)
    }
    
    public func addObject(object: [String: AnyObject], withID objectID: String, block: CompletionHandler?) {
        let path = "1/indexes/\(urlEncodedIndexName)/\(objectID.urlEncode())"
        client.performHTTPQuery(path, method: .PUT, body: object, block: block)
    }
    
    public func addObjects(objects: [AnyObject], block: CompletionHandler? = nil) {
        let path = "1/indexes/\(urlEncodedIndexName)/batch"
        
        var requests = [AnyObject]()
        requests.reserveCapacity(objects.count)
        for object in objects {
            requests.append(["action": "addObject", "body": object])
        }
        let request = ["requests": requests]
        
        client.performHTTPQuery(path, method: .POST, body: request, block: block)
    }
    
    public func deleteObjects(objectIDs: [String], block: CompletionHandler? = nil) {
        let path = "1/indexes/\(urlEncodedIndexName)/batch"
        
        var requests = [AnyObject]()
        requests.reserveCapacity(objectIDs.count)
        for id in objectIDs {
            requests.append(["action": "deleteObject", "objectID": id])
        }
        let request = ["requests": requests]
        
        client.performHTTPQuery(path, method: .POST, body: request, block: block)
    }
    
    public func getObject(objectID: String, block: CompletionHandler) {
        let path = "1/indexes/\(urlEncodedIndexName)/\(objectID.urlEncode())"
        client.performHTTPQuery(path, method: .GET, body: nil, block: block)
    }
    
    public func getObject(objectID: String, attributesToRetrieve attributes: [String], block: CompletionHandler) {
        let urlEncodedAttributes = Query.encodeForQuery(attributes, withKey: "attributes")
        let path = "1/indexes/\(urlEncodedIndexName)/\(objectID.urlEncode())?\(urlEncodedAttributes)"
        client.performHTTPQuery(path, method: .GET, body: nil, block: block)
    }
    
    public func getObjects(objectIDs: [String], block: CompletionHandler) {
        let path = "1/indexes/*/objects"
        
        var requests = [AnyObject]()
        requests.reserveCapacity(objectIDs.count)
        for id in objectIDs {
            requests.append(["indexName": indexName, "objectID": id])
        }
        let request = ["requests": requests]
        
        client.performHTTPQuery(path, method: .POST, body: request, block: block)
    }
    
    public func partialUpdateObject(partialObject: [String: AnyObject], objectID: String, block: CompletionHandler? = nil) {
        let path = "1/indexes/\(urlEncodedIndexName)/\(objectID.urlEncode())/partial"
        client.performHTTPQuery(path, method: .POST, body: partialObject, block: block)
    }
    
    public func partialUpdateObjects(objects: [AnyObject], block: CompletionHandler? = nil) {
        let path = "1/indexes/\(urlEncodedIndexName)/batch"
        
        var requests = [AnyObject]()
        requests.reserveCapacity(objects.count)
        for object in objects {
            if let object = object as? [String: AnyObject] {
                requests.append([
                    "action": "partialUpdateObject",
                    "objectID": object["objectID"] as String,
                    "body": object
                    ])
            }
        }
        let request = ["requests": requests]
        
        client.performHTTPQuery(path, method: .POST, body: request, block: block)
    }
    
    public func saveObject(object: [String: AnyObject], withID objectID: String, block: CompletionHandler? = nil) {
        let path = "1/indexes/\(urlEncodedIndexName)/\(objectID.urlEncode())"
        client.performHTTPQuery(path, method: .PUT, body: object, block: block)
    }
    
    public func saveObjects(objects: [AnyObject], block: CompletionHandler? = nil) {
        let path = "1/indexes/\(urlEncodedIndexName)/batch"
        
        var requests = [AnyObject]()
        requests.reserveCapacity(objects.count)
        for object in objects {
            if let object = object as? [String: AnyObject] {
                requests.append([
                    "action": "updateObject",
                    "objectID": object["objectID"] as String,
                    "body": object
                    ])
            }
        }
        let request = ["requests": requests]
        
        client.performHTTPQuery(path, method: .POST, body: request, block: block)
    }
    
    public func deleteObject(objectID: String, block: CompletionHandler? = nil) {
        let path = "1/indexes/\(urlEncodedIndexName)/\(objectID.urlEncode())"
        client.performHTTPQuery(path, method: .DELETE, body: nil, block: block)
    }
    
    public func search(query: Query, block: CompletionHandler) {
        let path = "1/indexes/\(urlEncodedIndexName)/query"
        let request = ["params": query.buildURL()]
        client.performHTTPQuery(path, method: .POST, body: request, block: block)
    }
    
    public func cancelPreviousSearch() {
        client.cancelQueries(.POST, path: "1/indexes/\(urlEncodedIndexName)/query")
    }
    
    public func waitTask(taskID: String, block: CompletionHandlerWithTask) {
        let path = "1/indexes/\(urlEncodedIndexName)/task/\(taskID.urlEncode())"
        client.performHTTPQuery(path, method: .GET, body: nil, block: { (JSON, error) -> Void in
            if let JSON = JSON as? [String: AnyObject] {
                if (JSON["status"] as? String) == "published" {
                    block(task: taskID, JSON: JSON, error: nil)
                } else {
                    NSThread.sleepForTimeInterval(0.1)
                    self.waitTask(taskID, block: block)
                }
            } else {
                block(task: taskID, JSON: JSON, error: error)
            }
        })
    }
    
    public func getSettings(block: CompletionHandler) {
        let path = "1/indexes/\(urlEncodedIndexName)/settings"
        client.performHTTPQuery(path, method: .GET, body: nil, block: block)
    }
    
    public func setSettings(settings: [String: AnyObject], block: CompletionHandler? = nil) {
        let path = "1/indexes/\(urlEncodedIndexName)/settings"
        client.performHTTPQuery(path, method: .PUT, body: settings, block: block)
    }
    
    public func clearIndex(block: CompletionHandler? = nil) {
        let path = "1/indexes/\(urlEncodedIndexName)/clear"
        client.performHTTPQuery(path, method: .POST, body: nil, block: block)
    }
    
    public func listUserKeys(block: CompletionHandler) {
        let path = "1/indexes/\(urlEncodedIndexName)/keys"
        client.performHTTPQuery(path, method: .GET, body: nil, block: block)
    }
    
    // TODO: need to know for which keys the response is
    public func getUserKeyACL(key: String, block: CompletionHandler) {
        let path = "1/indexes/\(urlEncodedIndexName)/keys/\(key.urlEncode())"
        client.performHTTPQuery(path, method: .GET, body: nil, block: block)
    }
    
    public func deleteUserKey(key: String, block: CompletionHandler? = nil) {
        let path = "1/indexes/\(urlEncodedIndexName)/keys/\(key.urlEncode())"
        client.performHTTPQuery(path, method: .DELETE, body: nil, block: block)
    }
    
    public func addUserKey(acls: [String], block: CompletionHandler? = nil) {
        let path = "1/indexes/\(urlEncodedIndexName)/keys"
        let request = ["acl": acls]
        client.performHTTPQuery(path, method: .POST, body: request, block: block)
    }
    
    public func addUserKey(acls: [String], withValidity validity: UInt, maxQueriesPerIPPerHour maxQueries: UInt, maxHitsPerQuery maxHits: UInt, block: CompletionHandler? = nil) {
        let path = "1/indexes/\(urlEncodedIndexName)/keys"
        let request: [String: AnyObject] = [
            "acl": acls,
            "validity": validity,
            "maxQueriesPerIPPerHour": maxQueries,
            "maxHitsPerQuery": maxHits,
        ]
        
        client.performHTTPQuery(path, method: .POST, body: request, block: block)
    }
    
    public func updateUserKey(key: String, withACL acls: [String], block: CompletionHandler? = nil) {
        let path = "1/indexes/\(urlEncodedIndexName)/keys/\(key.urlEncode())"
        let request = ["acl": acls]
        client.performHTTPQuery(path, method: .PUT, body: request, block: block)
    }
    
    public func updateUserKey(key: String, withACL acls: [String], withValidity validity: UInt, maxQueriesPerIPPerHour maxQueries: UInt, maxHitsPerQuery maxHits: UInt, block: CompletionHandler? = nil) {
        let path = "1/indexes/\(urlEncodedIndexName)/keys/\(key.urlEncode())"
        let request: [String: AnyObject] = [
            "acl": acls,
            "validity": validity,
            "maxQueriesPerIPPerHour": maxQueries,
            "maxHitsPerQuery": maxHits,
        ]
        
        client.performHTTPQuery(path, method: .PUT, body: request, block: block)
    }
    
    public func browse(page: UInt, block: CompletionHandlerWithIndexAndPage) {
        let path = "1/indexes/\(urlEncodedIndexName)/browse?page=\(page)"
        client.performHTTPQuery(path, method: .GET, body: nil, block: { (JSON, error) -> Void in
            block(index: self, page: page, hitsPerPage: 0, JSON: JSON, error: error)
        })
    }
    
    public func browse(page: UInt, hitsPerPage: UInt, block: CompletionHandlerWithIndexAndPage) {
        let path = "1/indexes/\(urlEncodedIndexName)/browse?page=\(page)&hitsPerPage=\(hitsPerPage)"
        client.performHTTPQuery(path, method: .GET, body: nil, block: { (JSON, error) -> Void in
            block(index: self, page: page, hitsPerPage: hitsPerPage, JSON: JSON, error: error)
        })
    }
}
