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
    var tests = OfflineIndexTests()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        tests.test()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

}

