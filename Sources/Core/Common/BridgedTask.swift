//
//  BridgedTask.swift
//
//
//  Created by Algolia on 07/03/2024.
//

#if COCOAPODS
    typealias BridgedTask = _Concurrency.Task
#else
    typealias BridgedTask = Task
#endif
