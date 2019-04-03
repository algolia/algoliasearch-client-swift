# NOTE: This Podfile is used to draw dependencies when building the project independently (e.g. for unit tests).

use_frameworks!

def common_deps
    pod 'AlgoliaSearchOfflineCore-iOS', '~> 1.2'
end

target "AlgoliaSearch-Offline-iOS" do
    common_deps
end

target "AlgoliaSearch-Offline-iOS-Tests" do
    common_deps
end

def testing_pods
  pod 'PromiseKit', '~> 4.4.0', :inhibit_warnings => true
end

target 'AlgoliaSearch iOS Tests' do
  testing_pods
end

target 'AlgoliaSearch OSX Tests' do
  testing_pods
end

target 'AlgoliaSearch tvOS Tests' do
  testing_pods
end

post_install do |installer|
  installer.pods_project.targets.each do |target|
    if ['PromiseKit'].include? target.name
      target.build_configurations.each do |config|
        config.build_settings['SWIFT_VERSION'] = '4.0'
      end
    end
  end
end
