//
//  Client.swift
//  AlgoliaSearch
//
//  Created by Thibault Deutsch on 13/02/15.
//  Copyright (c) 2015 Algolia. All rights reserved.
//

import Foundation
import Alamofire

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
    
    let timeout = 30
    
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
        
        let version = NSBundle.mainBundle().infoDictionary!["CFBundleShortVersionString"] as String
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
        // TODO: better header, using URLRequestConvertible
    }
    
    public func setExtraHeader(value: String, forKey key: String) {
        if (Alamofire.Manager.sharedInstance.session.configuration.HTTPAdditionalHeaders != nil) {
            Alamofire.Manager.sharedInstance.session.configuration.HTTPAdditionalHeaders!.updateValue(value, forKey: key)
        } else {
            let HTTPHeader = [key: value]
            Alamofire.Manager.sharedInstance.session.configuration.HTTPAdditionalHeaders = HTTPHeader
        }
    }
}
