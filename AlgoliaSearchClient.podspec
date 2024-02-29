Pod::Spec.new do |s|
  s.name = 'AlgoliaSearchClient'
  s.module_name  = 'AlgoliaSearchClient'
  s.version = '9.0.0-alpha.8'
  s.source = { :git => 'https://github.com/algolia/algoliasearch-client-swift.git', :branch => 'next' }
  s.authors = { 'Algolia' => 'contact@algolia.com' }
  s.license = { :type => 'MIT', :file => 'LICENSE' }
  s.homepage = 'https://github.com/algolia/algoliasearch-client-swift/tree/next'
  s.summary = 'Algolia Search API Client written in Swift.'
  s.documentation_url = 'https://www.algolia.com/doc/api-client/getting-started/what-is-the-api-client/swift/'
  s.source_files = 'Sources/**/*.swift'
  s.platforms = { :ios => '13.0', :osx => '10.15', :watchos => '6.0', :tvos => '13.0' }
  s.swift_version = '5.9'
  s.dependency 'AnyCodable-FlightSchool', '~> 0.6'
  s.dependency 'apple-swift-log', '~> 1.4'
end
