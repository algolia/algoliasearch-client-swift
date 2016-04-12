//
//  MirrorSettings.swift
//  Pods
//
//  Created by Clément Le Provost on 02/03/16.
//
//

import Foundation


class MirrorSettings {
    var lastSyncDate: NSDate = NSDate(timeIntervalSince1970: 0)
    var queries : [DataSelectionQuery] = []
    var queriesModificationDate: NSDate = NSDate(timeIntervalSince1970: 0)
    
    /// Serialize the settings to a plist and save them to disk.
    func save(filePath: String) {
        var queriesJson: [[String: AnyObject]] = []
        for query in queries {
            queriesJson.append([
                "query": query.query.build(),
                "maxObjects": query.maxObjects
            ])
        }
        let settings = [
            "lastSyncDate": lastSyncDate,
            "queries": queriesJson,
            "queriesModificationDate": queriesModificationDate
        ]
        (settings as NSDictionary).writeToFile(filePath, atomically: true)
    }

    /// Read a plist from the disk and parse the settings from it.
    func load(filePath: String) {
        self.queries.removeAll()
        if let settings = NSDictionary(contentsOfFile: filePath) {
            if let lastSyncDate = settings["lastSyncDate"] as? NSDate {
                self.lastSyncDate = lastSyncDate
            }
            if let queriesJson = settings["queries"] as? [[String: AnyObject]] {
                for queryJson in queriesJson {
                    if let queryString = queryJson["query"] as? String, maxObjects = queryJson["maxObjects"] as? Int {
                        self.queries.append(DataSelectionQuery(query: Query.parse(queryString), maxObjects: maxObjects))
                    }
                }
            }
            if let queriesModificationDate = settings["queriesModificationDate"] as? NSDate {
                self.queriesModificationDate = queriesModificationDate
            }
        }
    }
}

