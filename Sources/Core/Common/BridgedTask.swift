//
//  BridgedTask.swift
//
//
//  Created by Algolia on 07/03/2024.
//

#if COCOAPODS
    public typealias BridgedTask = _Concurrency.Task
#else
    public typealias BridgedTask = Task
#endif
