Pod::Spec.new do |s|
    s.name = 'InstantSearchClientOffline'
    s.module_name = 'InstantSearchClient'
    s.version = '5.1.6'
    s.license = 'MIT'
    s.summary = 'Algolia Search API Client for iOS & OS X written in Swift.'
    s.homepage = 'https://github.com/algolia/algoliasearch-client-swift'
    s.documentation_url = 'https://community.algolia.com/algoliasearch-client-swift/offline/'
    s.author   = { 'Algolia' => 'contact@algolia.com' }
    s.source = { :git => 'https://github.com/algolia/algoliasearch-client-swift.git', :tag => s.version }

    s.ios.deployment_target = '8.0'

    s.dependency 'AlgoliaSearchOfflineCore-iOS', '~> 1.2.0'

    # Activate Core-dependent code.
    # WARNING: Specifying the preprocessor macro is not enough; it must be added to Swift flags as well.
    s.pod_target_xcconfig = {
        'GCC_PREPROCESSOR_DEFINITIONS' => 'ALGOLIA_SDK=1',
        'OTHER_SWIFT_FLAGS' => '-DALGOLIA_SDK'
    }
    s.source_files = [
        'Sources/AlgoliaSearch-Client/**/*.{swift}',
        'Sources/AlgoliaSearch-Offline/**/*.{swift}'
    ]
end
