Pod::Spec.new do |s|
  s.name = 'AlgoliaSearchClient'
  s.ios.deployment_target = '11.0'
  s.osx.deployment_target = '10.13'
  s.tvos.deployment_target = '11.0'
  s.watchos.deployment_target = '4.0'
  s.version = '9.0.0-alpha.0'
  s.source = { :git => 'https://github.com/algolia/algoliasearch-client-swift.git', :branch => 'next' }
  s.authors = { 'Algolia' => 'contact@algolia.com' }
  s.license = { :type => 'MIT', :file => 'LICENSE' }
  s.homepage = 'https://github.com/algolia/algoliasearch-client-swift/tree/next'
  s.summary = 'Algolia Search API Client written in Swift.'
  s.documentation_url = 'https://www.algolia.com/doc/api-client/getting-started/what-is-the-api-client/swift/'
  s.source_files = 'Sources/AlgoliaSearchClient/**/*.swift'
  s.dependency 'AnyCodable-FlightSchool', '~> 0.6'
end
