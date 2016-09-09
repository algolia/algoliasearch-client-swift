//
//  MirrorSettings.swift
//  Pods
//
//  Created by Clément Le Provost on 02/03/16.
//
//

import Foundation


internal class MirrorSettings {
    var lastSyncDate: Date?
    var queries : [DataSelectionQuery] = []
    var queriesModificationDate: Date?
    
    /// Serialize the settings to a plist and save them to disk.
    func save(_ filePath: String) {
        var queriesJson: [JSONObject] = []
        for query in queries {
            queriesJson.append([
                "query": query.query.build(),
                "maxObjects": query.maxObjects
            ])
        }
        var settings: [String: Any] = [
            "queries": queriesJson
        ]
        settings["lastSyncDate"] = lastSyncDate
        settings["queriesModificationDate"] = queriesModificationDate
        (settings as NSDictionary).write(toFile: filePath, atomically: true)
    }

    /// Read a plist from the disk and parse the settings from it.
    func load(_ filePath: String) {
        self.queries.removeAll()
        if let settings = NSDictionary(contentsOfFile: filePath) {
            if let lastSyncDate = settings["lastSyncDate"] as? Date {
                self.lastSyncDate = lastSyncDate
            }
            if let queriesJson = settings["queries"] as? [JSONObject] {
                for queryJson in queriesJson {
                    if let queryString = queryJson["query"] as? String, let maxObjects = queryJson["maxObjects"] as? Int {
                        self.queries.append(DataSelectionQuery(query: Query.parse(queryString), maxObjects: maxObjects))
                    }
                }
            }
            if let queriesModificationDate = settings["queriesModificationDate"] as? Date {
                self.queriesModificationDate = queriesModificationDate
            }
        }
    }
}

