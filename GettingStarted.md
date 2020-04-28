# Swift getting started
​
[Install](https://swift.org/download/#releases) Swift if you haven't done it yet.
​

# Create Swift package
​
```shell
mkdir SwiftClientTest;cd SwiftClientTest
swift package init --type executable
```
​
# Add dependency
​
Open the Package.swift with Xcode or your favorite text editor

Set platform and add Swift Client dependency to your package.
Your package.swift must look as follows:

```swift
// swift-tools-version:5.2
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "SwiftClientTest",
    dependencies: [
        .package(name: "AlgoliaSearchClientSwift", url: "https://github.com/algolia/algoliasearch-client-swift", from: "8.0.0-beta.2")
    ],
    targets: [
        .target(
            name: "SwiftClientTest",
            dependencies: ["AlgoliaSearchClientSwift"]),
        .testTarget(
            name: "SwiftClientTestTests",
            dependencies: ["SwiftClientTest"]),
    ]
)
```

Fetch Swift client dependency by launching

```shell
swift package resolve
```

# Test the execution of your package by running

```shell
swift run
```

You are all set to play with the Swift API Client

## Add Employee structure in a `./Sources/SwiftClientTest/Employee.swift' file
​
```swift
import Foundation

struct Employee: Codable, CustomStringConvertible {
  let company: String
  let name: String
  
  var description: String {
    return "(company: \(company) name: \(name))"
  }
}

extension Array where Element == Employee {
  
  init(jsonFile: String) throws {
    let url = URL(fileURLWithPath: #file).deletingLastPathComponent().appendingPathComponent(jsonFile)
    let data = try Data(contentsOf: url)
    self = try JSONDecoder().decode([Employee].self, from: data)
  }
  
}
```
​
## Index datas
​
Download [Employees.json](https://github.com/algolia/algoliasearch-client-swift/blob/feat/v2/develop/Tests/AlgoliaSearchClientSwiftTests/Misc/Employees.json) to `./Sources/SwiftClientTest/.` folder

## Test snippets

Test your snippets in `main.swift`

```swift
import Foundation
import AlgoliaSearchClientSwift

let client = Client(appID: "APP ID", apiKey: "API KEY")
let index = client.index(withName: "INDEX NAME")

let settings = Settings().set(\.attributesForFaceting, to: [.searchable("company")])

// Read employees list from json string
let employees: [Employee] = try .init(jsonFile: "Employees.json")

// Save your info in the index
let me = Employee(company: "Algolia", name: "Your Name")
try index.saveObject(me).wait()
```
​
## How to test my snippets?
​
```shell
swift run
```
​
Or open your Package.swift with **Xcode** and run it with Cmd+R.
​
All the methods are provided in synchronous and asynchronous version. 
Copy-paste these snippets to your main.swift and call them.

## Search snippet

```swift
func searchSyncSnippet() throws {

  // Set attributes for faceting
  try index.setSettings(settings).wait()

  // Save employees list at index
  try index.saveObjects(employees).wait()

  // Get search results
  let results: [Employee] = try index.search(query: "algolia").extractHits()
  print(results)

}

func searchAsyncSnippet() {
  
  index.setSettings(settings) { result in
    switch result {
    case .failure(let error):
      print("\(error)")
      
    case .success(let revisionIndex):
      revisionIndex.wait { result in
        switch result {
        case .failure(let error):
          print("\(error)")

        case .success:
          index.saveObjects(records: employees) { result in
            switch result {
            case .failure(let error):
              print("\(error)")

            case .success(let saveTask):
              saveTask.wait { result in
                switch result {
                case .failure(let error):
                  print("\(error)")

                case .success:
                  index.search(query: "algolia") { result in
                    switch result {
                    case .failure(let error):
                      print("\(error)")
                      
                    case .success(let response):
                      print(try! response.extractHits() as [Employee])
                    }
                  }
                }
              }
            }
          }
        }
      }
    }
  }
  sleep(100)
}
```

## Save/Get object snippet

```swift

func setGetObjectSyncSnippet() throws {
  let saveObject = try index.saveObject(me)
  let meObjectID = saveObject.task.objectID
  try saveObject.wait()
  let fetchedMe: Hit<Employee> = try index.getObject(withID: meObjectID)
  print(fetchedMe)
}

func setGetObjectAsyncSnippet() {
  
  index.saveObject(me) { result in
    switch result {
    case .failure(let error):
      print("\(error)")

    case .success(let objectCreation):
      objectCreation.wait() { result in
        switch result {
        case .failure(let error):
          print("\(error)")

        case .success:
          index.getObject(withID: objectCreation.task.objectID) { (result: Result<Hit<Employee>, Error>) in
            switch result {
            case .failure(let error):
              print("\(error)")
              
            case .success(let fetchedMe):
              print(fetchedMe)
            }
          }
        }
      }
    }
  }
  sleep(100)
}
```
​
# Nice things to test
​
* RequestOptions
* MultiThreading
* Cancellation
* Batching
* Timeouts
* Settings and its substructures
* and much more...

# Functionalities not finished yet
* Synonyms
* Query rules
* MCM
* Secured API keys
* Analytics
