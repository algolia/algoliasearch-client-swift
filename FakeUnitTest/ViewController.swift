//
//  ViewController.swift
//  FakeUnitTest
//
//  Created by Clément Le Provost on 26/08/16.
//  Copyright © 2016 Algolia. All rights reserved.
//

import AlgoliaSearch
import UIKit


class ViewController: UIViewController {
    var offlineClientTests = OfflineClientTests()
    var offlineIndexTests = OfflineIndexTests()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Clean-up.
        let client = OfflineClient(appID: "DONTCARE", apiKey: "NEVERMIND")
        try! NSFileManager.defaultManager().removeItemAtPath(client.rootDataDir)
        
        offlineClientTests.test()
        offlineIndexTests.test()
    }
}

