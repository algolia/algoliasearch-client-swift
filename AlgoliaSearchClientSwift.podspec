Pod::Spec.new do |spec|
  spec.name         = "AlgoliaSearchClientSwift"
  spec.module_name  = 'AlgoliaSearchClientSwift'
  spec.version      = "8.0.0-beta.5"
  spec.summary      = "Algolia Search API Client written in Swift."
  spec.homepage     = "https://github.com/algolia/algoliasearch-client-swift"
  spec.license      = { :type => "MIT", :file => "LICENSE" }
  spec.author       = { 'Algolia' => 'contact@algolia.com'  }
  spec.documentation_url = "https://www.algolia.com/doc/api-client/getting-started/what-is-the-api-client/swift/"
  spec.platforms = { :ios => "8.0", :osx => "10.10", :watchos => "2.0" }
  spec.swift_version = "5.1"
  spec.source = { :git => "https://github.com/algolia/algoliasearch-client-swift.git", :tag => spec.version }
  spec.source_files  = "Sources/AlgoliaSearchClientSwift/**/*.swift"
  spec.dependency 'Logging'
end
