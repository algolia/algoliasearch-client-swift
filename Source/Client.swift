//
//  Client.swift
//  AlgoliaSearch
//
//  Created by Thibault Deutsch on 13/02/15.
//  Copyright (c) 2015 Algolia. All rights reserved.
//

import Foundation
import Alamofire

// TODO: need to know for which key is the response, sometimes other information needed. Fix this.

public typealias CompletionHandlerType = (JSON: AnyObject?, error: NSError?) -> Void?

/// Entry point in the Swift API.
///
/// You should instantiate a Client object with your AppID, ApiKey and Hosts
/// to start using Algolia Search API
public class Client {
    public let appID: String
    public let apiKey: String
    public let tagFilters: String?
    public let userToken: String?
    public let hostnames: [String]
    
    public var timeout: NSTimeInterval = 30 {
        didSet {
            Alamofire.Manager.sharedInstance.session.configuration.timeoutIntervalForRequest = timeout;
        }
    }
    
    /// Algolia Search initialization
    ///
    /// :param: appID the application ID you have in your admin interface
    /// :param: apiKey a valid API key for the service
    /// :param: hostnames the list of hosts that you have received for the service
    /// :param: tagFilters value of the header X-Algolia-TagFilters
    /// :param: userToken value of the header X-Algolia-UserToken
    public init(appID: String, apiKey: String, hostnames: [String]? = nil, tagFilters: String? = nil, userToken: String? = nil) {
        if countElements(appID) == 0 {
            NSException(name: "InvalidArgument", reason: "Application ID must be set", userInfo: nil).raise()
        } else if countElements(apiKey) == 0 {
            NSException(name: "InvalidArgument", reason: "APIKey must be set", userInfo: nil).raise()
        }
        
        // TODO: dsn, dsnhost?
        self.appID = appID
        self.apiKey = apiKey
        self.tagFilters = tagFilters
        self.userToken = userToken
        
        if (hostnames == nil || hostnames!.count == 0) {
            var generateHostname = [String]()
            for i in 1...3 {
                generateHostname.append("\(appID)-\(i).algolia.net")
            }
            self.hostnames = generateHostname
        } else {
            self.hostnames = hostnames!
        }
        self.hostnames.shuffle()
        
        let version = NSBundle(identifier: "com.algolia.AlgoliaSearch")!.infoDictionary!["CFBundleShortVersionString"] as String
        var HTTPHeader = [
            "X-Algolia-API-Key": self.apiKey,
            "X-Algolia-Application-Id": self.appID,
            "User-Agent": "Algolia for Swift \(version)"
        ]
        
        if let tagFilters = self.tagFilters {
            HTTPHeader["X-Algolia-TagFilters"] = tagFilters
        }
        if let userToken = self.userToken {
            HTTPHeader["X-Algolia-UserToken"] = userToken
        }
        
        Alamofire.Manager.sharedInstance.session.configuration.HTTPAdditionalHeaders = HTTPHeader
    }
    
    public func setExtraHeader(value: String, forKey key: String) {
        if (Alamofire.Manager.sharedInstance.session.configuration.HTTPAdditionalHeaders != nil) {
            Alamofire.Manager.sharedInstance.session.configuration.HTTPAdditionalHeaders!.updateValue(value, forKey: key)
        } else {
            let HTTPHeader = [key: value]
            Alamofire.Manager.sharedInstance.session.configuration.HTTPAdditionalHeaders = HTTPHeader
        }
    }
    
    // MARK: - Operations
    
    /// List all existing indexes
    ///
    /// :return: JSON Object in the block in the form:
    /// { "items": [ {"name": "contacts", "createdAt": "2013-01-18T15:33:13.556Z"},
    ///              {"name": "notes", "createdAt": "2013-01-18T15:33:13.556Z"}]}
    public func listIndexes(block: CompletionHandlerType?) {
        performHTTPQuery("1/indexes", method: .GET, body: nil, block: block)
    }
    
    /// Move an existing index.
    ///
    /// :param: srcIndexName the name of index to move.
    /// :param: dstIndexName the new index name that will contains sourceIndexName (destination will be overriten if it already exist).
    public func moveIndex(srcIndexName: String, dstIndexName: String, block: CompletionHandlerType?) {
        let path = "1/indexes/\(srcIndexName.urlEncode())/operation"
        let request = [
            "destination": dstIndexName,
            "operation": "move"
        ]
        
        performHTTPQuery(path, method: .POST, body: request, block: block)
    }
    
    /// Copy an existing index.
    ///
    /// :param: srcIndexName the name of index to copy.
    /// :param: dstIndexName the new index name that will contains a copy of sourceIndexName (destination will be overriten if it already exist).
    public func copyIndex(srcIndexName: String, dstIndexName: String, block: CompletionHandlerType?) {
        let path = "1/indexes/\(srcIndexName.urlEncode())/operation"
        let request = [
            "destination": dstIndexName,
            "operation": "copy"
        ]
        
        performHTTPQuery(path, method: .POST, body: request, block: block)
    }
    
    /// Delete an index
    ///
    /// :param: indexName the name of index to delete
    /// :return: JSON Object in the block in the form: { "deletedAt": "2013-01-18T15:33:13.556Z", "taskID": 721 }
    public func deleteIndex(indexName: String, block: CompletionHandlerType?) {
        let path = "1/indexes/\(indexName.urlEncode())"
        performHTTPQuery(path, method: .DELETE, body: nil, block: block)
    }
    
    /// Return 10 last log entries.
    public func getLogs(block: CompletionHandlerType) {
        performHTTPQuery("1/logs", method: .GET, body: nil, block: block)
    }
    
    /// Return last logs entries.
    ///
    /// :param: offset Specify the first entry to retrieve (0-based, 0 is the most recent log entry).
    /// :param: length Specify the maximum number of entries to retrieve starting at offset. Maximum allowed value: 1000.
    public func getLogsWithOffset(offset: UInt, lenght: UInt, block: CompletionHandlerType) {
        let path = "1/logs?offset=\(offset)&lenght=\(lenght)"
        performHTTPQuery(path, method: .GET, body: nil, block: block)
    }
    
    /// Return last logs entries.
    ///
    /// :param: offset Specify the first entry to retrieve (0-based, 0 is the most recent log entry).
    /// :param: length Specify the maximum number of entries to retrieve starting at offset. Maximum allowed value: 1000.
    public func getLogsWithType(type: String, offset: UInt, lenght: UInt, block: CompletionHandlerType) {
        let path = "1/logs?offset=\(offset)&lenght=\(lenght)&type=\(type)"
        performHTTPQuery(path, method: .GET, body: nil, block: block)
    }
    
    public func listUserKeys(block: CompletionHandlerType) {
        performHTTPQuery("1/keys", method: .GET, body: nil, block: block)
    }
    
    public func getUserKeyACL(key: String, block: CompletionHandlerType) {
        let path = "1/keys/\(key)"
        performHTTPQuery(path, method: .GET, body: nil, block: block)
    }
    
    public func deleteUserKey(key: String, block: CompletionHandlerType?) {
        let path = "1/keys/\(key)"
        performHTTPQuery(path, method: .DELETE, body: nil, block: block)
    }
    
    public func addUserKey(acls: [String], block: CompletionHandlerType?) {
        let request = ["acl": acls]
        performHTTPQuery("1/keys", method: .POST, body: request, block: block)
    }
    
    public func addUserKey(acls: [String], withValidity validity: UInt, maxQueriesPerIPPerHour maxQueries: UInt, maxHitsPerQuery maxHits: UInt, block: CompletionHandlerType?) {
        let request: [String: AnyObject] = [
            "acl": acls,
            "validity": validity,
            "maxQueriesPerIPPerHour": maxQueries,
            "maxHitsPerQuery": maxHits,
        ]
        
        performHTTPQuery("1/keys", method: .POST, body: request, block: block)
    }
    
    public func addUserKey(acls: [String], withIndexes indexes: [String], withValidity validity: UInt, maxQueriesPerIPPerHour maxQueries: UInt, maxHitsPerQuery maxHits: UInt, block: CompletionHandlerType?) {
        let request: [String: AnyObject] = [
            "acl": acls,
            "indexes": indexes,
            "validity": validity,
            "maxQueriesPerIPPerHour": maxQueries,
            "maxHitsPerQuery": maxHits,
        ]
        
        performHTTPQuery("1/keys", method: .POST, body: request, block: block)
    }
    
    public func updateUserKey(key: String, withACL acls: [String], block: CompletionHandlerType?) {
        let path = "1/keys/\(key)"
        let request = ["acl": acls]
        performHTTPQuery(path, method: .PUT, body: request, block: block)
    }
    
    public func updateUserKey(key: String, withACL acls: [String], andValidity validity: UInt, maxQueriesPerIPPerHour maxQueries: UInt, maxHitsPerQuery maxHits: UInt, block: CompletionHandlerType?) {
        let path = "1/keys/\(key)"
        let request: [String: AnyObject] = [
            "acl": acls,
            "validity": validity,
            "maxQueriesPerIPPerHour": maxQueries,
            "maxHitsPerQuery": maxHits,
        ]
        
        performHTTPQuery(path, method: .PUT, body: request, block: block)
    }
    
    public func updateUserKey(key: String, withACL acls: [String], withIndexes indexes: [String], andValidity validity: UInt, maxQueriesPerIPPerHour maxQueries: UInt, maxHitsPerQuery maxHits: UInt, block: CompletionHandlerType?) {
        let path = "1/keys/\(key)"
        let request: [String: AnyObject] = [
            "acl": acls,
            "indexes": indexes,
            "validity": validity,
            "maxQueriesPerIPPerHour": maxQueries,
            "maxHitsPerQuery": maxHits,
        ]
        
        performHTTPQuery(path, method: .PUT, body: request, block: block)
    }
    
    // MARK: - Network
    
    /// Perform an HTTP Query
    func performHTTPQuery(path: String, method: Alamofire.Method, body: [String: AnyObject]?, index: Int = 0, block: CompletionHandlerType?) {
        assert(index < hostnames.count, "\(index) < \(hostnames.count) !")
        
        Alamofire.request(method, "https://\(hostnames[index])/\(path)", parameters: body).responseJSON {
            (request, response, data, error) -> Void in
            if let statusCode = response?.statusCode {
                if let block = block {
                    switch(statusCode) {
                    case 200, 201:
                        block(JSON: data, error: nil)
                    case 400:
                        block(JSON: nil, error: NSError(domain: "Bad request argument", code: 400, userInfo: nil))
                    case 403:
                        block(JSON: nil, error: NSError(domain: "Invalid Application-ID or API-Key", code: 403, userInfo: nil))
                    case 404:
                        block(JSON: nil, error: NSError(domain: "Resource does not exist", code: 404, userInfo: nil))
                    default:
                        if let errorMessage = (data as [String: String])["message"] {
                            block(JSON: nil, error: NSError(domain: errorMessage, code: 0, userInfo: nil))
                        } else {
                            block(JSON: nil, error: NSError(domain: "No error message", code: 0, userInfo: nil))
                        }
                    }
                }
            } else {
                if (index + 1) < self.hostnames.count {
                    self.performHTTPQuery(path, method: method, body: body, index: index + 1, block: block)
                } else {
                    block?(JSON: nil, error: error)
                }
            }
        }
    }
}