Pod::Spec.new do |s|
  s.name = 'AlgoliaSearchClient'
  s.module_name  = 'AlgoliaSearchClient'
  s.version = '9.35.0'
  s.source = { :git => 'https://github.com/algolia/algoliasearch-client-swift.git', :tag => '9.35.0' }
  s.authors = { 'Algolia' => 'contact@algolia.com' }
  s.license = { :type => 'MIT', :file => 'LICENSE' }
  s.homepage = 'https://github.com/algolia/algoliasearch-client-swift/tree/main'
  s.summary = 'Algolia Search API Client written in Swift.'
  s.documentation_url = 'https://www.algolia.com/doc/libraries/sdk/install#swift'
  s.ios.deployment_target = '14.0'
  s.osx.deployment_target = '11.0'
  s.watchos.deployment_target = '7.0'
  s.tvos.deployment_target = '14.0'
  s.swift_version = '5.9'
  s.resource_bundles = { 'AlgoliaSearchClient' => ['PrivacyInfo.xcprivacy']}

  s.subspec 'Core' do |subs|
    subs.source_files = 'Sources/Core/**/*.swift'
  end
  s.subspec 'Abtesting' do |subs|
    subs.source_files = 'Sources/Abtesting/**/*.swift'
    subs.dependency 'AlgoliaSearchClient/Core'
  end
  s.subspec 'AbtestingV3' do |subs|
    subs.source_files = 'Sources/AbtestingV3/**/*.swift'
    subs.dependency 'AlgoliaSearchClient/Core'
  end
  s.subspec 'Analytics' do |subs|
    subs.source_files = 'Sources/Analytics/**/*.swift'
    subs.dependency 'AlgoliaSearchClient/Core'
  end
  s.subspec 'Composition' do |subs|
    subs.source_files = 'Sources/Composition/**/*.swift'
    subs.dependency 'AlgoliaSearchClient/Core'
  end
  s.subspec 'Ingestion' do |subs|
    subs.source_files = 'Sources/Ingestion/**/*.swift'
    subs.dependency 'AlgoliaSearchClient/Core'
  end
  s.subspec 'Insights' do |subs|
    subs.source_files = 'Sources/Insights/**/*.swift'
    subs.dependency 'AlgoliaSearchClient/Core'
  end
  s.subspec 'Monitoring' do |subs|
    subs.source_files = 'Sources/Monitoring/**/*.swift'
    subs.dependency 'AlgoliaSearchClient/Core'
  end
  s.subspec 'Personalization' do |subs|
    subs.source_files = 'Sources/Personalization/**/*.swift'
    subs.dependency 'AlgoliaSearchClient/Core'
  end
  s.subspec 'QuerySuggestions' do |subs|
    subs.source_files = 'Sources/QuerySuggestions/**/*.swift'
    subs.dependency 'AlgoliaSearchClient/Core'
  end
  s.subspec 'Recommend' do |subs|
    subs.source_files = 'Sources/Recommend/**/*.swift'
    subs.dependency 'AlgoliaSearchClient/Core'
  end
  s.subspec 'Search' do |subs|
    subs.source_files = 'Sources/Search/**/*.swift'
    subs.dependency 'AlgoliaSearchClient/Core'
  end
end
