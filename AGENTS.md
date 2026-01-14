# SWIFT CLIENT - AI AGENT INSTRUCTIONS

## ⚠️ CRITICAL: CHECK YOUR REPOSITORY FIRST

Before making ANY changes, verify you're in the correct repository:

```bash
git remote -v
```

- ✅ **CORRECT**: `origin .../algolia/api-clients-automation.git` → You may proceed
- ❌ **WRONG**: `origin .../algolia/algoliasearch-client-swift.git` → STOP! This is the PUBLIC repository

**If you're in `algoliasearch-client-swift`**: Do NOT make changes here. All changes must go through `api-clients-automation`. PRs and commits made directly to the public repo will be discarded on next release.

## ⚠️ BEFORE ANY EDIT: Check If File Is Generated

Before editing ANY file, verify it's hand-written by checking `config/generation.config.mjs`:

```javascript
// In generation.config.mjs - patterns WITHOUT '!' are GENERATED (do not edit)
'clients/algoliasearch-client-swift/**/Sources/**',             // Generated
'!clients/algoliasearch-client-swift/Sources/Core/**',          // Hand-written ✓
'!clients/algoliasearch-client-swift/Sources/Search/Extra/**',  // Hand-written ✓
```

**Hand-written (safe to edit):**

- `Sources/Core/**` - Core utilities, transport, configuration (except `Version.swift`)
- `Sources/Search/Extra/**` - Search-specific extensions
- `Sources/zlib/**` - Compression utilities

**Generated (DO NOT EDIT):**

- `Sources/{Client}/Models/**` - API models per client
- `Sources/{Client}/{Client}Client.swift` - API client classes
- `Sources/Core/Helpers/Version.swift` - Version info
- `Package.swift`, `AlgoliaSearchClient.podspec`

## Language Conventions

### Naming

- **Files**: `PascalCase.swift`
- **Types/Protocols**: `PascalCase`
- **Functions/Properties**: `camelCase`
- **Constants**: `camelCase` (Swift convention)

### Formatting

- SwiftFormat
- Run: `yarn cli format swift clients/algoliasearch-client-swift`

### Swift Idioms

- Protocol-oriented programming
- Value types (structs) over reference types (classes) where possible
- Use `guard` for early returns
- Prefer `let` over `var`
- Use `async/await` for asynchronous code

### Dependencies

- **HTTP**: URLSession (Foundation)
- **JSON**: Codable (Foundation)
- **Build**: Swift Package Manager (SPM)
- **Min version**: Swift 5.x

## Client Patterns

### Transport Architecture

```swift
// Sources/Core/
public struct Configuration {
    let appID: String
    let apiKey: String
    let hosts: [RetryableHost]
    let readTimeout: TimeInterval
    let writeTimeout: TimeInterval
}

// Transport uses URLSession with retry logic
class Transport {
    func request<T: Decodable>(...) async throws -> T
}
```

### Async/Await

```swift
// All API methods are async
func search(params: SearchParams) async throws -> SearchResponse

// Usage
Task {
    let response = try await client.search(params)
}
```

### Error Handling

```swift
// Swift error types
enum AlgoliaError: Error {
    case httpError(statusCode: Int, message: String)
    case unreachableHosts
    case decodingError(Error)
}

// Usage with do-catch
do {
    let response = try await client.search(params)
} catch let error as AlgoliaError {
    switch error {
    case .httpError(let code, let message):
        // Handle HTTP error
    case .unreachableHosts:
        // Handle network error
    }
}
```

## Common Gotchas

### Async Context

```swift
// WRONG - can't use await outside async context
let response = try await client.search(params)

// CORRECT - wrap in Task
Task {
    let response = try await client.search(params)
}

// Or use async function
func myAsyncFunction() async throws {
    let response = try await client.search(params)
}
```

### Optionals

```swift
// Use optional binding
if let hits = response.hits {
    // hits is non-optional here
}

// Or guard
guard let hits = response.hits else { return }

// Optional chaining
let count = response.hits?.count ?? 0
```

### Codable

```swift
// Models use Codable for JSON serialization
struct SearchParams: Codable {
    let query: String
    let hitsPerPage: Int?

    enum CodingKeys: String, CodingKey {
        case query
        case hitsPerPage = "hitsPerPage"
    }
}
```

### Value vs Reference Types

```swift
// Prefer struct (value type) for data
struct SearchParams { ... }  // ✓

// Use class only when reference semantics needed
class SearchClient { ... }   // Client needs reference
```

### Platform Availability

```swift
// Check availability for newer APIs
if #available(iOS 15.0, macOS 12.0, *) {
    // Use newer API
} else {
    // Fallback
}
```

## Build & Test Commands

```bash
# From repo root (api-clients-automation)
yarn cli build clients swift                   # Build Swift client
yarn cli cts generate swift                    # Generate CTS tests
yarn cli cts run swift                         # Run CTS tests
yarn cli playground swift search               # Interactive playground
yarn cli format swift clients/algoliasearch-client-swift

# From client directory (requires Xcode/Swift toolchain)
cd clients/algoliasearch-client-swift
swift build                                    # Build package
swift test                                     # Run tests
```
