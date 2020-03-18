# Swift getting started
​
[Install](https://swift.org/download/#releases) Swift if you haven't done it yet.
​

# Create Swift package
​
```shell
mkdir SwiftClientTest
cd SwiftClientTest
swift package init
```
​
# Add dependency
​
Open the Package.swift with Xcode or your favorite text editor

Set platform and add Swift Client dependency to your package.
Your package.swift must look as follows:

```swift
// swift-tools-version:5.1
// The swift-tools-version declares the minimum version of Swift required to build this package.
import PackageDescription

let package = Package(
    name: "SwiftClientTest",
    platforms: [.macOS(.v10_12)],
    products: [
        // Products define the executables and libraries produced by a package, and make them visible to other packages.
        .library(
            name: "SwiftClientTest",
            targets: ["SwiftClientTest"]),
    ],
    dependencies: [
        // Dependencies declare other packages that this package depends on.
        // .package(url: /* package url */, from: "1.0.0"),
        .package(url:"https://github.com/algolia/algoliasearch-client-swift", .branch("feat/v2/transport")),
    ],
    targets: [
        // Targets are the basic building blocks of a package. A target can define a module or a test suite.
        // Targets can depend on other targets in this package, and on products in packages which this package depends on.
        .target(
            name: "SwiftClientTest",
            dependencies: []),
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

# Make your package executable
```shell
echo 'print("Hello world!")' > ./Sources/SwiftClientTest/main.swift
```

# Test the execution of your package by running

```shell
swift run
```

You are all set to play with the Swift API Client

## Add Employee structure in a `./Sources/SwiftClientTest/Employee.swift' file
​
```swift
struct Employee: Codable, CustomStringConvertible {
  let company: String
  let name: String
  
  var description: String {
    return "(company: \(company) name: \(name))"
  }
}
```
​
## Index datas
​
Download [Employees.swift](https://github.com/algolia/algoliasearch-client-swift/blob/feat/v2/transport/Tests/AlgoliaSearchClientSwiftTests/Misc/Employees.swift) to `./Sources/SwiftClientTest/.` folder

## Test snippets

Test your snippets in `main.swift`

```swift
import Foundation
import AlgoliaSearchClientSwift

let client = Client(appID: %appID, apiKey: %apiKey)
let index = client.index(withName: %indexName)

var settings = Settings()
settings.attributesForFaceting = [.searchable("company")]

// Read employees list from json string
let employees = try! [Employee](jsonString: Resource.employees)
// Save your info in the index
let me = Hit<Employee>(objectID: %yourObjectID, object: .init(company: "Algolia", name: %yourName))
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
func searchSyncSnippet() {
  do {

    // Set attributes for faceting
    let setSettingsTask = try index.setSettings(settings)
    _ = try index.wait(for: setSettingsTask)
    
    // Save employees list at index
    let saveTask = try index.saveObjects(records: employees)
    _ = try index.wait(for: saveTask)
    
    // Get search results
    let results = try index.search(query: "algolia")
    print(try results.extractHits() as [Employee])
    
  } catch let error {
    print(error)
  }
}

func searchAsyncSnippet() {
  
  index.setSettings(settings) { result in
    switch result {
    case .failure(let error):
      print("\(error)")
      
    case .success(let revisionIndex):
      
      index.waitTask(withID: revisionIndex.taskID) { result in
        switch result {
        case .failure(let error):
          print("\(error)")

        case .success:
          index.saveObjects(records: employees) { result in
            switch result {
            case .failure(let error):
              print("\(error)")

            case .success(let response):
              index.waitTask(withID: response.taskID) { result in
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

func setGetObjectSyncSnippet() {
  do {
    let saveObject = try index.saveObject(record: me)
    _ = try index.wait(for: saveObject)
    let fetchedMe: Hit<Employee> = try index.getObject(objectID: saveObject.objectID)
    print(fetchedMe)
  } catch let error {
    print(error)
  }
}


func setGetObjectAsyncSnippet() {
  
  index.saveObject(record: me) { result in
    switch result {
    case .failure(let error):
      print("\(error)")

    case .success(let creation):
      index.waitTask(withID: creation.taskID) { result in
        switch result {
        case .failure(let error):
          print("\(error)")

        case .success:
          index.getObject(objectID: creation.objectID) { (result: Result<Hit<Employee>, Error>) in
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
* Timeouts
* Settings and its substructures
* and much more...
