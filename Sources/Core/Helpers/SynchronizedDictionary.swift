// SynchronizedDictionary.swift
//
// Created by Algolia on 08/01/2024
//

import Foundation

struct SynchronizedDictionary<K: Hashable, V> {
    subscript(key: K) -> V? {
        get {
            var value: V?

            self.queue.sync {
                value = self.dictionary[key]
            }

            return value
        }
        set {
            self.queue.sync(flags: DispatchWorkItemFlags.barrier) {
                self.dictionary[key] = newValue
            }
        }
    }

    private var dictionary = [K: V]()
    private let queue = DispatchQueue(
        label: "SynchronizedDictionary",
        qos: DispatchQoS.userInitiated,
        attributes: [DispatchQueue.Attributes.concurrent],
        autoreleaseFrequency: DispatchQueue.AutoreleaseFrequency.inherit,
        target: nil
    )
}
