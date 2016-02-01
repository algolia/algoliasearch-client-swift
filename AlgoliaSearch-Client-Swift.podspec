Pod::Spec.new do |s|
    s.name = 'AlgoliaSearch-Client-Swift'
    s.module_name = 'AlgoliaSearch'
    s.version = '2.2.0'
    s.license = 'MIT'
    s.summary = 'Algolia Search API Client for iOS & OS X written in Swift.'
    s.homepage = 'https://github.com/algolia/algoliasearch-client-swift'
    s.author   = { 'Algolia' => 'contact@algolia.com' }
    s.source = { :git => 'https://github.com/algolia/algoliasearch-client-swift.git', :tag => s.version }

    s.ios.deployment_target = '8.0'
    s.osx.deployment_target = '10.9'

    # By default, do not require the offline SDK.
    s.default_subspec = 'Online'

    # Online-only API client.
    s.subspec 'Online' do |online|
        # No additional dependency.
        # WARNING: Cocoapods complains when a subspec is empty, so we must define something additional here to keep
        # it satisfied.
        online.source_files = 'Source/*.swift'
    end

    # Offline-enabled API client.
    s.subspec 'Offline' do |offline|
        offline.dependency 'AlgoliaSearchSDK-iOS'
        # Activate SDK-dependent code.
        # WARNING: Specifying the preprocessor macro is not enough; it must be added to Swift flags as well.
        offline.pod_target_xcconfig = {
            'GCC_PREPROCESSOR_DEFINITIONS' => 'ALGOLIA_SDK=1',
            'OTHER_SWIFT_FLAGS' => '-DALGOLIA_SDK'
        }
    end
end
