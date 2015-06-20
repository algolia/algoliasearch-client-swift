//
//  Helpers.swift
//  AlgoliaSearch
//
//  Created by Thibault Deutsch on 21/06/15.
//  Copyright (c) 2015 Algolia. All rights reserved.
//

import Foundation

func safeIndexName(name: String) -> String {
    if let travisBuild = NSProcessInfo.processInfo().environment["TRAVIS_JOB_NUMBER"] as? String {
        return "\(name)_travis-\(travisBuild)"
    } else {
        return name
    }
}