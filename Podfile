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
  pod 'PromiseKit', '~> 4.4'
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
