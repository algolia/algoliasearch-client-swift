//
//  RemoteIndex.swift
//  AlgoliaSearch
//
//  Created by Thibault Deutsch on 19/02/15.
//  Copyright (c) 2015 Algolia. All rights reserved.
//

import Foundation

/// Contains all the functions related to one index
///
/// You can use Client.getIndex(indexName) to retrieve this object
public class RemoteIndex {
    let indexName: String
    let client: Client
    let urlEncodedIndexName: String
    
    init(client: Client, indexName: String) {
        self.client = client
        self.indexName = indexName
        urlEncodedIndexName = indexName.urlEncode()
    }
    
    public func addObject(object: [String: AnyObject], block: CompletionHandlerType? = nil) {
        let path = "1/indexes/\(urlEncodedIndexName)"
        client.performHTTPQuery(path, method: .POST, body: object, block: block)
    }
    
    public func addObject(object: [String: AnyObject], withID objectID: String, block: CompletionHandlerType?) {
        let path = "1/indexes/\(urlEncodedIndexName)/\(objectID.urlEncode())"
        client.performHTTPQuery(path, method: .PUT, body: object, block: block)
    }
    
    public func addObjects(objects: [AnyObject], block: CompletionHandlerType? = nil) {
        let path = "1/indexes/\(urlEncodedIndexName)/batch"
        
        var requests = [AnyObject]()
        for object in objects {
            requests.append(["action": "addObject", "body": object])
        }
        let request = ["requests": requests]
        
        client.performHTTPQuery(path, method: .POST, body: request, block: block)
    }
    
    public func deleteObjects(objectIDs: [String], block: CompletionHandlerType? = nil) {
        let path = "1/indexes/\(urlEncodedIndexName)/batch"
        
        var requests = [AnyObject]()
        for id in objectIDs {
            requests.append(["action": "deleteObject", "objectID": id])
        }
        let request = ["requests": requests]
        
        client.performHTTPQuery(path, method: .POST, body: request, block: block)
    }
    
    public func getObject(objectID: String, block: CompletionHandlerType) {
        let path = "1/indexes/\(urlEncodedIndexName)/\(objectID.urlEncode())"
        client.performHTTPQuery(path, method: .GET, body: nil, block: block)
    }
    
    public func getObject(objectID: String, attributesToRetrieve attributes: [String], block: CompletionHandlerType) {
        let urlEncodedAttributes = Query.encodeForQuery(attributes, withKey: "attributes")
        let path = "1/indexes/\(urlEncodedIndexName)/\(objectID.urlEncode())?\(urlEncodedAttributes)"
        client.performHTTPQuery(path, method: .GET, body: nil, block: block)
    }
    
    public func getObjects(objectIDs: [String], block: CompletionHandlerType) {
        let path = "1/indexes/*/objects"
        
        var requests = [AnyObject]()
        for id in objectIDs {
            requests.append(["indexName": indexName, "objectID": id])
        }
        let request = ["requests": requests]
        
        client.performHTTPQuery(path, method: .POST, body: request, block: block)
    }
    
    public func partialUpdateObject(partialObject: [String: AnyObject], objectID: String, block: CompletionHandlerType? = nil) {
        let path = "1/indexes/\(urlEncodedIndexName)/\(objectID.urlEncode())/partial"
        client.performHTTPQuery(path, method: .POST, body: partialObject, block: block)
    }
    
    public func partialUpdateObjects(objects: [AnyObject], block: CompletionHandlerType? = nil) {
        let path = "1/indexes/\(urlEncodedIndexName)/batch"
        
        var requests = [AnyObject]()
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
    
    public func saveObject(object: [String: AnyObject], withID objectID: String, block: CompletionHandlerType? = nil) {
        let path = "1/indexes/\(urlEncodedIndexName)/\(objectID.urlEncode())"
        client.performHTTPQuery(path, method: .PUT, body: object, block: block)
    }
    
    public func saveObjects(objects: [AnyObject], block: CompletionHandlerType? = nil) {
        let path = "1/indexes/\(urlEncodedIndexName)/batch"
        
        var requests = [AnyObject]()
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
    
    public func deleteObject(objectID: String, block: CompletionHandlerType? = nil) {
        let path = "1/indexes/\(urlEncodedIndexName)/\(objectID.urlEncode())"
        client.performHTTPQuery(path, method: .DELETE, body: nil, block: block)
    }
    
    public func search(query: Query, block: CompletionHandlerType) {
        let path = "1/indexes/\(urlEncodedIndexName)/query"
        let request = ["params": query.buildURL()]
        client.performHTTPQuery(path, method: .POST, body: request, block: block)
    }
    
    //
    //-(void) cancelPreviousSearches
    //    {
    //        NSString *path = [NSString stringWithFormat:@"/1/indexes/%@/query", self.urlEncodedIndexName];
    //        [self.apiClient cancelQueries:@"POST" path:path];
    //}
    
    //
    //-(void) waitTask:(NSString*)taskID
    //success:(void(^)(ASRemoteIndex *index, NSString *taskID, NSDictionary *result))success
    //failure:(void(^)(ASRemoteIndex *index, NSString *taskID, NSString *errorMessage))failure
    //{
    //    NSString *path = [NSString stringWithFormat:@"/1/indexes/%@/task/%@", self.urlEncodedIndexName, taskID];
    //    [self.apiClient performHTTPQuery:path method:@"GET" body:nil index:0 timeout:self.apiClient.timeout success:^(id JSON) {
    //    NSString *status = [JSON valueForKey:@"status"];
    //    if ([status compare:@"published"] == NSOrderedSame) {
    //    if (success != nil)
    //    success(self, taskID, JSON);
    //    } else {
    //    [NSThread sleepForTimeInterval:0.1f];
    //    [self waitTask:taskID success:success failure:failure];
    //    }
    //    } failure:^(NSString *errorMessage) {
    //    if (failure != nil)
    //    failure(self, taskID, errorMessage);
    //    }];
    //}
    //
    
    public func getSettings(block: CompletionHandlerType) {
        let path = "1/indexes/\(urlEncodedIndexName)/settings"
        client.performHTTPQuery(path, method: .GET, body: nil, block: block)
    }
    
    public func setSettings(settings: [String: AnyObject], block: CompletionHandlerType? = nil) {
        let path = "1/indexes/\(urlEncodedIndexName)/settings"
        client.performHTTPQuery(path, method: .PUT, body: settings, block: block)
    }
    
    public func clearIndex(block: CompletionHandlerType? = nil) {
        let path = "1/indexes/\(urlEncodedIndexName)/clear"
        client.performHTTPQuery(path, method: .POST, body: nil, block: block)
    }
    
    public func listUserKeys(block: CompletionHandlerType) {
        let path = "1/indexes/\(urlEncodedIndexName)/keys"
        client.performHTTPQuery(path, method: .GET, body: nil, block: block)
    }
    
    // TODO: need to know for which keys the response is
    public func getUserKeyACL(key: String, block: CompletionHandlerType) {
        let path = "1/indexes/\(urlEncodedIndexName)/keys/\(key.urlEncode())"
        client.performHTTPQuery(path, method: .GET, body: nil, block: block)
    }
    
    public func deleteUserKey(key: String, block: CompletionHandlerType? = nil) {
        let path = "1/indexes/\(urlEncodedIndexName)/keys/\(key.urlEncode())"
        client.performHTTPQuery(path, method: .DELETE, body: nil, block: block)
    }
    
    public func addUserKey(acls: [String], block: CompletionHandlerType? = nil) {
        let path = "1/indexes/\(urlEncodedIndexName)/keys"
        let request = ["acl": acls]
        client.performHTTPQuery(path, method: .POST, body: request, block: block)
    }
    
    public func addUserKey(acls: [String], withValidity validity: UInt, maxQueriesPerIPPerHour maxQueries: UInt, maxHitsPerQuery maxHits: UInt, block: CompletionHandlerType? = nil) {
        let path = "1/indexes/\(urlEncodedIndexName)/keys"
        let request: [String: AnyObject] = [
            "acl": acls,
            "validity": validity,
            "maxQueriesPerIPPerHour": maxQueries,
            "maxHitsPerQuery": maxHits,
        ]
        
        client.performHTTPQuery(path, method: .POST, body: request, block: block)
    }
    
    public func updateUserKey(key: String, withACL acls: [String], block: CompletionHandlerType? = nil) {
        let path = "1/indexes/\(urlEncodedIndexName)/keys/\(key.urlEncode())"
        let request = ["acl": acls]
        client.performHTTPQuery(path, method: .PUT, body: request, block: block)
    }
    
    public func updateUserKey(key: Sring, withACL acls: [String], withValidity validity: UInt, maxQueriesPerIPPerHour maxQueries: UInt, maxHitsPerQuery maxHits: UInt, block: CompletionHandlerType? = nil) {
        let path = "1/indexes/\(urlEncodedIndexName)/keys/\(key.urlEncode())"
        let request: [String: AnyObject] = [
            "acl": acls,
            "validity": validity,
            "maxQueriesPerIPPerHour": maxQueries,
            "maxHitsPerQuery": maxHits,
        ]
        
        client.performHTTPQuery(path, method: .PUT, body: request, block: block)
    }
}

//
//-(void) browse:(NSUInteger)page hitsPerPage:(NSUInteger)hitsPerPage
//success:(void(^)(ASRemoteIndex *index, NSUInteger page, NSUInteger hitsPerPage, NSDictionary *result))success
//failure:(void(^)(ASRemoteIndex *index, NSUInteger page, NSUInteger hitsPerPage, NSString *errorMessage))failure
//{
//    NSString *path = [NSString stringWithFormat:@"/1/indexes/%@/browse?page=%lu&hitsPerPage=%lu", self.urlEncodedIndexName, (unsigned long)page, (unsigned long)hitsPerPage];
//    [self.apiClient performHTTPQuery:path method:@"GET" body:nil index:0 timeout:self.apiClient.timeout success:^(id JSON) {
//    if (success != nil)
//    success(self, page, hitsPerPage, JSON);
//    } failure:^(NSString *errorMessage) {
//    if (failure != nil)
//    failure(self, page, hitsPerPage, errorMessage);
//    }];
//}
//
//-(void) browse:(NSUInteger)page
//success:(void(^)(ASRemoteIndex *index, NSUInteger page, NSDictionary *result))success
//failure:(void(^)(ASRemoteIndex *index, NSUInteger page, NSString *errorMessage))failure
//{
//    NSString *path = [NSString stringWithFormat:@"/1/indexes/%@/browse?page=%lu", self.urlEncodedIndexName, (unsigned long)page];
//    [self.apiClient performHTTPQuery:path method:@"GET" body:nil index:0 timeout:self.apiClient.timeout success:^(id JSON) {
//    if (success != nil)
//    success(self, page, JSON);
//    } failure:^(NSString *errorMessage) {
//    if (failure != nil)
//    failure(self, page, errorMessage);
//    }];
//}
