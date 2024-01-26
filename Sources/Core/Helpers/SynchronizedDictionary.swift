// SynchronizedDictionary.swift
//
// Created by Algolia on 08/01/2024
//

import Foundation

struct SynchronizedDictionary<K: Hashable, V> {
    private var dictionary = [K: V]()
    private let queue = DispatchQueue(
        label: "SynchronizedDictionary",
        qos: DispatchQoS.userInitiated,
        attributes: [DispatchQueue.Attributes.concurrent],
        autoreleaseFrequency: DispatchQueue.AutoreleaseFrequency.inherit,
        target: nil
    )

    subscript(key: K) -> V? {
        get {
            var value: V?

            queue.sync {
                value = dictionary[key]
            }

            return value
        }
        set {
            queue.sync(flags: DispatchWorkItemFlags.barrier) {
                dictionary[key] = newValue
            }
        }
    }
}
