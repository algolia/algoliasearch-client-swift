//
//  Copyright (c) 2015-2016 Algolia
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

import AlgoliaSearchSDK
import Foundation


/// An index with offline mirroring capabilities.
/// NOTE: Requires Algolia's SDK.
///
public class MirroredIndex : Index {
    /// Getter returning covariant-typed client.
    // TODO: Could not find a way to implement proper covariant properties in Swift.
    public var offlineClient: OfflineClient {
        return self.client as! OfflineClient
    }
    
    /// The local index mirroring this remote index (lazy instantiated, only if mirroring is activated).
    lazy var localIndex: ASLocalIndex? = ASLocalIndex(dataDir: self.offlineClient.rootDataDir!, appID: self.client.appID, indexName: self.indexName)
    
    /// The mirrored index settings.
    let mirrorSettings = MirrorSettings()
    
    /// Whether the index is mirrored locally. Default = false.
    public var mirrored: Bool = false {
        didSet {
            if (mirrored) {
                do {
                    try NSFileManager.defaultManager().createDirectoryAtPath(self.indexDataDir, withIntermediateDirectories: true, attributes: nil)
                } catch _ {
                    // Ignore
                }
                mirrorSettings.load(self.mirrorSettingsFilePath)
            }
        }
    }
    
    /// Data selection queries.
    public var queries: [String] {
        get { return mirrorSettings.queries }
        set {
            mirrorSettings.queries = newValue
            mirrorSettings.queriesModificationDate = NSDate()
            mirrorSettings.save(mirrorSettingsFilePath)
        }
    }
    
    /// Time interval between two syncs. Default = 1 hour.
    public var delayBetweenSyncs : NSTimeInterval = 60 * 60
    
    // Sync status:
    
    /// Syncing indicator.
    /// NOTE: To prevent concurrent access to this variable, we always access it from the main thread.
    private var syncing: Bool = false
    
    private var tmpDir : String?
    private var syncError : Bool = false
    private var settingsFilePath: String?
    private var objectsFilePaths: [String]?
    
    private var mirrorSettingsFilePath: String {
        get { return "\(self.indexDataDir)/mirror.plist" }
    }
    
    private var indexDataDir: String {
        get { return "\(self.offlineClient.rootDataDir!)/\(self.client.appID)/\(self.indexName)" }
    }
    
    // TODO: Move to top-level/other file?
    class MirrorSettings {
        var lastSyncDate: NSDate = NSDate(timeIntervalSince1970: 0)
        var queries : [String] = [] ///< Data selection queries.
        var queriesModificationDate: NSDate = NSDate(timeIntervalSince1970: 0)
        
        func save(filePath: String) {
            let settings = [
                "lastSyncDate": lastSyncDate,
                "queries": queries,
                "queriesModificationDate": queriesModificationDate
            ]
            (settings as NSDictionary).writeToFile(filePath, atomically: true)
        }
        
        func load(filePath: String) {
            if let settings = NSDictionary(contentsOfFile: filePath) {
                if let lastSyncDate = settings["lastSyncDate"] as? NSDate {
                    self.lastSyncDate = lastSyncDate
                }
                if let queries = settings["queries"] as? [String] {
                    self.queries = queries
                }
                if let queriesModificationDate = settings["queriesModificationDate"] as? NSDate {
                    self.queriesModificationDate = queriesModificationDate
                }
            }
        }
    }
    
    public override init(client: Client, indexName: String) {
        assert(client is OfflineClient);
        super.init(client: client, indexName: indexName)
    }
    
    // ----------------------------------------------------------------------
    // Sync
    // ----------------------------------------------------------------------

    /// Add a data selection query to the local mirror.
    /// The query is not run immediately. It will be run during the subsequent refreshes.
    /// @pre The index must have been marked as mirrored.
    public func addDataSelectionQuery(query: Query) {
        assert(mirrored);
        _addQuery(query)
        mirrorSettings.queriesModificationDate = NSDate()
        mirrorSettings.save(self.mirrorSettingsFilePath)
    }
    
    /// Add any number of data selection queries to the local mirror.
    /// The query is not run immediately. It will be run during the subsequent refreshes.
    /// @pre The index must have been marked as mirrored.
    public func addDataSelectionQueries(queries: [Query]) {
        assert(mirrored);
        for query in queries {
            _addQuery(query)
        }
        mirrorSettings.queriesModificationDate = NSDate()
        mirrorSettings.save(self.mirrorSettingsFilePath)
    }
    
    private func _addQuery(originalQuery: Query) {
        // Make sure we don't retrieve unnecessary information.
        let query = Query(copy: originalQuery)
        query.attributesToHighlight = []
        query.attributesToSnippet = []
        query.getRankingInfo = false
        mirrorSettings.queries.append(query.buildURL())
    }
    
    public func sync() {
        assert(NSThread.isMainThread(), "Should only be called from the main thread")
        if syncing {
            return
        }
        syncing = true
        dispatch_async(dispatch_get_global_queue(QOS_CLASS_BACKGROUND, 0)) {
            self._sync()
        }
    }
    
    public func syncIfNeeded() {
        assert(NSThread.isMainThread(), "Should only be called from the main thread")
        let currentDate = NSDate()
        if currentDate.timeIntervalSinceDate(mirrorSettings.lastSyncDate) > self.delayBetweenSyncs
            || mirrorSettings.queriesModificationDate.compare(mirrorSettings.lastSyncDate) == .OrderedDescending {
                sync()
        }
    }
    
    /// Refresh the local mirror.
    private func _sync() {
        assert(!NSThread.isMainThread()) // make sure it's run in the background
        assert(self.mirrored, "Mirroring not activated on this index")
        assert(self.offlineClient.rootDataDir != nil, "Please enable offline mode in client first")
        
        // Create temporary directory.
        do {
            self.tmpDir = NSTemporaryDirectory() + "/algolia/" + NSUUID().UUIDString
            try NSFileManager.defaultManager().createDirectoryAtPath(self.tmpDir!, withIntermediateDirectories: true, attributes: nil)
        } catch _ {
            NSLog("ERROR: Could not create temporary directory '%@'", self.tmpDir!)
        }
        
        // NOTE: We use `NSOperation`s to handle dependencies between tasks.
        syncError = false
        
        // Task: Download index settings.
        // TODO: Set a different timeout.
        // TODO: Should we use host retry like for realtime queries? Not sure it's necessary.
        // TODO: Factorize query construction with regular code.
        let path = "1/indexes/\(urlEncodedIndexName)/settings"
        let urlString = "https://\(client.readQueryHostnames.first!)/\(path)"
        let url = NSURL(string: urlString)
        let request = NSURLRequest(URL: url!)
        let settingsOperation = URLSessionOperation(session: client.manager.session, request: request) {
            (data: NSData?, response: NSURLResponse?, error: NSError?) in
            if (data != nil) {
                self.settingsFilePath = "\(self.tmpDir!)/settings.json"
                data!.writeToFile(self.settingsFilePath!, atomically: false)
            } else {
                self.syncError = true
            }
        }
        self.offlineClient.buildQueue.addOperation(settingsOperation)
        
        // Tasks: Perform data selection queries.
        var queryNo = 0
        self.objectsFilePaths = []
        var objectOperations: [NSOperation] = []
        for query in mirrorSettings.queries {
            let thisQueryNo = ++queryNo
            let path = "1/indexes/\(urlEncodedIndexName)/query"
            let urlString = "https://\(client.readQueryHostnames.first!)/\(path)"
            let request = client.manager.encodeParameter(CreateNSURLRequest(.POST, URL: urlString), parameters: ["params": query])
            let operation = URLSessionOperation(session: client.manager.session, request: request) {
                (data: NSData?, response: NSURLResponse?, error: NSError?) in
                if (data != nil) {
                    let objectFilePath = "\(self.tmpDir!)/\(thisQueryNo).json"
                    self.objectsFilePaths?.append(objectFilePath)
                    data!.writeToFile(objectFilePath, atomically: false)
                } else {
                    self.syncError = true
                }
            }
            objectOperations.append(operation)
            self.offlineClient.buildQueue.addOperation(operation)
        }
        
        // Task: build the index using the downloaded files.
        let buildIndexOperation = NSBlockOperation() {
            if !self.syncError {
                let status = self.localIndex!.buildFromSettingsFile(self.settingsFilePath!, objectFiles: self.objectsFilePaths!)
                if status != 200 {
                    NSLog("Error %d building index %@", status, self.indexName)
                } else {
                    // Remember the sync's date
                    self.mirrorSettings.lastSyncDate = NSDate()
                    self.mirrorSettings.save(self.mirrorSettingsFilePath)
                }
            }
            
            // Clean-up.
            do {
                try NSFileManager.defaultManager().removeItemAtPath(self.tmpDir!)
            } catch _ {
                // Ignore error
            }
            self.tmpDir = nil
            self.settingsFilePath = nil
            self.objectsFilePaths = nil
            
            // Mark the sync as finished.
            dispatch_async(dispatch_get_main_queue()) {
                self.syncing = false
            }
        }
        // Make sure this task is run after all the download tasks.
        buildIndexOperation.addDependency(settingsOperation)
        for operation in objectOperations {
            buildIndexOperation.addDependency(operation)
        }
        self.offlineClient.buildQueue.addOperation(buildIndexOperation)
    }
    
    // ----------------------------------------------------------------------
    // Search
    // ----------------------------------------------------------------------

    /// Search inside the index
    public override func search(query: Query, block: CompletionHandler) {
        // TODO: A lot of code duplication (with `Index`) in this method. See if we can reduce it.
        let path = "1/indexes/\(urlEncodedIndexName)/query"
        let request = ["params": query.buildURL()]
        
        // First try the in-memory query cache.
        let cacheKey = "\(path)_body_\(request)"
        if let content = searchCache?.objectForKey(cacheKey) {
            block(content: content, error: nil)
        }
            // Otherwise, run an online query.
        else {
            client.performHTTPQuery(path, method: .POST, body: request, hostnames: client.readQueryHostnames, isSearchQuery: true) { (content, error) -> Void in
                assert(content != nil || error != nil)
                if content != nil {
                    self.searchCache?.setObject(content!, forKey: cacheKey)
                    block(content: content, error: error)
                } else if isErrorTransient(error!) && self.mirrored {
                    self.searchMirror(query, block: block)
                }
                else {
                    block(content: content, error: error)
                }
            }
        }
    }

    
    /// Search the local mirror.
    public func searchMirror(query: Query, block: CompletionHandler) {
        let callingQueue = NSOperationQueue.currentQueue() ?? NSOperationQueue.mainQueue()
        self.offlineClient.searchQueue.addOperationWithBlock() {
            self._searchMirror(query) {
                (content, error) -> Void in
                callingQueue.addOperationWithBlock() {
                    block(content: content, error: error)
                }
            }
        }
    }
    
    /// Search the local mirror synchronously.
    private func _searchMirror(query: Query, block: CompletionHandler) {
        assert(!NSThread.isMainThread()) // make sure it's run in the background
        assert(self.mirrored, "Mirroring not activated on this index")
        
        var content: [String: AnyObject]?
        var error: NSError?
        
        let searchResults = localIndex!.search(query.buildURL())
        if searchResults.statusCode == 200 {
            assert(searchResults.data != nil)
            do {
                let json = try NSJSONSerialization.JSONObjectWithData(searchResults.data!, options: NSJSONReadingOptions(rawValue: 0))
                if json is [String: AnyObject] {
                    content = (json as! [String: AnyObject])
                } else {
                    error = NSError(domain: AlgoliaSearchErrorDomain, code: 500, userInfo: [NSLocalizedDescriptionKey: "Invalid JSON returned"])
                }
            } catch let _error as NSError {
                error = _error
            }
        } else {
            error = NSError(domain: AlgoliaSearchErrorDomain, code: Int(searchResults.statusCode), userInfo: nil)
        }
        assert(content != nil || error != nil)
        block(content: content, error: error)
    }
    
    // ----------------------------------------------------------------------
    // Browse
    // ----------------------------------------------------------------------
    
    public func browseMirror(query: Query, block: CompletionHandler) {
        let callingQueue = NSOperationQueue.currentQueue() ?? NSOperationQueue.mainQueue()
        self.offlineClient.searchQueue.addOperationWithBlock() {
            self._browseMirror(query) {
                (content, error) -> Void in
                callingQueue.addOperationWithBlock() {
                    block(content: content, error: error)
                }
            }
        }
    }

    /// Browse the local mirror synchronously.
    private func _browseMirror(query: Query, block: CompletionHandler) {
        assert(!NSThread.isMainThread()) // make sure it's run in the background
        assert(self.mirrored, "Mirroring not activated on this index")
        
        var content: [String: AnyObject]?
        var error: NSError?
        
        let searchResults = localIndex!.browse(query.buildURL())
        // TODO: Factorize this code with above and with online requests.
        if searchResults.statusCode == 200 {
            assert(searchResults.data != nil)
            do {
                let json = try NSJSONSerialization.JSONObjectWithData(searchResults.data!, options: NSJSONReadingOptions(rawValue: 0))
                if json is [String: AnyObject] {
                    content = (json as! [String: AnyObject])
                } else {
                    error = NSError(domain: AlgoliaSearchErrorDomain, code: 500, userInfo: [NSLocalizedDescriptionKey: "Invalid JSON returned"])
                }
            } catch let _error as NSError {
                error = _error
            }
        } else {
            error = NSError(domain: AlgoliaSearchErrorDomain, code: Int(searchResults.statusCode), userInfo: nil)
        }
        assert(content != nil || error != nil)
        block(content: content, error: error)
    }

}
