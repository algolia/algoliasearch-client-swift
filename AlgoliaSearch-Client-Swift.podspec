Pod::Spec.new do |s|
    s.name = 'AlgoliaSearch-Client-Swift'
    s.module_name = 'AlgoliaSearch'
    s.version = '4.8.1'
    s.license = 'MIT'
    s.summary = 'Algolia Search API Client for iOS & OS X written in Swift.'
    s.homepage = 'https://github.com/algolia/algoliasearch-client-swift'
    s.documentation_url = 'https://community.algolia.com/algoliasearch-client-swift/'
    s.author   = { 'Algolia' => 'contact@algolia.com' }
    s.source = { :git => 'https://github.com/algolia/algoliasearch-client-swift.git', :tag => s.version }

    s.ios.deployment_target = '8.0'
    s.osx.deployment_target = '10.10'
    s.tvos.deployment_target = '9.0'
    s.watchos.deployment_target = '2.0'

    s.source_files = [
        'Source/*.swift',
        'Source/Helpers/*.swift',
    ]
end
