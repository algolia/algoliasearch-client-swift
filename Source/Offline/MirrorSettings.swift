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

